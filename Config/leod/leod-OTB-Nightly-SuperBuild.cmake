set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-SuperBuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_SOURCE_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/nightly/OTB-Release/src/SuperBuild")
set(CTEST_BINARY_DIRECTORY  "${CTEST_DASHBOARD_ROOT}/nightly/OTB-SuperBuild/build")
set(CTEST_INSTALL_DIRECTORY "${CTEST_DASHBOARD_ROOT}/nightly/OTB-SuperBuild/install")

set(CTEST_GI_COMMAND          "/opt/local/bin/git")

set(CTEST_USE_LAUNCHERS TRUE)

set(GDAL_EXTRA_OPT "--with-gif=/opt/local")

set(OTB_INITIAL_CACHE "
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DATA_ROOT:PATH=$ENV{HOME}/Data/OTB-Data
DOWNLOAD_LOCATION:PATH=$ENV{HOME}/Data/SuperBuild-archives
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_USE_QT4:BOOL=OFF
USE_SYSTEM_QT4:BOOL=OFF
USE_SYSTEM_SQLITE:BOOL=OFF
USE_SYSTEM_JPEG:BOOL=OFF
USE_SYSTEM_TIFF:BOOL=OFF
USE_SYSTEM_GEOTIFF:BOOL=OFF
OTB_USE_CURL:BOOL=OFF
ENABLE_OTB_LARGE_INPUTS:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=$ENV{HOME}/Data/OTB-LargeInput
GDAL_SB_EXTRA_OPTIONS:STRING=${GDAL_EXTRA_OPT}
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
BUILD_TESTING:BOOL=ON
")

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/lib)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/bin)
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY}/include)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")

ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")

# before testing, set the DYLD_LIBRARY_PATH
set(ENV{DYLD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib)

ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}/OTB/build" ${CTEST_TEST_ARGS})

set(CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
${CTEST_BINARY_DIRECTORY}/OTB/build/CMakeCache.txt
${CTEST_BINARY_DIRECTORY}/OTB/build/otbConfigure.h
)

ctest_submit ()


