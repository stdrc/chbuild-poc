project(ChCoreKernel)

add_library(hello STATIC hello.cpp)

if(CHCORE_VIRT)
    add_subdirectory(virt)
endif()
