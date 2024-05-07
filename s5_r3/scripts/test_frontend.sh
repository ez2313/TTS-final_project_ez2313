#!/usr/bin/env bash
  
#uni:ez2313
#script to evaluate the frontend using MSE. The predicted output is the output of passing the test text into the frontend block. The actual output is the output of passing the test LPC feats into the encoder nnet. The evaluation is performed for the hires test and dev sets.

#configurations
stage=5
output_model=exp/encoder_decoder/encoder.mdl
lpc_test=data/test_hires/feats.scp
lpc_dev=data/dev_hires/feats.scp

ivectors_test=exp/nnet3_cleaned_1d/ivectors_test_hires
ivector_period=$(cat ${ivectors_test}/ivector_period)

ivectors_dev=exp/nnet3_cleaned_1d/ivectors_dev_hires
ivector_period_dev=$(cat ${ivectors_dev}/ivector_period)

#input_model=exp/frontend/final.raw
input_model=exp/frontend_backup/final.raw
test_text=data/test_hires/text
dev_text=data/dev_hires/text

lexicon=data/train_frontend/lexicon.txt
phones=exp/chain_cleaned_1d/tdnn1d_sp/graph/phones.txt

utt2num_test=data/test_hires/utt2num_frames
utt2num_dev=data/dev_hires/utt2num_frames

#use training alignments for calculating duration of phonemes
ali_dir=exp/chain_cleaned_1d/tree_bi

eval_dir=data/testing_frontend

home=$PWD

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mkdir -p $eval_dir

if [ $stage -le 0 ]; then
  echo "Begin stage 0: Text preparation"
  #create mapping for average phoneme duration
  counter=0
  for n in $ali_dir/ali.*.gz; do
          ((counter++))
          gunzip -c $n|  ali-to-phones --per-frame=true  ${ali_dir}/final.mdl ark:- ark,t:->>${eval_dir}/durations_data.txt ||exit 1
  done
  #construct file of average phoneme duration from training data
  awk '{                 
    for (i = 2; i <= NF; i++) {
        if ($i != last) {
            if (last != "") {
                total_consecutive[last] += count
                total_numbers[last]++
            }
            count = 0
            last = $i
        }
        count++
    }
    total_consecutive[last] += count
    total_numbers[last]++
	}
	END {
    	for (number in total_consecutive) {
        	average = total_consecutive[number] / total_numbers[number]
		rounded_average = sprintf("%.0f", average)
                print number, rounded_average
    	}
	}' ${eval_dir}/durations_data.txt > ${eval_dir}/durations_dict.txt;

  echo "End stage 0: Text preparation"
fi

if [ $stage -le 1 ]; then
  echo "Begin stage 1: Compute actual encoder output for test set"
  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_test}/ivector_online.scp --online-ivector-period=$ivector_period $output_model scp:${home}/${lpc_test} ark,t:${home}/${eval_dir}/actual_test_output.ark||exit 1
  echo "End stage 1: Computed actual encoder output"
fi



if [ $stage -le 2 ]; then
  echo "Begin stage 2: Compute features and predicted fronted output for test set"
  scripts/text_to_feats.py --text=${test_text} --lexicon=${lexicon} --phones=${phones} --utt2numframes=${utt2num_test} --duration=${eval_dir}/durations_dict.txt | copy-feats --compress=true ark:- ark:- | nnet3-compute-batch --use-gpu=wait ${input_model} ark:- ark,t:${home}/${eval_dir}/predicted_test_output.ark ||exit 1
 echo "End stage 2"
fi



if [ $stage -le 3 ]; then
  echo "Begin stage 3: Compute MSE"
  echo -e "\n \n" >>results.txt
  echo "Frontend test set  results:">>results.txt
  compute-MSE ark:${home}/${eval_dir}/predicted_test_output.ark ark:${home}/${eval_dir}/actual_test_output.ark >>results.txt ||exit 1 
  echo "End stage 3: Computed MSE"
fi

if [ $stage -le 4 ]; then
  echo "Begin stage 4: Compute actual encoder output for dev set"
  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_dev}/ivector_online.scp --online-ivector-period=$ivector_period_dev $output_model scp:${home}/${lpc_dev} ark,t:${home}/${eval_dir}/actual_dev_output.ark||exit 1
  echo "End stage 4: Computed actual encoder output"
fi



if [ $stage -le 5 ]; then
  echo "Begin stage 5: Compute features and predicted fronted output for dev set"
  scripts/text_to_feats.py --text=${dev_text} --lexicon=${lexicon} --phones=${phones} --utt2numframes=${utt2num_dev} --duration=${eval_dir}/durations_dict.txt | copy-feats --compress=true ark:- ark:- | nnet3-compute-batch --use-gpu=wait ${input_model} ark:- ark,t:${home}/${eval_dir}/predicted_dev_output.ark ||exit 1
 echo "End stage 5"
fi



if [ $stage -le 6 ]; then
  echo "Begin stage 6: Compute MSE"
  echo -e "\n \n" >>results.txt
  echo "Frontend dev set  results:">>results.txt
  compute-MSE ark:${home}/${eval_dir}/predicted_dev_output.ark ark:${home}/${eval_dir}/actual_dev_output.ark >>results.txt ||exit 1
  echo "End stage 6: Computed MSE"
fi






exit 0
