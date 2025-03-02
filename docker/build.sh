#!/usr/bin/env bash

dists=('es' 'lib' 'dist')

cd zlib || exit 0

emconfigure ./configure --static
emmake make CFLAGS="-fPIC" AR=emar ARFLAGS=rc

cd ../libjpeg || exit 0

echo "Update libjpeg dynamically"
git apply --check ../patches/libjpeg.diff
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

cd ../libpng || exit 0

echo "Build libpng"
emcmake cmake -DPNG_SHARED=OFF -DPNG_TESTS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DZLIB_LIBRARY=/img2webp/zlib/libz.a -DZLIB_INCLUDE_DIR=/img2webp/zlib .
emmake make clean && emmake make CFLAGS="-fPIC"

cd ../libwebp || exit 0

echo "Update libwebp dynamically"
git apply --check ../patches/libwebp.diff
result2=$?
if [ $result2 -eq 0 ]; then
  git apply ../patches/libwebp.diff
else
  echo "Failed to update libwebp dynamically"
  exit 1
fi

echo "Configure the project using CMake"
cd webp_js || exit 0
emcmake cmake -DEMSCRIPTEN_FORCE_COMPILERS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DWEBP_BUILD_WEBP_JS=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_GIF2WEBP=OFF -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF -DWEBP_USE_THREAD=OFF -DZLIB_LIBRARY=/img2webp/zlib/libz.a -DZLIB_INCLUDE_DIR=/img2webp/zlib -DJPEG_LIBRARY=/img2webp/libjpeg/libjpeg.a -DJPEG_INCLUDE_DIR=/img2webp/libjpeg -DPNG_LIBRARY=/img2webp/libpng/libpng16.a -DPNG_PNG_INCLUDE_DIR=/img2webp/libpng ../

echo "Build wasm files"
emmake make

echo "Copy js files to img2webp/src"
find . -maxdepth 1 \( -type f -name 'img2webp.js' -not -name '*.worker.js' \) -print0 | xargs -0 -I {} cp -a {} ../../src

cd ../..
pnpm fetch --frozen-lockfile && pnpm install --frozen-lockfile && pnpm build:rollup

cd libwebp/webp_js || exit 0

echo "Copy wasm files to img2webp/lib, img2webp/dist and img2webp/es"
for dist in "${dists[@]}"
do
  find . -maxdepth 1 \( -type f -name 'img2webp.wasm' -o -regex '.*\.worker\.js$' \) -print0 | xargs -0 -I {} cp -a {} "../../$dist"
done

echo "Clean libwebp/webp_js"
cd ..
rm -rf webp_js && git stash -qu && git stash drop -q
