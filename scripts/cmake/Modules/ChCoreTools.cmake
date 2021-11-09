macro(chcore_config _config_name _config_type _default _description)
    set(${_config_name}
        ${_default}
        CACHE ${_config_type} ${_description})
endmacro()
