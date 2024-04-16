#!/usr/bin/env bash
#uni:ez2313
#script to create encoder_decoder.raw  nnet from encoder.mdl
#copy and invert LDA from encoder network
#form decoder by reversing layers of encoder

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mdldir=exp/encoder_decoder
cp exp/chain_cleaned_1d/tdnn1d_sp/lda.mat $mdldir;
get-inv-lda $mdldir/lda.mat $mdldir/lda_inv.mat $mdldir/offset_inv.mat;
nnet3-am-copy --raw=true --nnet-config=conf/add.decoder.cfg --edits='remove-output-nodes name=output;rename-node old-name=output-temp new-name=output' $mdldir/encoder.mdl $mdldir/encoder_decoder.raw


