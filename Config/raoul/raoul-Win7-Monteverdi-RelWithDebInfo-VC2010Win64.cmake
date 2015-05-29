SET (dashboard_model Nightly)
SET (CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")

SET (OTB_PROJECT Monteverdi) # OTB / Monteverdi / Monteverdi2
SET (OTB_ARCH amd64) # x86 / amd64

SET (CTEST_BUILD_CONFIGURATION RelWithDebInfo)

SET (CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/src/${OTB_PROJECT}")
SET (CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/build/${OTB_PROJECT}-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}")

SET (CTEST_CMAKE_GENERATOR  "NMake Makefiles")
# defining a CTEST_BUILD_COMMAND prevent to build custom targets
#SET (CTEST_BUILD_COMMAND  "jom install")
SET (CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "raoul.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}-Static")
SET (CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/${OTB_PROJECT}-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION})

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

OTB_USE_CPACK:BOOL=ON

#GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W64/include
#GDAL_LIBRARY:FILEPATH=C:/OSGeo4W64/lib/gdal_i.lib

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OTB-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/cmake/OTB-5.0

OpenCV_DIR:PATH=$ENV{OSGEO4W_ROOT}/share/OpenCV

")

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(${dashboard_model})
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET PACKAGE)
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET INSTALL)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit ()
