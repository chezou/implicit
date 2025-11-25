# Build _nearest_neighbours extension
set(CYTHON_FLAGS --directive always_allow_keywords=True,binding=True,embedsignature=True,language_level=3)
cython_transpile(_nearest_neighbours.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE _nearest_neighbours_sources
)
python_add_library(_nearest_neighbours MODULE ${_nearest_neighbours_sources} WITH_SOABI)
install(TARGETS _nearest_neighbours LIBRARY DESTINATION implicit)

# Build evaluation extension
cython_transpile(evaluation.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE evaluation_sources
)
python_add_library(evaluation MODULE ${evaluation_sources} WITH_SOABI)
install(TARGETS evaluation LIBRARY DESTINATION implicit)

if(OpenMP_CXX_FOUND)
    target_link_libraries(_nearest_neighbours PRIVATE OpenMP::OpenMP_CXX)
    target_link_libraries(evaluation PRIVATE OpenMP::OpenMP_CXX)
endif()

add_subdirectory(cpu)
add_subdirectory(gpu)

FILE(GLOB python_files *.py)
install(FILES ${python_files} DESTINATION implicit)
