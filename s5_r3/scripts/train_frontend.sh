#!/usr/bin/env bash
#uni: ez2313
#script to train frontend RNN using LSTM and training data from prepare_frontend.sh
stage=0
train_stage=-10
num_epochs=30
feats_dir=data/train_frontend
targets_scp=data/train_frontend/data/frontend_output.scp
dir=exp/frontend
egs_dir=exp/frontend/egs

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

#BLSTM configuration adapted from ASPIRE run_blstm_7b.sh
if [ $stage -le 0 ]; then
  echo "Begin stage 0:  creating neural net configs"
  lstm_opts="decay-time=20"
  mkdir -p $dir/configs
  cat <<EOF > $dir/configs/network.xconfig
  input dim=184 name=input
  fast-lstmp-layer name=blstm1-forward input=input cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm1-backward input=input cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts
  fast-lstmp-layer name=blstm2-forward input=Append(blstm1-forward, blstm1-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm2-backward input=Append(blstm1-forward, blstm1-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts
  fast-lstmp-layer name=blstm3-forward input=Append(blstm2-forward, blstm2-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm3-backward input=Append(blstm2-forward, blstm2-backward) cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=3 $lstm_opts
  
  output-layer name=output input=Append(blstm3-forward, blstm3-backward) output-delay=0 objective-type=quadratic include-log-softmax=false dim=1024 max-change=1.5
EOF
 steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs/
 echo "End stage 0"
 fi
#old version as backup
#  mkdir -p $dir/configs
 # cat <<EOF > $dir/configs/network.xconfig
 # input dim=184 name=input
 # fast-lstmp-layer name=lstm1 input=input cell-dim=256 recurrent-projection-dim=128 non-recurrent-projection-dim=128 delay=-6 
 # fast-lstmp-layer  name=lstm2 input=lstm1 cell-dim=512 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-6
 # fast-lstmp-layer  name=lstm3 input=lstm2 cell-dim=1024 recurrent-projection-dim=256 non-recurrent-projection-dim=256 delay=-6
 # output-layer name=output input=lstm3 dim=1024 max-change=1.5 objective-type=quadratic include-log-softmax=false
#EOF
 # steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs
 # echo "End stage 0"
#fi

if [ $stage -le 1 ]; then
  echo "Begin stage 1: data cleanup"
    cp data/train_cleaned_sp_hires/utt2spk $feats_dir
    utils/fix_data_dir.sh $feats_dir
  echo "End stage 1: data cleanup"
fi

if [ $stage -le 2 ]; then
  echo "Begin stage 2: LSTM training"
    steps/nnet3/train_raw_rnn.py \
      --stage=$train_stage \
      --cmd="$train_cmd" \
      --egs.chunk-left-context=0 \
      --egs.chunk-right-context=0 \
      --egs.chunk-left-context-initial=0 \
      --egs.chunk-right-context-final=0 \
      --egs.dir="$egs_dir" \
      --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
      --trainer.num-epochs=$num_epochs \
      --trainer.optimization.num-jobs-initial=2 \
      --trainer.optimization.num-jobs-final=2 \
      --cleanup.remove-egs false \
      --use-dense-targets true \
      --feat-dir $feats_dir \
      --targets-scp $targets_scp \
      --use-gpu=wait \
      --dir=$dir || exit 1
  echo "End stage 2: LSTM training"       
fi


exit 0
