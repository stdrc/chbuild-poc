#[[
Load cache variables from project's `.config` file.

This script is intended to be used as -C option of
cmake command.
#]]

if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.config)
    message(FATAL_ERROR "There is no `.config` file")
endif()

file(READ ${CMAKE_CURRENT_SOURCE_DIR}/.config _config_str)
string(REGEX REPLACE "\n" ";" _config_lines "${_config_str}")

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
