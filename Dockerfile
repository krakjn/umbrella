FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        build-essential \
        cmake \
        golang-go \
        dpkg-dev \
    && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:/usr/local/bin:$PATH

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal \
    && curl -fsSL https://raw.githubusercontent.com/krakjn/bump/main/install/get_bump.sh | sh \
    && curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

WORKDIR /src
COPY . .

RUN chmod +x docker/entrypoint.sh \
        pkg/create.sh \
        api/pkg/create.sh api/pkg/generate.sh \
        cli/pkg/create.sh lib/pkg/create.sh net/pkg/create.sh \
    && just pack \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./dist/*.deb \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3333
ENTRYPOINT ["/src/docker/entrypoint.sh"]
CMD ["bash"]
