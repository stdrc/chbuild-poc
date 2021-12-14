cmake_minimum_required(VERSION 3.14)
project(ChCoreKernel)

message(STATUS "in kernel, CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "in kernel, CMAKE_CROSSCOMPILING: ${CMAKE_CROSSCOMPILING}")
message(STATUS "in kernel, CHCORE_ARCH: ${CHCORE_ARCH}")
message(STATUS "in kernel, CHCORE_PLAT: ${CHCORE_PLAT}")
message(STATUS "in kernel, CHCORE_VIRT: ${CHCORE_VIRT}")

add_library(hello STATIC hello.cpp)

if(CHCORE_VIRT)
    add_subdirectory(virt)
endif()
