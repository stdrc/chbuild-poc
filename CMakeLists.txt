cmake_minimum_required(VERSION 3.14)
project(ChCore)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}
                      "${CMAKE_SOURCE_DIR}/scripts/cmake/Modules/")
include(ExternalProject)
include(ChCoreTools)

message(STATUS "CHCORE_ARCH: ${CHCORE_ARCH}")
message(STATUS "CHCORE_PLAT: ${CHCORE_PLAT}")
message(STATUS "CHCORE_VIRT: ${CHCORE_VIRT}")

macro(chcore_config _config_name _config_type _default _description)
    list(APPEND _cache_args
         -D${_config_name}:${_config_type}=${${_config_name}})
endmacro()
include(${CMAKE_SOURCE_DIR}/config.cmake)

ExternalProject_Add(
    kernel
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/kernel"
    CMAKE_ARGS
        -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/scripts/cmake/Toolchains/kernel.cmake
    CMAKE_CACHE_ARGS ${_cache_args}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E echo "Skipping install step.")

# add_subdirectory(kernel)
