set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_FLAGS "-k -j1")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_BUILD_NAME "Package-Linux-gcc-4.9.4-x86_64-${dashboard_git_branch}")

set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(dashboard_source_name "src/OTB/Packaging")
set(dashboard_binary_name "build/pkg-otb-stable")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/src/OTB/)

set(SUPERBUILD_BINARY_DIR ${CTEST_DASHBOARD_ROOT}/build/OTB-SuperBuild-stable)
set(SUPERBUILD_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/install/OTB-SuperBuild-stable)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
CMAKE_C_COMPILER:PATH=/usr/bin/gcc-4.9
CMAKE_CXX_COMPILER:PATH=/usr/bin/g++-4.9
BUILD_TESTING:BOOL=ON
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/src/SuperBuild-archives
SUPERBUILD_BINARY_DIR:PATH=${SUPERBUILD_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
GENERATE_PACKAGE:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
NAME_SUFFIX:STRING=-gcc4.9
")
endmacro()

macro(dashboard_hook_submit)
  dashboard_copy_packages()
endmacro() 

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
