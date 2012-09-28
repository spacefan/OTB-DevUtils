SET (CTEST_SOURCE_DIRECTORY "C:/Users/msavinau/dev/nightly/OTB-VS2011Beta-Debug/src")
SET (CTEST_BINARY_DIRECTORY "C:/Users/msavinau/dev/nightly/OTB-VS2011Beta-Debug/build")

SET (CTEST_CMAKE_GENERATOR  "Visual Studio 11" )
SET (CTEST_CMAKE_COMMAND "C:/Program Files/CMake 2.8/bin/cmake.exe")
SET (CTEST_SITE "PO9450.c-s.fr" )
SET (CTEST_BUILD_NAME "Win7-Visual2012Beta-Debug-Static")
SET (CTEST_BUILD_CONFIGURATION "Debug")
SET (CTEST_HG_COMMAND "C:/Program Files/TortoiseHg/hg.exe")
SET (CTEST_HG_UPDATE_OPTIONS "-C")

SET (OTB_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_CONFIGURATION_TYPES:STRING=Debug

BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=ON

# Applications
BUILD_APPLICATIONS:BOOL=ON
#OTB_WRAP_PYTHON:BOOL=ON
#OTB_WRAP_QT:BOOL=ON
#SWIG_EXECUTABLE:FILEPATH=C:/OSGeo4W/apps/swigwin/swig.exe
#PYTHON_EXECUTABLE:FILEPATH=C:/OSGeo4W/bin/python.exe
#PYTHON_INCLUDE_DIR:PATH=C:/OSGeo4W/apps/Python27/include
#PYTHON_LIBRARY:FILEPATH=C:/OSGeo4W/apps/Python27/libs/python27.lib

# Data
OTB_DATA_ROOT:STRING=C:/Users/msavinau/dev/nightly/data/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

")

#Remove build dir
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()