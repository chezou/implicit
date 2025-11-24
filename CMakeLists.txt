cmake_minimum_required(VERSION 3.18.0)

project(${SKBUILD_PROJECT_NAME} LANGUAGES C CXX)

enable_testing()

# On Windows, we need full Development (includes python3xx.lib)
# On other platforms, Development.Module is sufficient
if(WIN32)
    find_package(Python REQUIRED COMPONENTS Interpreter Development)
    message(STATUS "Python_FOUND: ${Python_FOUND}")
    message(STATUS "Python_VERSION: ${Python_VERSION}")
    message(STATUS "Python_EXECUTABLE: ${Python_EXECUTABLE}")
    message(STATUS "Python_LIBRARIES: ${Python_LIBRARIES}")
    message(STATUS "Python_LIBRARY_DIRS: ${Python_LIBRARY_DIRS}")
    message(STATUS "Python_INCLUDE_DIRS: ${Python_INCLUDE_DIRS}")
else()
    find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)
endif()

execute_process(
    COMMAND "${Python_EXECUTABLE}" -c "import os, skbuild; print(os.path.join(os.path.dirname(skbuild.__file__), 'resources', 'cmake'))"
    OUTPUT_VARIABLE SKBUILD_CMAKE_DIR_RAW
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE SKBUILD_CMAKE_DIR_RESULT
)

if(SKBUILD_CMAKE_DIR_RESULT EQUAL 0)
    # Convert to CMake path to handle Windows backslashes correctly
    file(TO_CMAKE_PATH "${SKBUILD_CMAKE_DIR_RAW}" SKBUILD_CMAKE_DIR)
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
