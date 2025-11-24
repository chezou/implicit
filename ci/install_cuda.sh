yum-config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
yum install --setopt=obsoletes=0 -y \
    cuda-nvcc-12-9 \
    cuda-cudart-devel-12-9 \
    libcurand-devel-12-9 \
    libcublas-devel-12-9 \
    cuda-nvprof-12-9 \
    ninja-build
ln -s cuda-12.9 /usr/local/cuda
