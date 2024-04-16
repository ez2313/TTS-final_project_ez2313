// uni:ez2313
// adapted from featbin/get-full-lda-mat.cc

// Copyright 2012-2013  Johns Hopkins University (author: Daniel Povey)

// See ../../COPYING for clarification regarding multiple authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
// MERCHANTABLITY OR NON-INFRINGEMENT.
// See the Apache 2 License for the specific language governing permissions and
// limitations under the License.

#include "base/kaldi-common.h"
#include "util/common-utils.h"
#include "matrix/kaldi-matrix.h"
#include "transform/transform-common.h"

namespace kaldi {
void IncreaseTransformDimension(int32 new_dimension,
                       Matrix<BaseFloat> *mat) {
  int32 d = mat->NumRows();
  if (new_dimension < d)
    KALDI_ERR << "--new-dimension argument invalid or not specified: "
              << new_dimension << " < " << d;
  if (mat->NumCols() == d) { // linear transform d->d
    mat->Resize(new_dimension, new_dimension, kCopyData);
    for (int32 i = d; i < new_dimension; i++)
      (*mat)(i, i) = 1.0; // set new dims to unit matrix.
  } else if (mat->NumCols() == d+1) { // affine transform d->d.
    Vector<BaseFloat> offset(mat->NumRows());
    offset.CopyColFromMat(*mat, d);
    mat->Resize(d, d, kCopyData); // remove offset from mat->
    mat->Resize(new_dimension, new_dimension+1, kCopyData); // extend with zeros.
    for (int32 i = d; i < new_dimension; i++)
      (*mat)(i, i) = 1.0; // set new dims to unit matrix.
    for (int32 i = 0; i < d; i++) // and set offset [last column]
      (*mat)(d, i) = offset(i);          
  } else {
    KALDI_ERR << "Input matrix has unexpected dimension " << d
              << " x " << mat->NumCols();
  }  
}

} // end namespace kaldi


int main(int argc, char *argv[]) {
  try {
    using namespace kaldi;

    const char *usage =
        "Invert an LDA  matrix (n rows  by n+1 columns) and Offset reversing matrix to extract orginal feature from nnet last layer\n"
        "Usage: get-inv-lda [options] <lda-rxfilename> <inv-lda-wxfilename> <inv-offset-wxfilename> \n"
        "E.g.: get-inv-lda lda.mat lda_inv.mat offset_inv.mat\n";
    
    bool binary = true;
    ParseOptions po(usage);

    po.Register("binary", &binary, "Write in binary mode (only relevant if output is a wxfilename)");
    
    po.Read(argc, argv);
     if (po.NumArgs() !=3) {
      po.PrintUsage();
      exit(1);
    }

    

    std::string lda_rxfilename = po.GetArg(1),
        inv_lda_wxfilename = po.GetOptArg(2),
	offset_inv_wxfilename=po.GetOptArg(3);

    Matrix<BaseFloat> lda;
    ReadKaldiObject(lda_rxfilename, &lda);

    //separate linear and bias portions of LDA matrix
    //scale bias by negative one
    //invert linear component
    Vector<BaseFloat> bias(lda.NumRows());
    bias.CopyColFromMat(lda,lda.NumCols() - 1);
    bias.Scale(-1.0);

    Matrix<BaseFloat> linear(lda.NumRows(),lda.NumCols() -1);
    linear= lda.Range(0, lda.NumRows(), 0, lda.NumCols() - 1);

    linear.Invert();
    
    //prepare LDA inverse output
    Matrix<BaseFloat> output(lda);
    int32 d = lda.NumRows();
    for (int32 i=0; i<d; i++)
	    for (int32 j=0; j<d; j++)
		    output(i,j) = linear (i,j);
    for (int32 i=0; i<d; i++)
	    output(i,d)=bias(i);
    
    
    WriteKaldiObject(output, inv_lda_wxfilename, binary);

    //prepare offset reverse. In our LPC setup the dimension is twenty
     Matrix<BaseFloat> offset(20,lda.NumCols());
     offset.SetZero();
     for (int32 i=0; i<20; i++)
	     offset(i,20+i)=1.0;
     WriteKaldiObject(offset, offset_inv_wxfilename, binary);

    return 0;
  } catch(const std::exception &e) {
    std::cerr << e.what();
    return -1;
  }
}

