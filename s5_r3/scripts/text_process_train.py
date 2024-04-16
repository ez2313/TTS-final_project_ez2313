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

parser.add_argument('--utt2numframes', type=str, help= 'Optional argument (needed for testing nnet): Text file mapping utterance ID to number of frames')

args = parser.parse_args()


# if utter2numframes is given, create dictionary
if args.utt2numframes:
    utt2num={}
    with open(args.utt2numframes) as f:
        for line in f:
            line=line.strip();
            parts=line.split()
            utt2num[parts[0]]=parts[1]

#dimension for use in one-hot encoding
dim=184



#convert text into phoneme integer form
for line in sys.stdin:
    line=line.strip();
    parts=line.split()
    utterance_id=parts[0]
    utterance=parts[1:]

    #assume basic repeat length is 3, will be tuned later depending on how compares to actual num_frames
    feature_vec=[]
    for phone in utterance:
        feature_vec.append(phone)
        feature_vec.append(phone)
        feature_vec.append(phone)
    
    #one hot encoding using dimension of phonemes
    expanded=[[1 if i == feat else 0 for i in range(dim)] for feat in feature_vec]

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
                

        
                    
