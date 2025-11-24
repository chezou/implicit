# Build _als extension
set(CYTHON_FLAGS --directive always_allow_keywords=True,binding=True,embedsignature=True,language_level=3)
cython_transpile(_als.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE _als_sources
)
python_add_library(_als MODULE ${_als_sources} WITH_SOABI)
install(TARGETS _als LIBRARY DESTINATION implicit/cpu)

# Build bpr extension
cython_transpile(bpr.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE bpr_sources
)
python_add_library(bpr MODULE ${bpr_sources} bpr.h WITH_SOABI)
install(TARGETS bpr LIBRARY DESTINATION implicit/cpu)

# Build topk extension
cython_transpile(topk.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE topk_sources
)
python_add_library(topk MODULE ${topk_sources} select.h WITH_SOABI)
install(TARGETS topk LIBRARY DESTINATION implicit/cpu)

# Build lmf extension
cython_transpile(lmf.pyx
    LANGUAGE CXX
    CYTHON_ARGS ${CYTHON_FLAGS}
    OUTPUT_VARIABLE lmf_sources
)
python_add_library(lmf MODULE ${lmf_sources} WITH_SOABI)
install(TARGETS lmf LIBRARY DESTINATION implicit/cpu)

if(OpenMP_CXX_FOUND)
    target_link_libraries(_als PRIVATE OpenMP::OpenMP_CXX)
    target_link_libraries(bpr PRIVATE OpenMP::OpenMP_CXX)
    target_link_libraries(topk PRIVATE OpenMP::OpenMP_CXX)
    target_link_libraries(lmf PRIVATE OpenMP::OpenMP_CXX)
endif()

FILE(GLOB cpu_python_files *.py)
install(FILES ${cpu_python_files} DESTINATION implicit/cpu)
