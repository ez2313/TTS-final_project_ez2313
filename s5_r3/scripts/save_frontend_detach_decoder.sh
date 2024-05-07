#!/usr/bin/env bash
#uni:ez2313
#script to copy frontend nnet into trained_models directory
#detach decoder and move into trained_models directory
#freeze learning rates to zero
. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh


stage=1
frontend=exp/frontend/final.raw
decoder_dir=exp/encoder_decoder
trained_dir=trained_models
new_conf=conf/detach_decoder.cfg
src_conf=conf/encoder_decoder.cfg

#copy frontend and freeze learning rate
#copy inverse LDA matrix for decoder
if [ $stage -le 0 ]; then
	mkdir -p $trained_dir
	nnet3-copy --edits='set-learning-rate-factor name=* learning-rate-factor=0' $frontend $trained_dir/frontend.mdl
	cp $decoder_dir/offset_inv.mat $trained_dir
fi

#create configs needed to detach decoder
if [ $stage -le 1 ]; then
	echo "input-node name=input dim=1024">$new_conf
	echo "component-node name=tdnnf13b.noop component=tdnnf13b.noop input=input">>$new_conf

	#sed '$d' conf/add.decoder.cfg >>$new_conf
	#echo "output-node name=output input=output.noop objective=quadratic">>$new_conf

	#nnet3-info --verbose=3 $decoder_dir/encoder_decoder.raw > $src_conf
	#echo "input-node name=input dim=1024">$new_conf
	#echo "component-node name=tdnnf13b.noop component=tdnnf13b.noop input=input input-dim=1024 output-dim=1024">>$new_conf
	#sed -n '/component-node name=tdnnf13b.dropout component=tdnnf13b.dropout input=tdnnf13b.noop input-dim=1024 output-dim=1024/,/output-node name=output input=output.noop dim=20 objective=quadratic/p'\
	     #  	$src_conf >>$new_conf
	#sed -n '/component name=tdnnf13b.noop/,$p' $src_conf >>$new_conf
fi

#detach decoder
if [ $stage -le 2 ]; then
	#nnet3-init $new_conf $trained_dir/decoder.raw
	nnet3-copy --nnet-config=$new_conf --edits='set-learning-rate-factor name=* learning-rate-factor=0;remove-orphan-inputs=true' $decoder_dir/encoder_decoder.raw $trained_dir/decoder.mdl
fi
