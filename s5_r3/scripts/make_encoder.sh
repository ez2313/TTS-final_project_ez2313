#!/usr/bin/env bash
#uni:ez2313
#script to create encoder.mdl  nnet from final.mdl
#freeze learning rates to zero, remove outputs and reset tdnn13 as output for prep into decoder
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mdldir=exp/chain_cleaned_1d/tdnn1d_sp
enc_dir=exp/encoder_decoder
mkdir -p $enc_dir
nnet3-am-copy --learning-rate=0 --nnet-config=conf/add.encoder.cfg --edits='set-learning-rate-factor name=* learning-rate-factor=0; remove-output-nodes name=output; remove-output-nodes name=output-xent; rename-node old-name=output-temp new-name=output;remove-orphans' $mdldir/final.mdl $enc_dir/encoder.mdl

