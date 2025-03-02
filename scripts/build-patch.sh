#!/usr/bin/env bash

cd libwebp || exit 0
git diff HEAD~1 HEAD > ../patches/libwebp.diff

cd ../libjpeg || exit 0
git diff HEAD~1 HEAD > ../patches/libjpeg.diff
