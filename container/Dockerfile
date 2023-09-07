FROM debian:bullseye

RUN dpkg --add-architecture arm64 && \
    apt-get update && \
    apt-get full-upgrade --no-install-recommends -y \
        build-essential crossbuild-essential-arm64 git \
        debhelper devscripts lintian dh-exec \
        libc6:arm64 libstdc++6:arm64 \
        python-wheel-common python3-pkg-resources python3-distutils python3-setuptools && \
    adduser --gecos runner --disabled-password runner && \
    rm -rf /var/lib/apt/lists/*
