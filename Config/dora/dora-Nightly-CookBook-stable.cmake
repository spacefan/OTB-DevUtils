set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_FLAGS "-k" )
include(${CTEST_SCRIPT_DIRECTORY}/dora_common.cmake)

set(OTB_PROJECT OTB)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
unset(OTB_PROJECT)
set(CTEST_BUILD_NAME "Ubuntu16.04-64bits-CookBook-${dashboard_git_branch}")

set(CTEST_DASHBOARD_TRACK LatestRelease)

set(dashboard_otb_source "nightly/OTB-Release/src")
set(dashboard_otb_binary "nightly/OTB-Release/build-stable")
set(dashboard_otb_install "nightly/OTB-Release/install-stable")

set(dashboard_root_name "tests")
set(dashboard_source_name "${dashboard_otb_source}/Documentation/Cookbook")
set(dashboard_binary_name "nightly/CookBook/stable")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/${dashboard_otb_source})

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CTEST_USE_LAUNCHERS:BOOL=OFF

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
OTB_DATA_PATHS:STRING=$ENV{HOME}/Data/OTB-Data/Examples::$ENV{HOME}/Data/OTB-Data/Input

CMAKE_PREFIX_PATH:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_otb_install}
")
endmacro()

#set(dashboard_no_test 1)
#set(dashboard_no_submit 1)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
