SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR i686)

if(MINGW OR CYGWIN OR WIN32)
    set(WHERE_CMD where)
    set(TOOLCHAIN_SUFFIX ".exe")
elseif(UNIX OR APPLE)
    set(WHERE_CMD which)
    set(TOOLCHAIN_SUFFIX "")
endif()

find_program(CMAKE_C_COMPILER  NAMES ${CROSS_COMPILE}gcc)
find_program(CMAKE_CXX_COMPILER NAMES ${CROSS_COMPILE}g++)
find_program(CMAKE_ASM_COMPILER NAMES ${CROSS_COMPILE}gcc)
find_program(CMAKE_LINKER NAMES ${CROSS_COMPILE}ld)
find_program(CMAKE_OBJCOPY ${CROSS_COMPILE}objcopy)
find_program(CMAKE_OBJDUMP ${CROSS_COMPILE}objdump)
find_program(SIZE ${CROSS_COMPILE}size)
find_program(CMAKE_READELF      ${CROSS_COMPILE}readelf)
find_program(CMAKE_MAKE_PROGRAM  NAMES ${CROSS_COMPILE}mingw32-make${TOOLCHAIN_SUFFIX})


# specify cross compilers and tools
# SET(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc${TOOLCHAIN_SUFFIX} CACHE INTERNAL "")
# SET(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++${TOOLCHAIN_SUFFIX} CACHE INTERNAL "")
# set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc${TOOLCHAIN_SUFFIX} CACHE INTERNAL "")
# set(CMAKE_LINKER ${CROSS_COMPILE}ld${TOOLCHAIN_SUFFIX} CACHE INTERNAL "")
# set(CMAKE_OBJCOPY ${CROSS_COMPILE}objcopy CACHE INTERNAL "")
# set(CMAKE_OBJDUMP ${CROSS_COMPILE}objdump CACHE INTERNAL "")
# set(SIZE ${CROSS_COMPILE}size CACHE INTERNAL "")
# set(CMAKE_MAKE_PROGRAM ${CROSS_COMPILE}make CACHE INTERNAL "")

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

set(CMAKE_FIND_ROOT_PATH ${CROSS_COMPILE}gcc)
# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)