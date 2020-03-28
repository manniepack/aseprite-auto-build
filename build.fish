#!/usr/bin/env fish

# Ensure build folder exists
if not test -d ./build
   mkdir ./build
end
cd ./build

# Ensure Skia exists
if test -d ./skia
   rm -r ./skia
end
curl -Lo skia.zip "https://github.com/aseprite/skia/releases/download/m81-b607b32047/Skia-macOS-Release-x64.zip"
unzip skia.zip -d skia
rm skia.zip

# Ensure Aseprite src exists
if not test -d ./aseprite
    git clone --recursive https://github.com/aseprite/aseprite.git

    cd ./aseprite
    git checkout (git describe --tags (git rev-list --tags --max-count=1))
    git submodule update --init --recursive
else
    cd ./aseprite
    git pull
end

# Configure and build Aseprite
if not test -d ./build
    mkdir ./build
else
    rm -r ./build/*
end
cd ./build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
  -DCMAKE_OSX_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk \
  -DLAF_OS_BACKEND=skia \
  -DSKIA_DIR=(realpath (string join / (pwd) "../../skia")) \
  -DSKIA_LIBRARY_DIR=(realpath (string join / (pwd) "../../skia/out/Release-x64")) \
  -G Ninja \
  ..
ninja aseprite
