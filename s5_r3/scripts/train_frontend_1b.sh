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
num_jobs_initial=4
num_jobs_final=22
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
  fast-lstmp-layer name=blstm1-forward input=input delay=-1 $lstm_opts
  fast-lstmp-layer name=blstm1-backward input=input delay=1 $lstm_opts
  fast-lstmp-layer name=blstm2-forward input=Append(blstm1-forward, blstm1-backward) delay=-2 $lstm_opts
  fast-lstmp-layer name=blstm2-backward input=Append(blstm1-forward, blstm1-backward) delay=2 $lstm_opts
  fast-lstmp-layer name=blstm3-forward input=Append(blstm2-forward, blstm2-backward) delay=-3 $lstm_opts
  fast-lstmp-layer name=blstm3-backward input=Append(blstm2-forward, blstm2-backward) delay=3 $lstm_opts
  
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
      --egs.chunk-width=$chunk_width \
      --egs.chunk-left-context=$chunk_left_context \
      --egs.chunk-right-context=$chunk_right_context \
      --egs.chunk-left-context-initial=0 \
      --egs.chunk-right-context-final=0 \
      --egs.dir="$egs_dir" \
      --feat.cmvn-opts "--norm-means=false --norm-vars=false" \
      --trainer.num-epochs=$num_epochs \
      --trainer.samples-per-iter=$samples_per_iter \
      --trainer.optimization.num-jobs-initial=2 \
      --trainer.optimization.num-jobs-final=2 \
      --trainer.optimization.shrink-value 0.99 \
      --trainer.optimization.initial-effective-lrate=$initial_effective_lrate \
      --trainer.optimization.final-effective-lrate=$final_effective_lrate \
      --trainer.rnn.num-chunk-per-minibatch=$num_chunk_per_minibatch \
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
