set(CMAKE_SYSTEM_NAME QNX)

set(arch gcc_ntox86_64_gpp)
set(ntoarch x86_64)

set(CMAKE_SIZEOF_VOID_P 8)
set(CMAKE_SYSTEM_PROCESSOR ${ntoarch})

set(CMAKE_C_COMPILER qcc)
set(CMAKE_C_COMPILER_TARGET ${arch})

set(CMAKE_CXX_COMPILER q++)
set(CMAKE_CXX_COMPILER_TARGET ${arch})
	
set(CMAKE_SYSROOT $ENV{QNX_TARGET})

# Need to explicit set _QNX_SOURCE for workaround in Google Protobuf setting CXX_EXTENSIONS to OFF
set(CMAKE_CXX_FLAGS_INIT "-D_QNX_SOURCE")