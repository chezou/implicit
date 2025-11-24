yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
yum install --setopt=obsoletes=0 -y \
    cuda-nvcc-12-6 \
    cuda-cudart-devel-12-6 \
    libcurand-devel-12-6 \
    libcublas-devel-12-6 \
    cuda-nvprof-12-6 \
    ninja-build
ln -s cuda-12.6 /usr/local/cuda
