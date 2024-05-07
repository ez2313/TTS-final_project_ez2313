#!/usr/bin/env bash
#uni: ez2313
#script to train frontend RNN using LSTM and training data from prepare_frontend.sh
stage=0
train_stage=-10
feats_dir=data/train_frontend
targets_scp=data/train_frontend/data/frontend_output.scp
dir=exp/frontend

#toggle to use old or create new examples
remove_egs=true
egs_dir=
#remove_egs=false
#egs_dir=exp/frontend/egs

#configuration adapted from TEDLIUM rnnlm

# training options
num_epochs=6
embedding_dim=1024

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

if [ $stage -le 0 ]; then
  echo "Begin stage 0:  creating neural net configs"

  mkdir -p $dir/configs
  cat <<EOF > $dir/configs/network.xconfig
  input dim=184 name=input
  relu-renorm-layer name=tdnn1 dim=$embedding_dim input=input
  relu-renorm-layer name=tdnn2 dim=$embedding_dim input=Append(0, IfDefined(-1))
  relu-renorm-layer name=tdnn3 dim=$embedding_dim input=Append(0, IfDefined(-1))
  output-layer name=output include-log-softmax=false dim=$embedding_dim
EOF

 steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs/
 echo "End stage 0"
 fi

if [ $stage -le 1 ]; then
  echo "Begin stage 1: data cleanup"
    cp data/train_cleaned_sp_hires/utt2spk $feats_dir
    utils/fix_data_dir.sh $feats_dir
  echo "End stage 1: data cleanup"
fi

if [ $stage -le 2 ]; then
  echo "Begin stage 2: LSTM training"
    steps/nnet3/train_raw_dnn.py \
      --stage=$train_stage \
      --cmd="$train_cmd" \
      --egs.dir="$egs_dir" \
      --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
      --trainer.num-epochs=$num_epochs \
      --trainer.optimization.num-jobs-initial=2 \
      --trainer.optimization.num-jobs-final=2 \
      --cleanup.remove-egs $remove_egs \
      --use-dense-targets true \
      --feat-dir $feats_dir \
      --targets-scp $targets_scp \
      --use-gpu=wait \
      --dir=$dir || exit 1
  echo "End stage 2: LSTM training"       
fi


exit 0
