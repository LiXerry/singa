%module model_operation

%include "config.i"
%include "std_vector.i"
%include "std_string.i"
%{
#include "../src/model/operation/convolution.h"
#include "../src/model/operation/batchnorm.h"
%}
namespace singa {

class ConvHandle {
 public:
  ConvHandle(const Tensor &input, const std::vector<size_t>& kernel_size,
             const std::vector<size_t>& stride, const std::vector<size_t>& padding,
             const size_t in_channels, const size_t out_channels,
             const bool bias);
  bool bias_term;
  size_t batchsize;
};

Tensor CpuConvForward(const Tensor &x, Tensor &W,  Tensor &b, const ConvHandle &ch);

Tensor CpuConvBackwardx(const Tensor &dy, Tensor &W, const Tensor &x, const ConvHandle &ch);

Tensor CpuConvBackwardW(const Tensor &dy, const Tensor &x, const Tensor &W, const ConvHandle &ch);

Tensor CpuConvBackwardb(const Tensor &dy, const Tensor &b, const ConvHandle &ch);

#if USE_CUDNN
class CudnnConvHandle: public ConvHandle {
 public:
  CudnnConvHandle(const Tensor &input, const std::vector<size_t>& kernel_size,
                  const std::vector<size_t>& stride, const std::vector<size_t>& padding,
                  const size_t in_channels, const size_t out_channels,
                  const bool bias, const size_t workspace_byte_limit = 1024 * 1024 * 1024,
                  const std::string& prefer = "fastest");
  bool bias_term;
  size_t batchsize;
};

Tensor GpuConvForward(const Tensor &x, const Tensor &W, const Tensor &b, const CudnnConvHandle &cch);

Tensor GpuConvBackwardx(const Tensor &dy, const Tensor &W, const Tensor &x, const CudnnConvHandle &cch);

Tensor GpuConvBackwardW(const Tensor &dy, const Tensor &x, const Tensor &W, const CudnnConvHandle &cch);

Tensor GpuConvBackwardb(const Tensor &dy, const Tensor &b, const CudnnConvHandle &cch);

#endif  // USE_CUDNN

class BatchNormHandle{
  public:
    BatchNormHandle(const float momentum, const Tensor& input, const Tensor& RunningMean_, const Tensor& RunningVariance_);

    size_t batchsize;
    Tensor runningMean_;
    Tensor runningVariance_;

};


class CudnnBatchNormHandle: public BatchNormHandle{
    public:
      CudnnBatchNormHandle(const float momentum, const Tensor& input, const Tensor& RunningMean_, const Tensor& RunningVariance_);

    size_t batchsize;
    Tensor runningMean_;
    Tensor runningVariance_;
};

Tensor GpuBatchNormForwardTraining(const Tensor& x, const Tensor& bnScale_, const Tensor& bnBias_, 
   std::vector<Tensor>& cache, CudnnBatchNormHandle &cbnh);

Tensor GpuBatchNormForwardInference(const Tensor& x, const Tensor& bnScale_, const Tensor& bnBias_, const CudnnBatchNormHandle &cbnh);

std::vector<Tensor> GpuBatchNormBackward(const Tensor& dy,
  const std::vector<Tensor>& cache, const CudnnBatchNormHandle &cbnh);
     

}

