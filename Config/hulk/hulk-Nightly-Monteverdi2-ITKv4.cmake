SET (ENV{DISPLAY} ":0.0")

SET (CTEST_SOURCE_DIRECTORY  "$ENV{HOME}/Dashboard/src/Monteverdi2")
SET (CTEST_BINARY_DIRECTORY  "$ENV{HOME}/Dashboard/build/Monteverdi2_ITKv4")
SET (CTEST_INSTALL_DIRECTORY "$ENV{HOME}/Dashboard/install/Monteverdi2_ITKv4")

SET( CTEST_CMAKE_GENERATOR     "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND       "cmake" )
SET (CTEST_BUILD_COMMAND       "/usr/bin/make -j10 -i -k install" )
SET (CTEST_SITE                "hulk.c-s.fr" )
SET (CTEST_BUILD_NAME          "Ubuntu10.04-64bits-ITKv4-Release")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND          "/usr/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS   "-C")
SET (CTEST_USE_LAUNCHERS ON)

SET (OTB_INITIAL_CACHE "

BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_INSTALL_PREFIX:STRING=${CTEST_INSTALL_DIRECTORY}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_TESTING:BOOL=ON

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/home/otbval/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data

OTB_DIR:STRING=$ENV{HOME}/Dashboard/build/OTB-ITKv4-RelWithDebInfo
ITK_DIR:PATH=$ENV{HOME}/Dashboard/build/ITKv4-upstream-RelWithDebInfo
OpenCV_DIR:PATH=/home/otbval/tools/install/opencv-2.4.5/share/OpenCV
")

SET( OTB_PULL_RESULT_FILE "${CTEST_BINARY_DIRECTORY}/pull_result.txt" )

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${OTB_PULL_RESULT_FILE}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_DIRECTORY})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_DIRECTORY})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

execute_process( COMMAND ${CTEST_HG_COMMAND} pull http://hg.orfeo-toolbox.org/Monteverdi2
                 WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
                 OUTPUT_VARIABLE   OTB_PULL_RESULT
                 ERROR_VARIABLE    OTB_PULL_RESULT )
file(WRITE ${OTB_PULL_RESULT_FILE} ${OTB_PULL_RESULT} )

ctest_start(Experimental)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${OTB_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()

