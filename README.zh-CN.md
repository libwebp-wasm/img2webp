# Img2Webp

## 介绍

通过使用 [Emscripten](https://emscripten.org) 编译器的方式，从而实现 [libwebp](https://github.com/webmproject/libwebp) 项目从 C/C++ 到 WASM 的转变。大致的流程如下：

![Emscripten 编译流程](https://user-images.githubusercontent.com/8049878/189127696-bba0af00-d58d-42b3-b09e-9e15eb255731.png "Emscripten 编译流程")

## 使用

### 安装

#### 工具链

主要包括安装 [emsdk](https://github.com/emscripten-core/emsdk)、[cmake](https://cmake.org) 以及 [pnpm](https://pnpm.io)，具体的安装方式可以参考 [Emscripten 官方文档](https://emscripten.org/docs/getting_started/downloads.html)、[pnpm 官方文档](https://pnpm.io/installation)以及[安装 cmake](https://juejin.cn/post/6844904024433491982#heading-6)。

#### submodule

```bash
git submodule update --init --recursive --remote --rebase
```

### 构建

#### MacOS

在使用 zsh 的情况下，推荐安装 [dotenv 插件](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/dotenv)，这样就可以实现一些功能，比如在当前目录存在 .env 文件的情况下设置环境变量。

```bash
pnpm build:mac
```

#### Docker

##### 构建镜像

```bash
docker build -f ./docker/Dockerfile -t libwebp-wasm/img2webp:latest .
```

##### 运行镜像

```bash
docker run --rm  -v $(pwd)/dist:/img2webp/dist -v $(pwd)/es:/img2webp/es -v $(pwd)/lib:/img2webp/lib libwebp-wasm/img2webp:latest
```

#### 其它

注意：现在是通过运行 `git apply` 命令的方式，实现修改上游 submodule 项目代码的目的。所以，有时候需要在 submodule 目录下提交自己的 commit，然后手动执行生成 patch 的操作。

```bash
pnpm build:patch
```

## 例子

- [Img 转 Webp](https://libwebp-wasm.github.io/img2webp/example/)

## License

MIT
