# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT OTB) # OTB / Monteverdi / Monteverdi2
set(OTB_ARCH amd64) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION Release)
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
set(CTEST_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION})

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

CMAKE_PREFIX_PATH:PATH=${OSGEO4W_ROOT}

SWIG_EXECUTABLE:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/swigwin-3.0.5/swig.exe

PYTHON_EXECUTABLE:FILEPATH=${OSGEO4W_ROOT}/bin/python.exe
PYTHON_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/apps/Python27/include
PYTHON_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/apps/Python27/libs/python27.lib

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4:BOOL=ON

OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=OFF
OTB_USE_GLUT:BOOL=OFF


Boost_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include/boost-1_56
Boost_LIBRARY_DIR:PATH=${OSGEO4W_ROOT}/lib

ITK_DIR:PATH=${OSGEO4W_ROOT}/lib/cmake/ITK-4.7

OpenCV_DIR:PATH=${OSGEO4W_ROOT}/share/OpenCV

LIBSVM_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include
LIBSVM_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/libsvm.lib

LIBKML_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include
LIBKML_BASE_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmlbase.lib;${OSGEO4W_ROOT}/lib/expat.lib
LIBKML_CONVENIENCE_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmlconvenience.lib
LIBKML_DOM_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmldom.lib
LIBKML_ENGINE_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmlengine.lib
LIBKML_MINIZIP_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/minizip.lib;${OSGEO4W_ROOT}/lib/zdll.lib
LIBKML_REGIONATOR_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmlregionator.lib
LIBKML_XSD_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/kmlxsd.lib

MUPARSERX_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include
MUPARSERX_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/muparserx.lib

MUPARSER_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include
MUPARSER_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/muparser.lib

TINYXML_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/include
TINYXML_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/lib/tinyxml.lib
    ")
endmacro()

#remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
