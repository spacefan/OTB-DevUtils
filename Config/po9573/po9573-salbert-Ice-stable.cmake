set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (dashboard_model Experimental)
string(TOLOWER ${dashboard_model} lcdashboard_model)

set (CTEST_BUILD_CONFIGURATION "Debug")
# set (CTEST_BUILD_CONFIGURATION "Release")

set( USER_CONFIG "-stable" )

#set (OTB_DASHBOARD_DIR "$ENV{HOME}/dev/install/Monteverdi2Dashboard/nightly/Monteverdi2-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/dev/source/Ice${USER_CONFIG}")
set (CTEST_BINARY_DIRECTORY "$ENV{HOME}/dev/build/Ice${USER_CONFIG}")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )
set (CTEST_SITE "po9573.c-s.fr" )
set (CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-$ENV{USER}${USER_CONFIG}")
# set (CTEST_GIT_COMMAND "/usr/bin/git")
# set (CTEST_GIT_UPDATE_OPTIONS "")
set (CTEST_USE_LAUNCHERS ON)

set (ICE_INSTALL_PREFIX "$ENV{HOME}/dev/install/Ice${USER_CONFIG}")

set (ICE_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
# CTEST_USE_LAUNCHERS:BOOL=ON

CMAKE_C_FLAGS:STRING=-Wall -Wextra
CMAKE_CXX_FLAGS:STRING=-Wall -Wextra

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

ITK_DIR:PATH=$ENV{HOME}/dev/install/ITK-4-debug/lib/cmake/ITK-4.8

OTB_DIR:PATH=$ENV{HOME}/dev/install/OTB${USER_CONFIG}/lib/cmake/OTB-5.2

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}

GLFW_INCLUDE_DIR=$ENV{HOME}/local/include
GLFW_LIBRARY=$ENV{HOME}/local/lib/libglfw.so

BUILD_ICE_APPLICATION:BOOL=ON
")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Experimental)
# ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${ICE_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
#ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 6)
ctest_submit ()
