# Overview:
Welcome! <br>
This repository is my final project for COMS6998 Fundamentals of Speech Recognition at Columbia University.
The project is a Text-To-Speech system using the open source Kaldi platform. The project uses the TEDLIUM dataset and builds off of the s5_r3 recipe. 
- The training through the initial TDNN follows the TEDLIUM recipe but uses Linear Predictive Coding (LPC) coefficients instead of MFCCs.
- The heart of the project is an encoder-decoder TDNN neural network for trained with LPC coefficients. The decoder is then detached and used as the backend of the TTS system.
- The project developed a frontend using text processing and a Bidirectional Long Short Term Memory RNN (BLSTM) to convert input text into speech embeddings. The speech embeddings are then passed into the decoder.
- Finally, a vocoder uses the predicted LPC coefficients to generate speech in waveform.
Overall the project demonstrates the ability to develop a low resource TTS system. 

# Table of Contents
The README will detail the following sections:
1. Contents of the repository.
2. Training and testing.
4. Final System.
5. Results.
6. Description of all files created or modified. 

# Final system:
The trained system consists of 3 parts:
1. **Frontend**: The frontend uses text processing to convert text into phoneme features in binary integer vector form using one-hot encoding, and then uses a BLSTM to convert the features into speech embeddings of dimension 1024.
2. **Decoder**: The decoder nnet takes the speech embeddings from the frontend as input and outputs (predicted) LPC coefficient values. The decoder does so by reversing the process of the encoder.
3. **Vocoder**: The vocoder uses the predicted LPC coefficients to produce speech in waveform. 

# Training and testing:
The training and testing is performed by run.sh with the following stages:
### Stage -1:
The stage calls setup.sh which performs the setup needed for the training process by:
1. Creating the necessary links to `utils` and `steps`.
2. Moving the custom scripts from the `scripts` directory to the appropriate subdirectory of `src`.
3. Recompiling the updated portions of `src`.

### Stages 0 to Stage 17:
For these stages, the training process follows the Tedlium s5_r3 training (adapted from the given pretrained version) but uses order 20 LPC coefficients instead of MFCCs. In order to implement the LPC coefficients the following files were modified or added:
The files. 


`TODO: add section detailing each file added/modified and usage`

# Files:
