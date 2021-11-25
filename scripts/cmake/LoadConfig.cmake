#[[
Load cache variables from project's `.config` file.

This script is intended to be used as -C option of
cmake command.
#]]

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/.config)
    message(FATAL_ERROR "There is no `.config` file")
endif()

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

# Hook the `chcore_config` macro to set cache variable descriptions
macro(chcore_config _config_name _config_type _default _description)
    if(DEFINED ${_config_name})
        set(${_config_name}
            ${${_config_name}}
            CACHE ${_config_type} ${_description} FORCE)
    endif()
endmacro()

# Include the top-level config definition file
include(${CMAKE_SOURCE_DIR}/Config.cmake)

# Hide unrelavant builtin cache variables
mark_as_advanced(CMAKE_INSTALL_PREFIX)
