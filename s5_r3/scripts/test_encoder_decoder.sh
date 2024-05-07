#!/usr/bin/env bash
  
#uni:ez2313
#script to evaluate the encoder-decoder network on  hires LPC coefficients of the Tedlium test set and dev set.

#configurations

stage=1
model=exp/encoder_decoder/final.raw
lpc_test=data/test_hires/feats.scp
ivectors_test=exp/nnet3_cleaned_1d/ivectors_test_hires
ivector_period=$(cat ${ivectors_test}/ivector_period)


lpc_dev=data/dev_hires/feats.scp
ivectors_dev=exp/nnet3_cleaned_1d/ivectors_dev_hires
ivector_dev_period=$(cat ${ivectors_dev}/ivector_period)


eval_dir=data/testing_encoder_decoder
home=$PWD
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mkdir -p $eval_dir
if [ $stage -le 0 ]; then
  echo "Begin stage 0: Encoder decoder on test set"
  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_test}/ivector_online.scp --online-ivector-period=$ivector_period $model scp:${home}/${lpc_test} ark,t:${home}/${eval_dir}/predicted_output.ark;
  copy-feats scp:${lpc_test} ark,t:${home}/${eval_dir}/test_actual.ark
  echo -e "\n" >>results.txt
  echo -e "Mean squared error, following Kaldi convention of -.5*(x-y).(x-y) \n" >> results.txt
  echo "Encoder Decoder test set results:">>results.txt
  compute-MSE ${home}/${eval_dir}/predicted_output.ark ${home}/${eval_dir}/test_actual.ark >>results.txt 
fi

if [ $stage -le 1 ]; then
  echo "Begin stage 1: Encoder decoder on dev set"
  nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_dev}/ivector_online.scp --online-ivector-period=$ivector_dev_period $model scp:${home}/${lpc_dev} ark,t:${home}/${eval_dir}/predicted_dev_output.ark;
  copy-feats scp:${lpc_dev} ark,t:${home}/${eval_dir}/dev_actual.ark
  echo -e "\n" >>results.txt
  echo "Encoder Decoder dev set results:">>results.txt
  compute-MSE ark:${home}/${eval_dir}/predicted_dev_output.ark ark:${home}/${eval_dir}/dev_actual.ark >>results.txt
fi

