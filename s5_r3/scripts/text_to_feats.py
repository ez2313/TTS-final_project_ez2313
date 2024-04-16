#!/usr/bin/env python
#uni:ez2313

# Note: Some syntax adapted from text_to_phones.py 

""" This script converts text (where each line is a ID and transcript) into phoneme features in the form of an int vector using one-hot encoding. The output is printed to stdout. 
"""

from __future__ import print_function

import argparse
import sys
import errno


parser = argparse.ArgumentParser(description="""This script converts text (where each line is a ID and transcript) into phoneme features in the form of an int vector using one-hot encoding. The output is printed to stdout.""")

parser.add_argument('--text', type=str, help="Text file to convert")
parser.add_argument('--phones', type=str, help="Text file mapping phoneme to int identifier")
parser.add_argument('--duration', type=str, help= 'Text file mapping phoneme to avg. duration')
parser.add_argument('--lexicon', type=str, help= 'Text file of data lexicon')
parser.add_argument('--utt2numframes', type=str, help= 'Optional argument (needed for testing nnet): Text file mapping utterance ID to number of frames')

args = parser.parse_args()

# Check if any of the required arguments are missing
if not (args.text and args.phones and args.duration and args.lexicon):
    parser.error("The arguments (--text, --phones, --duration, --lexicon) are required. Use --help for more information.")
    sys.exit(1)


# if utter2numframes is given, create dictionary
if args.utt2numframes:
    utt2num={}
    with open(args.utt2numframes) as f:
        for line in f:
            line=line.strip();
            parts=line.split()
            utt2num[parts[0]]=parts[1]

#create dictionary mapping phoneme to average duration
int_to_duration={}
with open(args.duration) as f:
    for line in f:
        line=line.strip();
        parts=line.split()
        #multiply by duration factor, extra factor of 3 for sampling rate
        int_to_duration[parts[0]]=(3*int(parts[1])*(parts[0]+' ')).strip()

#create mapping of phoneme to integer (concated for duration length)
phones_to_int={}
with open(args.phones) as f:
    for line in f:
        line=line.strip();
        parts=line.split()
        try:
            phones_to_int[parts[0]]=int_to_duration[str(parts[1])]
        except:
            phones_to_int[parts[0]]= (3*(parts[1]+' ')).strip()
#save dimension for use in one-hot encoding
dim=len(phones_to_int.keys())


#dictionary mapping words to phonemes in int form
words_to_phones={}
with open (args.lexicon) as f:
    for line in f:
        line=line.strip();
        parts=line.split()
        phones=parts[1:]
        str_vec=''
        for phone in phones:
            str_vec=" ".join([str_vec,phones_to_int[phone]])
            words_to_phones[parts[0]]=str_vec.strip()

#convert text into phoneme integer form
with open (args.text) as f:
    for line in f:
        line=line.strip();
        parts=line.split()
        utterance_id=parts[0]
        utterance=parts[1:]
        utterance_str=''

        for word in utterance:
            try:
                utterance_str=" ".join([utterance_str,words_to_phones[word]])
            except:
                utterance_str=" ".join([utterance_str,words_to_phones['<unk>']])

        feature_vec=[int(phone) for phone in utterance_str.split()]
        #one hot encoding using dimension of phonemes
        expanded=[[1 if i == feat else 0 for i in range(dim)] for feat in feature_vec]
        padding=[1 if i == 1  else 0 for i in range(dim)]

        try:
            counter = int(utt2num[utterance_id])-len(expanded)
            
        except:
            counter = 0
                
        try:
            #padding if predicted length less than num_frames
            if counter == 0:
                print(utterance_id+'  ' +'[')
                for i in range(len(expanded)-1):
                    print(*expanded[i])
                expanded[-1].append(']')
                print(*expanded[-1])

            elif counter > 0:
                counter_temp=counter
                print(utterance_id+'  ' +'[')
                for i in range(len(expanded)-1):
                    if counter_temp > 0 and i % 3 == 0:
                        counter_temp=counter_temp-1
                        print(*expanded[i])
                        print(*expanded[i])

                    else:
                        print(*expanded[i])
                
                if counter_temp>0:
                    print(*expanded[-1])
                    for i in range(counter_temp-1):
                        print(*padding)
                    padding.append(']')
                    print(*padding)
                else:
                    expanded[-1].append(']')
                    print(*expanded[-1])

                
            else:
                #shortening if predicted length greater than num_frames
                new_counter= abs(counter)
                output_length = 0
                print(utterance_id+'  ' +'[')
                for i in range(len(expanded)-1):
                    if new_counter > 0 and i % 3 == 0:
                        new_counter=new_counter-1
                           
                    else:
                        print(*expanded[i])
                expanded[-1].append(']')
                print(*expanded[-1])
        
                    
        except IOError as e:
            if e.errno == errno.EPIPE:
                pass
