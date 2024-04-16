// uni:ez2313
// Portions adapted from featbin/compare-feats.cc, nnet3/nnet-training.cc


#include "base/kaldi-common.h"
#include "util/common-utils.h"
#include "matrix/kaldi-matrix.h"
#include "matrix/kaldi-vector.h"


int main(int argc, char *argv[]) {
  try {
    using namespace kaldi;

    const char *usage =
        "Computes MSE  per frame between two sets of features\n"
        "with same  dimension.\n"
        "\n"
    "Usage: ComputeMSE <in-rspecifier1> <in-rspecifier2>\n"
        "e.g.: ComputeMSE ark:1.ark ark:2.ark\n";

    ParseOptions po(usage);

    
    po.Read(argc, argv);

    if (po.NumArgs() != 2) {
      po.PrintUsage();
      exit(1);
    }

    std::string rspecifier1 = po.GetArg(1), rspecifier2 = po.GetArg(2);
    
    int32 num_frames = 0; 
    BaseFloat total_objf = 0, output = 0;

    SequentialBaseFloatMatrixReader feat_reader1(rspecifier1);
    RandomAccessBaseFloatMatrixReader feat_reader2(rspecifier2);

    for (; !feat_reader1.Done(); feat_reader1.Next()) {
      std::string utt = feat_reader1.Key();
      Matrix<BaseFloat> feat1 (feat_reader1.Value());
        
      
      if (!feat_reader2.HasKey(utt)) {
        KALDI_WARN << "Second table has no feature for utterance "
                   << utt;
        continue;
      }
      Matrix<BaseFloat> feat2 (feat_reader2.Value(utt));
      
      Matrix<BaseFloat> diff(feat1);
      diff.CopyFromMat(feat1);
      diff.AddMat(-1.0, feat2);
      num_frames += diff.NumRows();
      total_objf += -0.5 * TraceMatMat(diff, diff, kTrans);
    }
   output = total_objf/num_frames;

   std::cout << "Objective function is " << output << " over " << num_frames << " number of frames." << std::endl;



  } catch(const std::exception &e) {
    std::cerr << e.what();
   return -1;
  }
}

