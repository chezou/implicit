cmake_minimum_required(VERSION 3.18.0)

project(${SKBUILD_PROJECT_NAME} LANGUAGES C CXX)

enable_testing()

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)
find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)
find_package(OpenMP)

include_directories(.)
set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
add_subdirectory(implicit)
