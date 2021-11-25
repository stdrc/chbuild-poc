#[[
Load cache variables from `.config` and `config.cmake`.

This script is intended to be used as -C option of
cmake command.
#]]

if(EXISTS ${CMAKE_SOURCE_DIR}/.config)
    # Read in config file
    file(READ ${CMAKE_SOURCE_DIR}/.config _config_str)
    string(REGEX REPLACE "\n" ";" _config_lines "${_config_str}")

    # Set config cache variables
    foreach(_line ${_config_lines})
        if(${_line} MATCHES "^//" OR ${_line} MATCHES "^#")
            continue()
        endif()
        string(REGEX MATCHALL "^([^:=]+):([^:=]+)=(.*)$" _config "${_line}")
        if("${_config}" STREQUAL "")
            message(FATAL_ERROR "Invalid line in `.config`: ${_line}")
        endif()
        set(${CMAKE_MATCH_1}
            ${CMAKE_MATCH_3}
            CACHE ${CMAKE_MATCH_2} "" FORCE)
    endforeach()
else()
    message(WARNING "There is no `.config` file")
endif()

# Check if there exists `chcore_config` macro, which will be used in
# `config.cmake`
if(NOT COMMAND chcore_config)
    message(FATAL_ERROR "Don't directly use `LoadConfig.cmake`")
endif()

# Include the top-level config definition file
include(${CMAKE_SOURCE_DIR}/config.cmake)

# Hide unrelavant builtin cache variables
mark_as_advanced(CMAKE_INSTALL_PREFIX)
