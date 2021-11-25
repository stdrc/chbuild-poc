cmake_minimum_required(VERSION 3.15)
project(ChCore)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
                      "${CMAKE_SOURCE_DIR}/scripts/cmake/Modules/")
include(ChCoreTools)

include(Config.cmake)

message(STATUS "CHCORE_ARCH: ${CHCORE_ARCH}")
message(STATUS "CHCORE_PLAT: ${CHCORE_PLAT}")
message(STATUS "CHCORE_VIRT: ${CHCORE_VIRT}")

add_subdirectory(kernel)
