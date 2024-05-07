#!/usr/bin/env bash

#uni:ez2313
#script to generate examples and train the encoder-decoder network
#Note: The input data and output targets are the LPC coefficients of the Tedlium training set. 

#configurations
train_stage=-10
gmm=tri3_cleaned
nnet3_affix=_cleaned_1d  

train_set=train_cleaned
tdnn_affix=1d  #affix for TDNN directory, e.g. "a" or "b", in case we change the configuration.
lpc_dir=data/${train_set}_sp_hires
lpc_targets=${lpc_dir}/feats.scp
dir=exp/encoder_decoder
dropout_schedule='0,0@0.20,0.5@0.50,0'
train_ivector_dir=exp/nnet3${nnet3_affix}/ivectors_${train_set}_sp_hires

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

#run train.py using encoder-decoder.raw as initial model, 
#lpc coefficients as egs
# --egs.frames-per-eg 1\
steps/nnet3/train_raw_dnn.py --trainer.input-model ${dir}/encoder_decoder.raw\
	--stage $train_stage \
	--cmd "$decode_cmd" \
	--feat.online-ivector-dir $train_ivector_dir \
	--feat.cmvn-opts "--norm-means=false --norm-vars=false" \
	--trainer.optimization.minibatch-size 512 \
	--trainer.dropout-schedule $dropout_schedule \
	--trainer.num-epochs 2 \
	--trainer.optimization.num-jobs-initial 2 \
	--trainer.optimization.num-jobs-final 3 \
	--trainer.optimization.initial-effective-lrate 0.00025 \
	--trainer.optimization.final-effective-lrate 0.000025 \
	--trainer.max-param-change 2.0 \
	--cleanup.remove-egs true \
	--cleanup.preserve-model-interval 50\
	--feat-dir $lpc_dir\
	--targets-scp $lpc_targets\
	--dir $dir \
	--use-dense-targets true\
	--use-gpu=wait

