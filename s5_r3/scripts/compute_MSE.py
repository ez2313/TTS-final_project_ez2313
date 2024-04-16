#!/usr/bin/env python
#uni: ez2313
#function to take text ark format of raw features and associated  predicted output and compute MSE.  Per Kaldi NNET3, the mean squared error is on a frame level and calculated as
# -.5 (x-y).(x-y)
#inputs: path to raw features, path to predicted output, feature_order/dimension (used to compute number of frames)
#returns: value of MSE on frame level, number of frames

import argparse
import sys
sys.path.insert(0, 'steps')
from libs.common import read_mat_ark

parser = argparse.ArgumentParser(
        description='This script reads in text ark format of actual features and associated  predicted output and computes MSE. Usage: compute_MSE.py predicted_output.ark actual_features.ark feature_order')
parser.add_argument('predicted_output', type=str, help='Path to predicted output .ark file')
parser.add_argument('actual_features',type=str, help='Path to actual features file, in text .ark format')
parser.add_argument('feature_order', type=int, help='Feature order/dimension')
args = parser.parse_args()

predicted_in = args.predicted_output
actual_in = args.actual_features
feat_order= args.feature_order

#read in matrices and initialize output
predicted_values= { key: mat for key, mat in read_mat_ark(predicted_in) }
actual_values= { key: mat for key, mat in read_mat_ark(actual_in) }
objectivef=0
num_frames=0

for key in predicted_values.keys():
    if len(predicted_values[key]) != len(actual_values[key]):
        sys.exit(1)
    num_frames+=len(predicted_values[key])
    #iterate over frames
    for i in range(len(predicted_values[key])):
        #iterate over feature values
        for j in range(feat_order):
            pred_iter=predicted_values[key][i][j]
            actual_iter=actual_values[key][i][j]
            diff=pred_iter-actual_iter
            objectivef+=diff**2
MSE= -.5*objectivef/num_frames
print('Objective function is {} over {} number of frames.'.format(MSE, num_frames))
