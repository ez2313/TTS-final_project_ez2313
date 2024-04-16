#!/usr/bin/env bash
  
#uni:ez2313
#script to evaluate the encoder-decoder network
#Note: The testing data is hires LPC coefficients of the Tedlium test set. 

#configurations

#model=exp/encoder_decoder_backup/1700.raw
model=exp/encoder_decoder/final.raw
lpc_test=data/test_hires/feats.scp
lpc_order=20
ivectors_test=exp/nnet3_cleaned_1d/ivectors_test_hires
ivector_period=$(cat ${ivectors_test}/ivector_period)
eval_dir=data/testing_encoder_decoder
home=$PWD
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mkdir -p $eval_dir
nnet3-compute-batch --use-gpu=wait --online-ivectors=scp:${home}/${ivectors_test}/ivector_online.scp --online-ivector-period=$ivector_period $model scp:${home}/${lpc_test} ark,t:${home}/${eval_dir}/predicted_output.ark;

copy-feats scp:${lpc_test} ark,t:${home}/${eval_dir}/test_actual.ark


echo -e "Mean squared error, following Kaldi convention of -.5*(x-y).(x-y) \n" >> results.txt
echo "Encoder Decoder testing results:">>results.txt
scripts/compute_MSE.py ${home}/${eval_dir}/predicted_output.ark ${home}/${eval_dir}/test_actual.ark $lpc_order >>results.txt 
