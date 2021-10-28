#!/bin/bash

# Change directory to the directory where this file is
cd "$(dirname "$0")"

# Define MATLAB version
MATLABVER=R2021a

# Add MATLAB library path to Linux LD path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/$MATLABVER/bin/glnxa64

echo Creating makefiles...
cmake "..\modules\ecal" -B"../_build_linux" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../_install_linux -DHAS_HDF5=OFF -DHAS_QT5=OFF -DBUILD_APPS=OFF -DProtobuf_INCLUDE_DIR=/usr/local/MATLAB/$MATLABVER/toolbox/shared/robotics/externalDependency/libprotobuf/include -DProtobuf_LIBRARIES=/usr/local/MATLAB/$MATLABVER/bin/glnxa64/ -DProtobuf_PROTOC_EXECUTABLE=/usr/local/MATLAB/$MATLABVER/bin/glnxa64/protoc -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF -Wno-dev

echo Building libraries...
cmake --build "../_build_linux" --target install
