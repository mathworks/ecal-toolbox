#!/bin/bash

# Change directory to the directory where this file is
cd "$(dirname "$0")"

echo Creating makefiles...
cmake "..\modules\ecal" -B"../_build_linux" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../_install_linux -DHAS_HDF5=OFF -DHAS_QT5=OFF -DBUILD_APPS=OFF -DECAL_THIRDPARTY_BUILD_PROTOBUF=ON -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF -DECAL_THIRDPARTY_BUILD_CURL=OFF -DECAL_THIRDPARTY_BUILD_HDF5=OFF -Wno-dev

echo Building libraries...
cmake --build "../_build_linux" --target install
