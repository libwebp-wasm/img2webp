#!/usr/bin/env bash

pnpm build:example

dist=build/example

mkdir -p $dist
cp -r example/dist/* $dist
