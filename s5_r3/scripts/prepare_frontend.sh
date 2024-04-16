#!/usr/bin/env bash
#uni: ez2313
#script to prepare training examples for the frontend block that will take text as input and return speech embeddings as output
#creates training output using the encoder nnet, and performs grapheme-to-phoneme processing to create the training intput in vector of int form. 
stage=2
#nj=8
lang_dir=data/lang_chain/phones
#training_text=data/train_cleaned_sp_hires/text
utt2num=data/train_cleaned_sp_hires/utt2num_frames
phones=exp/chain_cleaned_1d/tdnn1d_sp/graph/phones.txt
ali_dir=exp/chain_cleaned_1d/tree_bi
model=exp/encoder_decoder/encoder.mdl
output_dir=data/train_frontend
lpc_train=data/train_cleaned_sp_hires/feats.scp
ivectors_train=exp/nnet3_cleaned_1d/ivectors_train_cleaned_sp_hires
ivector_period=$(cat ${ivectors_train}/ivector_period)
home=$PWD
#output_wspecifier="ark| copy-feats --compress=true ark:- ark:- | gzip -c > $output_dir/nnet_output.JOB.gz"
output_wspecifier="ark:-| copy-feats --compress=true ark:- ark,scp:${home}/${output_dir}/data/frontend_output.ark,${home}/${output_dir}/data/frontend_output.scp"
#log_dir=data/train_frontend/log

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mkdir -p $output_dir/data
#mkdir -p $log_dir

#format lexicon
if [ $stage -le 0 ]; then
  echo "start run Frontend stage 0"
  cut -d " " -f2- $lang_dir/align_lexicon.txt>$output_dir/lexicon.txt
  echo "run Frontend stage 0 DONE"
fi

#create training output
if [ $stage -le 1 ]; then
  echo "start run Frontend stage 1"
  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_train}/ivector_online.scp \
         --online-ivector-period=$ivector_period $model scp:${home}/${lpc_train} \
         $output_wspecifier || exit 1
  echo "run Frontend stage 1 DONE"
fi

#create training output
#script without parallelization works but takes 5 hours...
#TODO fix parallel so each job uses a split of data (e.g. by running utils/split_scp.pl
#if [ $stage -le 1 ]; then
#  echo "start run Frontend stage 1"
#  $train_cmd JOB=1:$nj $log_dir/nnet3_compute_output.JOB.log \
#	  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_train}/ivector_online.scp \
#	  --online-ivector-period=$ivector_period $model scp:${home}/${lpc_train} \
#	  $output_wspecifier || exit 1

  # concatenate the .scp files together.
#  for n in $(seq $nj); do
#	  cat ${home}/${output_dir}/data/frontend_output.$n.scp || exit 1
#  done > $output_dir/feats.scp || exit 1
#
#  echo "run Frontend stage 1 DONE"
#fi

#create training input
if [ $stage -le 2 ]; then
  echo "start run Frontend stage 2"
  counter=0
  for n in $ali_dir/ali.*.gz; do
	  ((counter++))
	  input_wspecifier="copy-feats --compress=true ark:- ark,scp:${home}/${output_dir}/data/frontend_input.${counter}.ark,${home}/${output_dir}/data/frontend_input.${counter}.scp"
	  gunzip -c $n|  ali-to-phones --per-frame=true  ${ali_dir}/final.mdl ark:- ark,t:-|scripts/text_process_train.py --utt2numframes=${utt2num} | $input_wspecifier ||exit 1
  done

  #concatenate the .scp files together.
  for n in ${home}/${output_dir}/data/frontend_input.*.scp; do
         cat $n || exit 1
  done > $output_dir/feats.scp || exit 1
  echo "run Frontend stage 2 DONE"
fi
