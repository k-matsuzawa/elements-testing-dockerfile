FROM node:12.14.1-buster-slim

# install dependencies
RUN apt update && apt install -y \
    gpg \
    wget \
    build-essential \
    python \
    git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
ENV GPG_KEY_SERVER hkp://keyserver.ubuntu.com:80
# setup bitcoin
ARG BITCOIN_VERSION=0.18.1
ENV BITCOIN_TARBALL bitcoin-${BITCOIN_VERSION}-x86_64-linux-gnu.tar.gz
ENV BITCOIN_URL https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/$BITCOIN_TARBALL
ENV BITCOIN_ASC_URL https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/SHA256SUMS.asc
ENV BITCOIN_PGP_KEY 01EA5486DE18A882D4C2684590C8019E36C2E964
RUN wget -qO ${BITCOIN_TARBALL} ${BITCOIN_URL} \
    && gpg --keyserver ${GPG_KEY_SERVER} --recv-keys ${BITCOIN_PGP_KEY} \
    && wget -qO SHA256SUMS.asc ${BITCOIN_ASC_URL} \
    && gpg --verify SHA256SUMS.asc \
    && sha256sum --ignore-missing --check SHA256SUMS.asc \
    && tar -xzvf ${BITCOIN_TARBALL} --directory=/opt/ \
    && ln -sfn /opt/bitcoin-${BITCOIN_VERSION}/bin/* /usr/bin \
    && rm -f ${BITCOIN_TARBALL} SHA256SUMS.asc

# setup elements
ARG ELEMENTS_VERSION=0.18.1.3
ENV ELEMENTS_TARBALL elements-${ELEMENTS_VERSION}-x86_64-linux-gnu.tar.gz
ENV ELEMENTS_URL https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/$ELEMENTS_TARBALL
ENV ELEMENTS_ASC_URL https://github.com/ElementsProject/elements/releases/download/elements-${ELEMENTS_VERSION}/SHA256SUMS.asc
ENV ELEMENTS_PGP_KEY 17A985E3CF2C185F6FA87E95F3F68E2D86A48FDB
RUN wget -qO ${ELEMENTS_TARBALL} ${ELEMENTS_URL} \
  && gpg --keyserver ${GPG_KEY_SERVER} --recv-keys ${ELEMENTS_PGP_KEY} \
  && wget -qO SHA256SUMS.asc ${ELEMENTS_ASC_URL} \
  && gpg --verify SHA256SUMS.asc \
  && sha256sum --ignore-missing --check SHA256SUMS.asc \
  && tar -xzvf ${ELEMENTS_TARBALL} --directory=/opt/ \
  && ln -sfn /opt/elements-${ELEMENTS_VERSION}/bin/* /usr/bin \
  && rm -f ${ELEMENTS_TARBALL} SHA256SUMS.asc

# setup cmake
ENV CMAKE_VERSION 3.16.2
RUN wget -qO cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz \
  && gpg --keyserver ${GPG_KEY_SERVER} --recv-keys 2D2CEF1034921684 \
  && wget -qO cmake-${CMAKE_VERSION}-SHA-256.txt https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-SHA-256.txt \
  && wget -qO cmake-${CMAKE_VERSION}-SHA-256.txt.asc https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-SHA-256.txt.asc \
  && gpg --verify cmake-${CMAKE_VERSION}-SHA-256.txt.asc \
  && sha256sum --ignore-missing --check cmake-${CMAKE_VERSION}-SHA-256.txt \
  && tar -xzvf cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz --directory=/opt/ \
  && rm -f cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz cmake-${CMAKE_VERSION}-SHA-256.txt cmake-${CMAKE_VERSION}-SHA-256.txt.asc \
  && ln -sfn /opt/cmake-${CMAKE_VERSION}-Linux-x86_64/bin/* /usr/bin
# ENV PATH /opt/cmake-${CMAKE_VERSION}-Linux-x86_64/bin:${PATH}

WORKDIR /root

# TODO: set ENTRYPOINT