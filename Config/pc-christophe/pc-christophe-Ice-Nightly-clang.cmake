#set (ENV{DISPLAY} ":0.0")
# Avoid non-ascii characters in tool output.
#set(ENV{LC_ALL} C)

set (CTEST_BUILD_CONFIGURATION "Release")

set (DASHBOARD_DIR "$ENV{HOME}/OTB")

set (CTEST_SOURCE_DIRECTORY "${DASHBOARD_DIR}/trunk/Ice")
set (CTEST_BINARY_DIRECTORY "${DASHBOARD_DIR}/bin/Ice-clang-Nightly")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set (CTEST_SITE "pc-christophe.cst.cnes.fr" )
set (CTEST_BUILD_NAME "Fedora20-64bits-clang-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_HG_COMMAND "/usr/bin/hg")
set (CTEST_HG_UPDATE_OPTIONS "-C")

set(INSTALLROOT "/home/otbtesting/install")
set (ICE_INSTALL_PREFIX "${INSTALLROOT}/Ice-clang-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_ICE_APPLICATION:BOOL=ON

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-gnu

GLFW_INCLUDE_DIR:PATH=/usr/include/GLFW
ITK_DIR:PATH=${INSTALLROOT}/ITK_trunk-Release/lib/cmake/ITK-4.6
OTB_DIR:PATH=${INSTALLROOT}/OTB-clang-ThirdPartyTrunk/lib/otb/

CMAKE_INSTALL_PREFIX:PATH=${ICE_INSTALL_PREFIX}

")

set (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})
ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})

ctest_start (Nightly)
ctest_update (SOURCE "${CTEST_SOURCE_DIRECTORY}")
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files (${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
