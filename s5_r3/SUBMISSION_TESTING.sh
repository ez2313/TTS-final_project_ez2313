{\rtf1\ansi\ansicpg1252\cocoartf2759
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 Menlo-Regular;}
{\colortbl;\red255\green255\blue255;\red64\green11\blue217;\red0\green0\blue0;\red46\green174\blue187;
\red180\green36\blue25;\red200\green20\blue201;\red193\green101\blue28;}
{\*\expandedcolortbl;;\cssrgb\c32309\c18666\c88229;\csgray\c0;\cssrgb\c20199\c73241\c78251;
\cssrgb\c76411\c21697\c12527;\cssrgb\c83397\c23074\c82666;\cssrgb\c80555\c47366\c13837;}
\paperw11900\paperh16840\margl1440\margr1440\vieww30080\viewh15840\viewkind0
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f0\fs22 \cf2 \CocoaLigature0 !/usr/bin/env bash\cf3 \
\cf2 #uni:ez2313\cf3 \
\cf2 #Final submission testing script to evaluate the trained encoder-decoder and frontend in terms of MSE without GPU. \cf3 \
\cf2 #Per Kaldi notation the MSE is -.5 (x-y)^T(x-y)\cf3 \
\cf2 #The evaluation is performed for a small portion of the hires test and dev sets to meet the time constraints.\cf3 \
\cf2 #Note: on my project VM with a GPU, evaluation of the full hires test and dev sets takes about a minute. \cf3 \
\
\cf2 #configurations\cf3 \
\cf4 stage\cf3 =\cf5 0\cf3 \
\
\cf2 #untoggle to test a single utterance, used for testing\cf3 \
\cf2 #lpc_test=data/test_hires/smallest_feats.scp\cf3 \
\cf2 #lpc_dev=data/dev_hires/smallest_feats.scp\cf3 \
\
\cf4 lpc_test\cf3 =data/test_hires/sample_feats.scp\
\cf4 lpc_dev\cf3 =data/dev_hires/sample_feats.scp\
\
\
\
\cf4 home\cf3 =\cf6 $PWD\cf3 \
\
\cf4 stage\cf3 =\cf5 0\cf3 \
\cf4 lpc_order\cf3 =\cf5 20\cf3 \
\cf4 embed_dim\cf3 =\cf5 1024\cf3 \
\
\cf4 ivectors_test\cf3 =exp/nnet3_cleaned_1d/ivectors_test_hires\
\cf4 ivector_period\cf3 =\cf6 $(cat $\{ivectors_test\}/ivector_period)\cf3 \
\
\cf4 ivectors_dev\cf3 =exp/nnet3_cleaned_1d/ivectors_dev_hires\
\cf4 ivector_period_dev\cf3 =\cf6 $(cat $\{ivectors_dev\}/ivector_period)\cf3 \
\
\cf2 #untogle to test a single utterance, used for testing\cf3 \
\cf2 #test_text=data/test_hires/smallest_text\cf3 \
\cf2 #dev_text=data/dev_hires/smallest_text\cf3 \
\
\cf4 test_text\cf3 =data/test_hires/sample_text\
\cf4 dev_text\cf3 =data/dev_hires/sample_text\
\
\cf4 lexicon\cf3 =trained_models/lexicon.txt\
\cf4 phones\cf3 =trained_models/phones.txt\
\
\cf4 utt2num_test\cf3 =data/test_hires/utt2num_frames\
\cf4 utt2num_dev\cf3 =data/dev_hires/utt2num_frames\
\
\
\cf2 #trained models\cf3 \
\cf4 enc_dec\cf3 =trained_models/trained_encoder_decoder.raw\
\cf4 encoder_frontend\cf3 =trained_models/encoder.mdl\
\cf4 frontend\cf3 =trained_models/frontend.mdl\
\
\
\cf2 #duration model\cf3 \
\cf4 dur\cf3 =trained_models/durations_dict.txt\
\
\
\cf4 eval_dir1\cf3 =data/testing_encoder_decoder\
\cf4 eval_dir2\cf3 =data/testing_frontend\
\
\cf7 . \cf3 ./cmd.sh\
\cf7 . \cf3 ./path.sh\
\cf7 . \cf3 ./utils/parse_options.sh\
\
\
\cf7 mkdir\cf3  \cf6 -p\cf3  \cf6 $eval_dir1\cf3 \
\cf7 mkdir\cf3  \cf6 -p\cf3  \cf6 $eval_dir2\cf3 \
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 0\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 0: Evaluate Encoder Decoder on test set\cf7 "\cf3 \
  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 --online-ivectors=scp:$\{home\}\cf3 /\cf6 $\{ivectors_test\}\cf3 /ivector_online.scp \cf6 --online-ivector-period=$ivector_period\cf3  \cf6 $enc_dec\cf3  scp:\cf6 $\{home\}\cf3 /\cf6 $\{lpc_test\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /predicted_output.ark\cf7 ||exit\cf3  \cf5 1\cf7 ;\cf3 \
  copy-feats scp:\cf6 $\{lpc_test\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /test_actual.ark\cf7 ||exit\cf3  \cf5 1\cf3 \
  \cf7 echo\cf5  -e \cf7 "\cf5 SUBMISSION TESTING FOR EZ2313 FINAL PROJECT:\cf7 "\cf5  \cf7 >\cf3  SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  -e \cf7 "\cf6 \\n\cf7 "\cf5  \cf7 >>\cf3  SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  -e \cf7 "\cf5 Mean squared error, following Kaldi convention of -.5*(x-y).(x-y) \cf6 \\n\cf7 "\cf5  \cf7 >>\cf3  SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  \cf7 "\cf5 Encoder Decoder test set results:\cf7 ">>\cf3 SUBMISSION_RESULTS.txt\
  scripts/compute_MSE.py \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /predicted_test_output.ark \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /test_actual.ark \cf6 $lpc_order\cf3  \cf7 >>\cf3 SUBMISSION_RESULTS.txt \cf7 ||exit\cf3  \cf5 1\cf7 ;\cf3 \
\cf7 fi\cf3 \
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 1\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 1: Evaluate Encoder Decoder on dev set\cf7 "\cf3 \
  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 --online-ivectors=scp:$\{home\}\cf3 /\cf6 $\{ivectors_dev\}\cf3 /ivector_online.scp \cf6 --online-ivector-period=$ivector_period_dev\cf3  \cf6 $enc_dec\cf3  scp:\cf6 $\{home\}\cf3 /\cf6 $\{lpc_dev\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /predicted_dev_output.ark\cf7 ||exit\cf3  \cf5 1\cf7 ;\cf3 \
  copy-feats scp:\cf6 $\{lpc_dev\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /dev_actual.ark\cf7 ||exit\cf3  \cf5 1\cf7 ;\cf3 \
  \cf7 echo\cf5  -e \cf7 "\cf6 \\n\cf7 "\cf5  \cf7 >>\cf3 SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  \cf7 "\cf5 Encoder Decoder dev set results:\cf7 ">>\cf3 SUBMISSION_RESULTS.txt\
  scripts/compute_MSE.py \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /predicted_dev_output.ark \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir1\}\cf3 /dev_actual.ark \cf6 $lpc_order\cf3  \cf7 >>\cf3 SUBMISSION_RESULTS.txt \cf7 ||exit\cf3  \cf5 1\cf3 \
\cf7 fi\cf3 \
\
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 2\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 2: Frontend testing Compute actual encoder output for test set\cf7 "\cf3 \
  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 --online-ivectors=scp:$\{home\}\cf3 /\cf6 $\{ivectors_test\}\cf3 /ivector_online.scp \cf6 --online-ivector-period=$ivector_period\cf3  \cf6 $encoder_frontend\cf3  scp:\cf6 $\{home\}\cf3 /\cf6 $\{lpc_test\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /actual_test_output.ark\cf7 ||exit\cf3  \cf5 1\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 End stage 2: Computed actual encoder output\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 3\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 3: Frontend Compute features and predicted fronted output for test set\cf7 "\cf3 \
  scripts/text_to_feats.py \cf6 --text=$\{test_text\}\cf3  \cf6 --lexicon=$\{lexicon\}\cf3  \cf6 --phones=$\{phones\}\cf3  \cf6 --utt2numframes=$\{utt2num_test\}\cf3  \cf6 --duration=$\{dur\}\cf3  \cf7 |\cf3  copy-feats \cf6 --compress=true\cf3  ark:- ark:- \cf7 |\cf3  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 $\{frontend\}\cf3  ark:- ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /predicted_test_output.ark \cf7 ||exit\cf3  \cf5 1\cf3 \
 \cf7 echo\cf5  \cf7 "\cf5 End stage 3\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 4\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 4: Compute Frontend TEST MSE\cf7 "\cf3 \
  \cf7 echo\cf5  -e \cf7 "\cf6 \\n\cf7 "\cf5  \cf7 >>\cf3 SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  \cf7 "\cf5 Frontend test set  results:\cf7 ">>\cf3 SUBMISSION_RESULTS.txt\
  scripts/compute_MSE.py \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /predicted_test_output.ark \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /actual_test_output.ark \cf6 $embed_dim\cf3  \cf7 >>\cf3 SUBMISSION_RESULTS.txt \cf7 ||exit\cf3  \cf5 1\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 End stage 4: Computed MSE\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 5\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 5: Frontend Compute actual encoder output for dev set\cf7 "\cf3 \
  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 --online-ivectors=scp:$\{home\}\cf3 /\cf6 $\{ivectors_dev\}\cf3 /ivector_online.scp \cf6 --online-ivector-period=$ivector_period_dev\cf3  \cf6 $encoder_frontend\cf3  scp:\cf6 $\{home\}\cf3 /\cf6 $\{lpc_dev\}\cf3  ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /actual_dev_output.ark\cf7 ||exit\cf3  \cf5 1\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 End stage 5: Computed actual encoder output\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 6\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 6: Frontend Compute features and predicted fronted output for dev set\cf7 "\cf3 \
  scripts/text_to_feats.py \cf6 --text=$\{dev_text\}\cf3  \cf6 --lexicon=$\{lexicon\}\cf3  \cf6 --phones=$\{phones\}\cf3  \cf6 --utt2numframes=$\{utt2num_dev\}\cf3  \cf6 --duration=$\{dur\}\cf3  \cf7 |\cf3  copy-feats \cf6 --compress=true\cf3  ark:- ark:- \cf7 |\cf3  nnet3-compute-batch \cf6 --use-gpu=no\cf3  \cf6 $\{frontend\}\cf3  ark:- ark,t:\cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /predicted_dev_output.ark \cf7 ||exit\cf3  \cf5 1\cf3 \
 \cf7 echo\cf5  \cf7 "\cf5 End stage 6\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\cf7 if [\cf3  \cf6 $stage\cf3  \cf7 -le\cf3  \cf5 7\cf3  \cf7 ];\cf3  \cf7 then\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 Begin stage 7: Compute DEV MSE\cf7 "\cf3 \
  \cf7 echo\cf5  -e \cf7 "\cf6 \\n\cf7 "\cf5  \cf7 >>\cf3 SUBMISSION_RESULTS.txt\
  \cf7 echo\cf5  \cf7 "\cf5 Frontend dev set  results:\cf7 ">>\cf3 SUBMISSION_RESULTS.txt\
  scripts/compute_MSE.py \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /predicted_dev_output.ark \cf6 $\{home\}\cf3 /\cf6 $\{eval_dir2\}\cf3 /actual_dev_output.ark \cf6 $embed_dim\cf3  \cf7 >>\cf3 SUBMISSION_RESULTS.txt \cf7 ||exit\cf3  \cf5 1\cf3 \
  \cf7 echo\cf5  \cf7 "\cf5 End stage 7: Computed MSE\cf7 "\cf3 \
\cf7 fi\cf3 \
\
\cf7 exit\cf3  \cf5 0}