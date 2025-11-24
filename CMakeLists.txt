cmake_minimum_required(VERSION 3.21.0)

project(${SKBUILD_PROJECT_NAME} LANGUAGES C CXX)

enable_testing()

# Use modern CMake Python support
find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)

# Find Cython using cython-cmake
find_package(Cython REQUIRED)
include(UseCython)

find_package(OpenMP)

include_directories(.)
set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
add_subdirectory(implicit)
