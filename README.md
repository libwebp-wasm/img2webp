# Img2Webp

## Introduction

The process of converting the [libwebp](https://github.com/webmproject/libwebp) project from C/C++ to WASM is achieved using the [Emscripten](https://emscripten.org) compiler. The general workflow is as follows:

![Emscripten Compilation Flow](https://user-images.githubusercontent.com/8049878/189127696-bba0af00-d58d-42b3-b09e-9e15eb255731.png "Emscripten Compilation Flow")

## Usage

### Installation

#### Toolchain

This includes installing [emsdk](https://github.com/emscripten-core/emsdk), [cmake](https://cmake.org), and [pnpm](https://pnpm.io). For specific installation methods, refer to the [Emscripten official documentation](https://emscripten.org/docs/getting_started/downloads.html), [pnpm official documentation](https://pnpm.io/installation), and [installing cmake](https://gist.github.com/fscm/29fd23093221cf4d96ccfaac5a1a5c90).

#### submodule

```bash
git submodule update --init --recursive --remote --rebase
```

### Build

#### MacOS

If you are using zsh, it is recommended to install [the dotenv plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv) to enable features like setting environment variables if a .env file is present in the current directory.

```bash
pnpm build:mac
```

#### Docker

##### Build Image

```bash
docker build -f ./docker/Dockerfile -t libwebp-wasm/img2webp:latest .
```

##### Run Image

```bash
docker run --rm  -v $(pwd)/dist:/img2webp/dist -v $(pwd)/es:/img2webp/es -v $(pwd)/lib:/img2webp/lib libwebp-wasm/img2webp:latest
```

#### Other

Note: The modification of upstream submodule project code is currently done by running the git apply command. Sometimes you need to commit your own changes in the submodule directory and manually generate the patch.

```bash
pnpm build:patch
```

## Example

- [Img to Webp](https://libwebp-wasm.github.io/img2webp/example/)

## License

MIT
