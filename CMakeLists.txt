cmake_minimum_required(VERSION 3.18.0)

project(${SKBUILD_PROJECT_NAME} LANGUAGES C CXX)

enable_testing()

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)

execute_process(
    COMMAND "${Python_EXECUTABLE}" -c "import os, skbuild; print(os.path.join(os.path.dirname(skbuild.__file__), 'resources', 'cmake'))"
    OUTPUT_VARIABLE SKBUILD_CMAKE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE SKBUILD_CMAKE_DIR_RESULT
)

if(SKBUILD_CMAKE_DIR_RESULT EQUAL 0)
    message(STATUS "Using scikit-build CMake modules from: ${SKBUILD_CMAKE_DIR}")
    list(APPEND CMAKE_MODULE_PATH "${SKBUILD_CMAKE_DIR}")
else()
    message(FATAL_ERROR "Failed to find scikit-build CMake modules")
endif()

find_package(PythonExtensions REQUIRED)
find_package(Cython REQUIRED)
find_package(OpenMP)

include_directories(.)
set (CMAKE_CXX_STANDARD 17)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
add_subdirectory(implicit)
