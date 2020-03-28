git clone --depth=1 https://github.com/aseprite/aseprite.git
cd aseprite
git checkout (git describe --tags (git rev-list --tags --max-count=1))

brew install ninja cmake

mkdir deps
cd deps

git clone "https://chromium.googlesource.com/chromium/tools/depot_tools.git"
set PATH $PWD/depot_tools $PATH

git clone --depth=1 -b aseprite-m71 https://github.com/aseprite/skia.git
cd skia
python ./tools/git-sync-deps
gn gen out/Release --args="is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_libjpeg_turbo=false skia_use_system_libpng=false skia_use_libwebp=false skia_use_system_zlib=false extra_cflags_cc=[\"-frtti\"]"
ninja -C out/Release skia
cd ../..

mkdir build
cd build
cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
  -DCMAKE_OSX_SYSROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk \
  -DLAF_OS_BACKEND=skia \
  -DSKIA_DIR=~/Software/aseprite/deps/skia \
  -DSKIA_OUT_DIR=~/Software/aseprite/deps/skia/out/Release \
  -G Ninja \
  ..
ninja aseprite

bin/aseprite
