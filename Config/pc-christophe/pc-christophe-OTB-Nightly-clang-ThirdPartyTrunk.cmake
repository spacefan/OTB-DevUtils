# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-clang-ThirdPartyTrunk-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_DASHBOARD_TRACK Experimental)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(CTEST_USE_LAUNCHERS 1)

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")
set (OTB_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual
CMAKE_INSTALL_PREFIX=${OTB_INSTALL_PREFIX}

##external GDAL
GDAL_CONFIG:FILEPATH=${INSTALLROOT}/gdal/trunk/bin/gdal-config
GDAL_INCLUDE_DIR:PATH=${INSTALLROOT}/gdal/trunk/include/
GDAL_LIBRARY:FILEPATH=${INSTALLROOT}/gdal/trunk/lib/libgdal.so

##external ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.7

##external OpenCV
OpenCV_DIR=${INSTALLROOT}/opencv/trunk/share/OpenCV/

##external OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/trunk/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/trunk/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/include

#external openjpeg
OpenJPEG_DIR:PATH=${INSTALLROOT}/openjpeg/trunk/lib/openjpeg-2.1

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

#OTB_USE_XXX
OTB_USE_6S=ON
OTB_USE_CURL=ON
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_OPENJPEG=ON
OTB_USE_QT4=ON
OTB_USE_SIFTFAST=ON
 ")
endmacro()

#mxe_*.log are not from the yesterday's build.
#This is because OTB-Nightly-clang build is submitted before MXE
list(APPEND CTEST_NOTES_FILES
  "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt"
  "${CTEST_DASHBOARD_ROOT}/install/gdal/trunk/gdal_svn_info.txt"
  "${CTEST_DASHBOARD_ROOT}/build/ossim/trunk/ossim_svn_info.txt"
  "${CTEST_DASHBOARD_ROOT}/build/opencv/trunk/opencv_git_show.txt" )

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)