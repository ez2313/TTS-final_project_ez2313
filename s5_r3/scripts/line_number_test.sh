#!/usr/bin/env bash
  
#uni:ez2313
#script to evaluate the frontend using MSE. The predicted output is the output of passing the test text into the frontend block. The actual output is the output of passing the test LPC feats into the encoder nnet.

#configurations
stage=1
output_model=exp/encoder_decoder/encoder.mdl
lpc_test=data/test_hires/feats.scp

feature_order=1024
ivectors_test=exp/nnet3_cleaned_1d/ivectors_test_hires
ivector_period=$(cat ${ivectors_test}/ivector_period)

input_model=exp/frontend/final.raw
test_text=data/test_hires/text
lexicon=data/train_frontend/lexicon.txt
phones=exp/chain_cleaned_1d/tdnn1d_sp/graph/phones.txt
utt2num=data/test_hires/utt2num_frames
#use training alignments for calculating duration of phonemes
ali_dir=exp/chain_cleaned_1d/tree_bi

eval_dir=data/testing_frontend

home=$PWD

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

mkdir -p $eval_dir

if [ $stage -le 0 ]; then
  echo "Begin stage 0: Text preparation"
  #create mapping for average phoneme duration
  counter=0
  for n in $ali_dir/ali.*.gz; do
          ((counter++))
          gunzip -c $n|  ali-to-phones --per-frame=true  ${ali_dir}/final.mdl ark:- ark,t:->>${eval_dir}/durations_data.txt ||exit 1
  done
  #construct file of average phoneme duration from training data
  awk '{                 
    for (i = 2; i <= NF; i++) {
        if ($i != last) {
            if (last != "") {
                total_consecutive[last] += count
                total_numbers[last]++
            }
            count = 0
            last = $i
        }
        count++
    }
    total_consecutive[last] += count
    total_numbers[last]++
	}
	END {
    	for (number in total_consecutive) {
        	average = total_consecutive[number] / total_numbers[number]
		rounded_average = sprintf("%.0f", average)
                print number, rounded_average
    	}
	}' ${eval_dir}/durations_data.txt > ${eval_dir}/durations_dict.txt;

  echo "End stage 0: Text preparation"
fi

if [ $stage -le 1 ]; then
  echo "Begin stage 1: Compute features and predicted fronted output"
  scripts/text_to_feats.py --text=${test_text} --lexicon=${lexicon} --phones=${phones} --utt2numframes=${utt2num} --duration=${eval_dir}/durations_dict.txt > test_line_numbers.txt
 echo "End stage 1"
fi
