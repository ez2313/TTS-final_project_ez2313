# Overview:
Welcome! <br>
This repository is my final project for COMS6998 Fundamentals of Speech Recognition at Columbia University.
The project is a Text-To-Speech system using the open source Kaldi platform. The project uses the TEDLIUM dataset and builds off of the s5_r3 recipe. 
- Please see the [video](https://www.youtube.com/watch?v=rA2Aw7WRing) for a 3 minute overview of the project and results. Please see the [paper](FINAL_paper.pdf) for a full discussion.
- **Training** requires installation of [Kaldi](https://kaldi-asr.org/) and a disk with at least 2300GB and a **GPU**. Running `run.sh` without any argument from stage 0 will peform the full training. 
- **Inference and Testing** The trained models can be used as is for inference and testing. The Submission_Testing.sh script is designed for use on a system with more limited resources and **CPU only**, and provides an example of inference using the trained models (runtime should be less than 5 minutes). 
- High level overview of project:
  - The training through the initial TDNN follows the TEDLIUM recipe but uses Linear Predictive Coding (LPC) coefficients instead of MFCCs.
  - The heart of the project is an encoder-decoder TDNN neural network for trained with LPC coefficients. The decoder is then detached and used as the backend of the TTS system.
  - The project developed a frontend using text processing and a Bidirectional Long Short Term Memory RNN (BLSTM) to convert input text into speech embeddings. The speech embeddings are then passed into the decoder.
  Overall the project demonstrates the ability to develop a low resource TTS system. 

# Repository contents
 List of new and modified files (copies of files touched can be found in the scripts directory). The listing here includes a brief summary of the purpose of each file created or modified.

**Kaldi Src files lightly edited to support LPC coefficient as new feature:**\
`src/feat/online-feature.cc`\
`src/feat/online-feature.h`\
`src/feat/online-feature-test.cc`\
`src/feat/Makefile` (Edited to include new and modified src/feat files)\
`src/featbin/Makefile` (Edited to include make for new and modified src/featbin files)\


**New Src files**:\
`feat/feature-lpc.h`\
`feat/feature-lpc.cc`\
`feat/feature-lpc-test.cc`
        
        These 3 src files are used to extract LPC coefficients. The scripts are adapted from the parallel scripts for plp.\
        

`featbin/compute-lpc-feats.cc`
        
        Create LPC  feature files.
        Usage:  compute-lpc-feats [options...] <wav-rspecifier> <feats-wspecifier>
        Input: audio, Output: LPC feats`

`featbin/get-inv-lda.cc`

        Invert an LDA  matrix (n rows  by n+1 columns) and Offset reversing matrix to extract orginal feature from nnet last layer
        Usage: get-inv-lda [options] <lda-rxfilename> <inv-lda-wxfilename> <inv-offset-wxfilename>
        E.g.: get-inv-lda lda.mat lda_inv.mat offset_inv.mat

        Options:
        --binary                    : Write in binary mode (only relevant if output is a wxfilename) (bool, default = true)
        Input: LDA matrix, Output: Inverse LDA matrix, reverse offset matrix

`featbin/compute-MSE.cc`
        '''
        Computes MSE  per frame between two sets of features
        with same  dimension.

        Usage: ComputeMSE <in-rspecifier1> <in-rspecifier2>
        e.g.: ComputeMSE ark:1.ark ark:2.ark

        Standard options:
        --config                    : Configuration file to read (this option may be repeated) (string, default = "")
        --help                      : Print out usage message (bool, default = false)
        --print-args                : Print the command line arguments (to stderr) (bool, default = true)
        --verbose                   : Verbose level (higher->more logging) (int, default = 0)
        Input: two sets of feats with same dimension. Output: MSE between the sets of features.
        '''

**New scripts**:

`SUBMISSION_TESTING.sh`
        
        New script to test the trained encoder-decoder network and frontend network in terms of MSE without using a GPU.
        Output: SUBMISSION_RESULTS.txt
        

`compute_MSE.py`
        
        usage: compute_MSE.py [-h] predicted_output actual_features feature_order

        This script reads in text ark format of actual features and associated predicted output and computes MSE.

        positional arguments:
        predicted_output  Path to predicted output .ark file
        actual_features   Path to actual features file, in text .ark format
        feature_order     Feature order/dimension

        optional arguments:
        -h, --help        show this help message and exit
        Output: Mean Squared Error of the compared features.
        

`make_encoder.sh`
        
        new script to output encoder.mdl  nnet from final.mdl
        freeze learning rates to zero, remove outputs and reset tdnn13 as output for prep into decoder.
        Output: encoder.mdl
        

`make_encoder_decoder.sh`
        
        script to create encoder_decoder.raw  nnet from encoder.mdl, copy and invert LDA from encoder network
        form decoder by reversing layers of encoder.
        Output: (untrained) encoder_decoder.raw
        

`prepare_frontend.sh`
        
        new script to prepare training examples for the frontend block that will take text as input and return speech embeddings as output
        creates training output using the encoder nnet, and performs grapheme-to-phoneme processing to create the training intput in vector of int form.
        Output: features for use as training egs for frontend BLSTM training, both egs input and output.
        

`test_encoder_decoder.sh`
        
        new script to evaluate the encoder-decoder network on  hires LPC coefficients of the Tedlium test set and dev set.
        Output: results.txt
        

`test_frontend.sh`
        
        new script to evaluate the frontend using MSE. The predicted output is the output of passing the test text into the frontend block.
        The actual frontend output is the output of passing the test LPC feats into the encoder nnet. The evaluation is performed for the hires test and dev sets.
        Output: results.txt
        

`text_process_train.py`
                                    
        Usage: text_process_train.py [-h] [--utt2numframes UTT2NUMFRAMES]

        This script converts text (where each line is a ID and transcript) into
        phoneme features in the form of an int vector using one-hot encoding. The
        output is printed to stdout.

        optional arguments:
        -h, --help            show this help message and exit
        --utt2numframes UTT2NUMFRAMES
                        Optional argument (needed for testing nnet): Text file
                        mapping utterance ID to number of frames
        


`text_to_feats.py`
        
        usage: text_to_feats.py [-h] [--text TEXT] [--phones PHONES]
                                [--duration DURATION] [--lexicon LEXICON]
                                [--utt2numframes UTT2NUMFRAMES]

        This script converts text (where each line is a ID and transcript) into
        phoneme features in the form of an int vector using one-hot encoding. The
        output is printed to stdout.

        optional arguments:
        -h, --help            show this help message and exit
        --text TEXT           Text file to convert
        --phones PHONES       Text file mapping phoneme to int identifier
        --duration DURATION   Text file mapping phoneme to avg. duration
        --lexicon LEXICON     Text file of data lexicon
        --utt2numframes UTT2NUMFRAMES
                        Optional argument (needed for testing nnet): Text file
                        mapping utterance ID to number of frames
        


`train_encoder_decoder.sh`
        
        New script to generate examples and train the encoder-decoder network
        Note: The input data and output targets are the LPC coefficients of the Tedlium training set.
        Output: trained encoder_decoder network
        


`train_frontend.sh`
        
        New script to train frontend RNN using BLSTM and training data from prepare_frontend.sh
        Output: trained frontend BLSTM
        

The scripts/backups/ directory contains backup version and development scripts.\
The scripts/setup/ directory contains copies of the modified and new Kaldi src and steps files.\
The scripts/tuning/ directory contains 4 versions of tuning for train_frontend.sh\

**Trained_models**:
This directory contains the pretrained models and files needed for inference.

`durations_dict.txt`
         dictionary used for duration modeling

`frontend_encoder.mdl`
        trained version of encoder network used for producing ground truth
        speech embeddings for frontend training

                                                                  
`frontend.mdl`
        trained frontend BLSTM

`full_encoder.mdl`
        trained ASR encoder, based on LPCs

`lda.mat`
        lda transform matrix needed by encoders for inference/testing

`lda_inv.mat`
        transform matrix to reverse the lda transormation. Used by Decoder layers.

`lexicon.txt`
        TEDLIUM lexicon. Needed by frontend for inference/testing

`offset_inv.mat`
        matrix to reverse offset and extract desired output from nnet training. Used by Decoder layers

`phones.txt`
        TEDLIUM phoneme to integer mapping. Needed by Fronted

`trained_encoder_decoder.raw`
        Trained encoder-decoder network`

**New files in Steps to support extracting LPC coefficients**\
`steps/make_lpc.sh`

**Modified TEDLIUM files:**\
`local/nnet3/run_ivector_common.sh` (Lightly edited to use LPC coefficients)\
`local/chain/tuning/run_tdnn_1d.sh` (input dimension changed to be 20 order for LPC coefficients.)\
`run.sh`
        Steps 1-17 modified to use LPC coefficients instead of MFCCs. Stages 18-24 new. Trains encoder-decoder network and frontend, performs GPU testing.
        Output: results.txt, and trained models placed in trained_models/ directory

**New conf**:\
`conf/add.encoder.cfg`
        configuration file for creating encoder.mdl
        
`conf/add.decoder.cfg`
        configuration file used for adding decoder layers to encoder decoder network.\


