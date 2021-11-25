chcore_config(CHCORE_ARCH STRING "aarch64" "Target architecture")
chcore_config(CHCORE_PLAT STRING "raspi3" "Target hardware platform")

include(kernel/config.cmake)
