from skbuild import setup


def exclude_non_implicit_cmake_files(cmake_manifest):
    """Filter cmake manifest to include only implicit package files.

    We seem to be picking up a bunch of unrelated files from thrust/spdlog/rmm.
    This filters the cmake manifest down to things from this package only.
    """
    return [f for f in cmake_manifest if "implicit" in f]


setup(
    cmake_process_manifest_hook=exclude_non_implicit_cmake_files,
)
