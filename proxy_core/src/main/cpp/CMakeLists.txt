# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(myNpmLib)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

add_library(flclash SHARED IMPORTED)
set_target_properties(flclash PROPERTIES IMPORTED_LOCATION ${NATIVERENDER_ROOT_PATH}/libflclash.so IMPORTED_NO_SONAME TRUE)

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(proxy_core SHARED napi_init.cpp)
target_link_libraries(proxy_core PUBLIC libace_napi.z.so hilog_ndk.z flclash)
