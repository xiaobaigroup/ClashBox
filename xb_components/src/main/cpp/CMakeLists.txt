cmake_minimum_required(VERSION 3.10)
project(xb_compontents)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/utils)

set(LOG_LIB
libace_napi.z.so
libhilog_ndk.z.so
native_window_manager
ability_access_control
ability_base_want
ability_runtime)

add_library(
xb_components SHARED
init.cpp
utils/napi_utils.cpp
)
target_link_libraries(xb_components PUBLIC ${LOG_LIB} )
