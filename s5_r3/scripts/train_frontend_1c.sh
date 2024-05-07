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

#BLSTM configuration adapted from ASPIRE run_blstm.sh

# LSTM options
label_delay=0
cell_dim=1024
hidden_dim=1024
recurrent_projection_dim=128
non_recurrent_projection_dim=128
chunk_width=20
chunk_left_context=10
chunk_right_context=10
#chunk_left_context=40
#chunk_right_context=40


# training options
num_epochs=6
initial_effective_lrate=0.0003
final_effective_lrate=0.00003
momentum=0.5
num_chunk_per_minibatch=100
samples_per_iter=20000


. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

if [ $stage -le 0 ]; then
  echo "Begin stage 0:  creating neural net configs"
  lstm_opts="decay-time=20 cell-dim=$cell_dim"
  lstm_opts+=" recurrent-projection-dim=$recurrent_projection_dim"
  lstm_opts+=" non-recurrent-projection-dim=$non_recurrent_projection_dim"

  mkdir -p $dir/configs
  cat <<EOF > $dir/configs/network.xconfig
  input dim=184 name=input
  relu-renorm-layer name=tdnn1 dim=1024 input=Append(-2,-1,0,1,2)
  relu-renorm-layer name=tdnn2 dim=1024 input=Append(-1,2)
  relu-renorm-layer name=tdnn3 dim=1024 input=Append(-3,3)
  relu-renorm-layer name=tdnn4 dim=1024 input=Append(-7,2)
  relu-renorm-layer name=tdnn5 dim=1024
  output-layer name=output dim=$1024 max-change=1.5 objective-type=quadratic include-log-softmax=false
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
    steps/nnet3/train_raw_rnn.py \
      --stage=$train_stage \
      --cmd="$train_cmd" \
      --egs.dir="$egs_dir" \
      --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
      --trainer.num-epochs=$num_epochs \
      --trainer.samples-per-iter=$samples_per_iter \
      --trainer.optimization.num-jobs-initial=2 \
      --trainer.optimization.num-jobs-final=2 \
      --trainer.optimization.shrink-value 0.99 \
      --trainer.optimization.initial-effective-lrate=$initial_effective_lrate \
      --trainer.optimization.final-effective-lrate=$final_effective_lrate \
      --trainer.optimization.momentum=$momentum \
      --cleanup.remove-egs $remove_egs \
      --use-dense-targets true \
      --feat-dir $feats_dir \
      --targets-scp $targets_scp \
      --use-gpu=wait \
      --dir=$dir || exit 1
  echo "End stage 2: LSTM training"       
fi


exit 0
