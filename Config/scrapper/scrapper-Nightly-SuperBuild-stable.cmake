# Client maintainer: guillaume.pasero@c-s.fr
#RK: DONT EVEN THINK OF ACTIVATING SYSTEM LIBRARY AND MAKING OTB PACKAGE!
# THIS WILL REQUIRE SPECIFIC PATCHING IN GENERATED CMAKE FILES
# SEE otb.git/Packaging/install_cmake_files.cmake

set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(dashboard_no_install 1)
include(${CTEST_SCRIPT_DIRECTORY}/scrapper_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_BUILD_NAME "CentOS6-64bits-SuperBuild-${dashboard_git_branch}")

set(dashboard_root_name "tests")
set(dashboard_source_name "OTB/src/SuperBuild")
set(dashboard_binary_name "OTB/superbuild_stable")

set(CTEST_INSTALL_DIRECTORY ${CTEST_DASHBOARD_ROOT}/OTB/install_sb_stable)

set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/OTB/src)

list(APPEND CTEST_TEST_ARGS 
  BUILD ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build
)
list(APPEND CTEST_NOTES_FILES
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/CMakeCache.txt
  ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/OTB/build/otbConfigure.h
)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
CMAKE_CXX_FLAGS:STRING='-std=c++11'
BUILD_TESTING:BOOL=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput
#disable to test update_pkg
QT4_SB_ENABLE_GTK:BOOL=OFF
WITH_REMOTE_MODULES:BOOL=ON
")
endmacro()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
