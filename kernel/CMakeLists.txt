project(ChCoreKernel)

add_library(hello STATIC hello.cpp)

if(CHCORE_VIRTUALIZATION)
    add_subdirectory(virt)
endif()
