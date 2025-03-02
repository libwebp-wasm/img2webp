#!/usr/bin/env bash

echo "Install dependencies using Homebrew"
brew install libpng jpeg zlib

echo "Install dependencies using pnpm"
pnpm install

echo "Initialize and update submodules"
git submodule update --init --recursive --remote --rebase

dists=('es' 'lib' 'dist')

echo "Clean es, lib, src, and dist"
rm -rf src && git stash -qu && git stash drop -q

for dist in "${dists[@]}"
do
  rm -rf "$dist" && mkdir "$dist"
done

cd zlib || exit 0

# Configure zlib with static flag
emconfigure ./configure --static
# Build zlib with PIC flags
emmake make CFLAGS="-fPIC" AR=emar ARFLAGS=rc

echo "Move libz.a to the zlib/xxx/lib directory"
zlibLibPath="$(brew --cellar zlib)/$(brew list --versions zlib | tr ' ' '\n' | tail -1)/lib"
if [ -f "${zlibLibPath}/libz.a.bak" ]; then
  rm -f "${zlibLibPath}/libz.a"
else
  mv "${zlibLibPath}/libz.a" "${zlibLibPath}/libz.a.bak"
fi
mv libz.a "${zlibLibPath}/libz.a"

echo "Clean up zlib build artifacts"
emmake make clean && git stash -qu && git stash drop -q

cd ../libjpeg || exit 0

echo "Update libjpeg dynamically"
git apply --quiet --check ../patches/libjpeg.diff
result1=$?
if [ $result1 -eq 0 ]; then
  git apply ../patches/libjpeg.diff
else
  echo "Failed to update libjpeg dynamically"
  exit 1
fi

echo "Build libjpeg"
emcmake cmake -DBUILD_STATIC=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON .
emmake make clean && emmake make CFLAGS="-fPIC"

echo "Move libjpeg.a to jpeg/xxx/lib directory"
jpegLibPath="$(brew --cellar jpeg)/$(brew list --versions jpeg | tr ' ' '\n' | tail -1)/lib"
if [ -f "${jpegLibPath}/libjpeg.a.bak" ]; then
  rm -f "${jpegLibPath}/libjpeg.a"
else
  mv "${jpegLibPath}/libjpeg.a" "${jpegLibPath}/libjpeg.a.bak"
fi
mv libjpeg.a "${jpegLibPath}/libjpeg.a"

echo "Clean libjpeg build artifacts"
emmake make clean && git stash -qu && git stash drop -q

cd ../libpng || exit 0

echo "Build libpng"
# Add -DCMAKE_POSITION_INDEPENDENT_CODE=ON to enable PIC for libpng
emcmake cmake -DPNG_SHARED=OFF -DPNG_TESTS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DZLIB_LIBRARY="$(brew --prefix zlib)/lib/libz.a" -DZLIB_INCLUDE_DIR="$(brew --prefix zlib)/include" .
# Add CFLAGS="-fPIC" to ensure PIC is used
emmake make clean && emmake make CFLAGS="-fPIC"

echo "Move libpng.a to libpng/xxx/lib directory"
libpngLibPath="$(brew --cellar libpng)/$(brew list --versions libpng | tr ' ' '\n' | tail -1)/lib"
if [ -f "${libpngLibPath}/libpng16.a.bak" ]; then
  rm -f "${libpngLibPath}/libpng16.a"
else
  mv "${libpngLibPath}/libpng16.a" "${libpngLibPath}/libpng16.a.bak"
fi
mv libpng16.a "${libpngLibPath}/libpng16.a"

echo "Clean libpng build artifacts"
emmake make clean && git stash -qu && git stash drop -q

cd ../libwebp || exit 0

echo "Update libwebp dynamically"
git apply --quiet --check ../patches/libwebp.diff
result2=$?
if [ $result2 -eq 0 ]; then
  git apply ../patches/libwebp.diff
else
  echo "Failed to update libwebp dynamically"
  exit 1
fi

echo "Configure the project using CMake"
cd webp_js || exit 0
emcmake cmake -DEMSCRIPTEN_FORCE_COMPILERS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DWEBP_BUILD_WEBP_JS=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_GIF2WEBP=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_USE_THREAD=OFF -DZLIB_LIBRARY="$(brew --prefix zlib)/lib/libz.a" -DZLIB_INCLUDE_DIR="$(brew --prefix zlib)/include" -DJPEG_LIBRARY="$(brew --prefix jpeg)/lib/libjpeg.a" -DJPEG_INCLUDE_DIR="$(brew --prefix jpeg)/include" -DPNG_LIBRARY="$(brew --prefix libpng)/lib/libpng16.a" -DPNG_PNG_INCLUDE_DIR="$(brew --prefix libpng)/include" ../

echo "Build wasm files"
emmake make

echo "Copy wasm files to img2webp/lib, img2webp/dist and img2webp/es and copy js files to img2webp/src"
find . -maxdepth 1 \( -type f -name 'img2webp.js' -not -name '*.worker.js' \) -print0 | xargs -0 -I {} cp -a {} ../../src

for dist in "${dists[@]}"
do
  find . -maxdepth 1 \( -type f -name 'img2webp.wasm' -o -regex '.*\.worker\.js$' \) -print0 | xargs -0 -I {} cp -a {} "../../$dist"
done

echo "Clean libwebp/webp_js"
cd ..
rm -rf webp_js && git stash -qu && git stash drop -q
