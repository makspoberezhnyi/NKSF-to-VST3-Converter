cmake_minimum_required(VERSION 3.16)
project(nks-host LANGUAGES C CXX OBJC OBJCXX)

# Add VST3 SDK
set(SMTG_ADD_VST3_PLUGINS OFF CACHE BOOL "Disable VST3 plugins")
set(SMTG_ADD_VST3_HOSTING ON CACHE BOOL "Enable VST3 hosting")
set(SMTG_BUILD_EXAMPLES OFF CACHE BOOL "Disable VST3 examples")
set(SMTG_BUILD_VST3_INSPECTOR OFF CACHE BOOL "Disable VST3 inspector")
set(SMTG_BUILD_DOCS OFF CACHE BOOL "Disable VST3 docs")
set(SMTG_MAC_CODE_SIGN_IDENTITY "" CACHE STRING "Disable SDK code signing")

add_subdirectory(vst3sdk)

add_executable(nks-host 
    nks-host/main.cpp
    vst3sdk/public.sdk/source/vst/hosting/module.cpp
    vst3sdk/public.sdk/source/vst/hosting/module_mac.mm
    vst3sdk/public.sdk/source/vst/utility/stringconvert.cpp
)
target_include_directories(nks-host PRIVATE vst3sdk)

target_link_libraries(nks-host PRIVATE sdk_hosting)

if(APPLE)
    target_link_libraries(nks-host PRIVATE "-framework CoreFoundation" "-framework CoreServices" "-framework Cocoa")
endif()

set_target_properties(nks-host PROPERTIES CXX_STANDARD 17 CXX_STANDARD_REQUIRED ON)

# Add ARC for Objective-C++
target_compile_options(nks-host PRIVATE -fobjc-arc)
