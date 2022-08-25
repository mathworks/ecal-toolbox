@echo off

rem Change directory to the directory where this file is
cd /D "%~dp0"

echo Creating QNX environment variables... 
call %ALLUSERSPROFILE%"\MATLAB\SupportPackages\R2022a\toolbox\slrealtime\target\supportpackage\qnx710\qnxsdp-env.bat"
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo Creating makefiles for eCAL...
cmake "..\modules\ecal" -B"../_build_qnx" -DCMAKE_TOOLCHAIN_FILE="..\buildtools\qnx.cmake" -G"Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../_install_qnx -DHAS_HDF5=OFF -DHAS_QT5=OFF -DHAS_CURL=ON -DBUILD_APPS=OFF -DECAL_THIRDPARTY_BUILD_PROTOBUF=ON -Dprotobuf_BUILD_PROTOC_BINARIES=OFF -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF -DECAL_THIRDPARTY_BUILD_CURL=OFF -DECAL_THIRDPARTY_BUILD_HDF5=OFF -Wno-dev
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

echo Building libraries...
cmake --build ../_build_qnx --target install
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
