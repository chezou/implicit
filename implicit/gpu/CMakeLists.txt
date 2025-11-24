if (UNIX)
find_package(CUDAToolkit)

if(CUDAToolkit_FOUND)
if (${CUDAToolkit_VERSION} VERSION_LESS "12.0.0")
    message("implicit requires CUDA 12.0 or greater for GPU acceleration - found CUDA ${CUDAToolkit_VERSION}")

elseif(DEFINED ENV{IMPLICIT_DISABLE_CUDA})
    # disable building the CUDA extension if the IMPLICIT_DISABLE_CUDA environment variable is set
    message("Disabling building the GPU extension since IMPLICIT_DISABLE_CUDA env var is set")

else()
    enable_language(CUDA)
    add_cython_target(_cuda CXX)

    # use rapids-cmake to install dependencies
    # Set the rapids-cmake version before including RAPIDS.cmake
    set(rapids-cmake-version 25.08)
    file(DOWNLOAD https://raw.githubusercontent.com/rapidsai/rapids-cmake/branch-25.08/RAPIDS.cmake
        ${CMAKE_BINARY_DIR}/RAPIDS.cmake)
    include(${CMAKE_BINARY_DIR}/RAPIDS.cmake)
    include(rapids-cmake)
    include(rapids-cpm)
    include(rapids-cuda)
    include(rapids-export)
    include(rapids-find)
    include(${rapids-cmake-dir}/cpm/package_override.cmake)

    rapids_cpm_init()
    rapids_cmake_build_type(Release)

    # thrust/cub have a cmake issue where the conda build fails
    # to find them, and needs these patches
    # https://github.com/benfred/cub/commit/97934d146b771fd2e8bda75f73349a4b3c9e10a7
    # https://github.com/benfred/thrust/commit/8452c764cc8d772314169e99811535f3a9108cfe
    # (note that cub is pulled in through thrust here - meaning we only need to override
    # the thrust version to pull it in)
    # Issue is tracked in https://github.com/NVIDIA/thrust/issues/1966
    file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/override.json
      [=[
        {
          "packages" : {
            "Thrust" : {
              "version" : "1.17.2",
              "git_url" : "https://github.com/benfred/thrust.git",
              "git_tag" : "no_cmake_find_root_path",
              "git_shallow" : true,
              "always_download" : true,
            }
          }
        }
    ]=])
    rapids_cpm_package_override(${CMAKE_CURRENT_BINARY_DIR}/override.json)

    # Disable shared library builds for RMM/RAFT to avoid runtime dependencies
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

    # get rmm (header-only usage with static linking)
    include(${rapids-cmake-dir}/cpm/rmm.cmake)
    rapids_cpm_rmm(BUILD_EXPORT_SET implicit-exports INSTALL_EXPORT_SET implicit-exports)

    # get rapids_logger to generate logger_macros.hpp
    include(${rapids-cmake-dir}/cpm/rapids_logger.cmake)
    rapids_cpm_rapids_logger()

    # get raft headers (header-only mode)
    rapids_cpm_find(raft 25.08
        GLOBAL_TARGETS      raft::raft
        BUILD_EXPORT_SET    implicit-exports
        INSTALL_EXPORT_SET  implicit-exports
        CPM_ARGS
            GIT_REPOSITORY  https://github.com/rapidsai/raft.git
            GIT_TAG         branch-25.08
            SOURCE_SUBDIR   cpp
            OPTIONS         "BUILD_TESTS OFF"
                           "BUILD_BENCH OFF"
                           "RAFT_COMPILE_LIBRARY OFF"
    )

    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --extended-lambda -Xfatbin=-compress-all --expt-relaxed-constexpr")

    add_library(_cuda MODULE ${_cuda}
        als.cu
        bpr.cu
        matrix.cu
        random.cu
        knn.cu
    )

    python_extension_module(_cuda)

    if(DEFINED ENV{IMPLICIT_CUDA_ARCH})
        message("using cuda arch $ENV{IMPLICIT_CUDA_ARCH}")
        set_target_properties(_cuda PROPERTIES CUDA_ARCHITECTURES $ENV{IMPLICIT_CUDA_ARCH})
    else()
        # CUDA 12.0+ supports architectures 70 (Volta) through 90a (Hopper)
        # Note: Dropping Pascal (60) support as CUDA 12 focuses on newer architectures
        if (${CUDAToolkit_VERSION} VERSION_LESS "12.6.0")
            set_target_properties(_cuda PROPERTIES CUDA_ARCHITECTURES "70;80;86;90")
        else()
            # CUDA 12.6+ includes full support for Hopper (90a)
            set_target_properties(_cuda PROPERTIES CUDA_ARCHITECTURES "70;80;86;90;90a")
        endif()
        get_target_property(CUDA_ARCH _cuda CUDA_ARCHITECTURES)
        message("using cuda architectures ${CUDA_ARCH} for cuda version ${CUDAToolkit_VERSION}")
    endif()
    target_link_libraries(_cuda CUDA::cublas CUDA::curand rmm::rmm raft::raft)

    install(TARGETS _cuda LIBRARY DESTINATION implicit/gpu)
endif()
endif()
endif()

FILE(GLOB gpu_python_files *.py)
install(FILES ${gpu_python_files} DESTINATION implicit/gpu)
