FROM emscripten/emsdk

LABEL maintainer="liuliang@w3ctech.com"

ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN apt update && apt upgrade -y \
    && apt install -y --no-install-recommends \
    wget \
    tar \
    ca-certificates \
    xmlto \
    imagemagick \
    build-essential
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.4/cmake-3.30.4-linux-x86_64.tar.gz && \
tar -zxvf cmake-3.30.4-linux-x86_64.tar.gz --strip-components=1 -C /usr/local && rm cmake-3.30.4-linux-x86_64.tar.gz

RUN npm install -g corepack@latest
RUN corepack enable && corepack install --global pnpm@10.4.1
WORKDIR /img2webp

COPY . ./
RUN chmod +x ./docker/build.sh && apt clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash", "./docker/build.sh"]
