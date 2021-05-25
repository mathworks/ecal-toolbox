set(CMAKE_SYSTEM_NAME QNX)

set(arch gcc_ntox86_64)
set(ntoarch x86_64)

set(CMAKE_C_COMPILER qcc)
set(CMAKE_C_COMPILER_TARGET ${arch})

set(CMAKE_CXX_COMPILER q++)
set(CMAKE_CXX_COMPILER_TARGET ${arch})
	
set(CMAKE_SYSROOT $ENV{QNX_TARGET})

set(CMAKE_CXX_FLAGS_INIT "-D_QNX_SOURCE -stdlib=libstdc++")

# Explicitly link libsocket
set(CMAKE_EXE_LINKER_FLAGS_INIT "-lsocket")

# Set protoc properties for cross-compiling
add_executable(protoc IMPORTED)
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
	set_target_properties(protoc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../protoc-3.11.4-win64/bin/protoc.exe)
else()
	set_target_properties(protoc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/../protoc-3.11.4-linux-x86_64/bin/protoc)
endif()
set_target_properties(protoc PROPERTIES IMPORTED_GLOBAL TRUE)