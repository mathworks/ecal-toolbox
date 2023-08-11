#!/bin/bash

# Change directory to the directory where this file is
cd "$(dirname "$0")"

# Define MATLAB version
MATLABVER=R2022b

echo Creating QNX environment variables... 
source /home/$USER/Documents/MATLAB/SupportPackages/$MATLABVER/toolbox/slrealtime/target/supportpackage/qnx710/qnxsdp-env.sh

echo Creating makefiles...
cmake "..\modules\ecal" -B"../_build_qnx" -DCMAKE_TOOLCHAIN_FILE="..\buildtools\qnx.cmake" -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../_install_qnx -DHAS_HDF5=OFF -DHAS_QT5=OFF -DHAS_CURL=ON -DBUILD_APPS=OFF -DECAL_THIRDPARTY_BUILD_PROTOBUF=ON -Dprotobuf_BUILD_PROTOC_BINARIES=OFF -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF -DECAL_THIRDPARTY_BUILD_CURL=OFF -DECAL_THIRDPARTY_BUILD_HDF5=OFF -Wno-dev

echo Building libraries...
cmake --build "../_build_qnx" --target install
