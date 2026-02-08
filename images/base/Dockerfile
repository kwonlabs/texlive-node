# syntax=docker/dockerfile:1

# ==============================================================================
# Dockerfile.base
# Builds: texlive-node
# Base: texlive/texlive:${TEXLIVE_VERSION} + Node.js
# ==============================================================================

# Allow TEXLIVE_VERSION to be passed (e.g., TL2024, latest)
ARG TEXLIVE_VERSION=latest
FROM texlive/texlive:${TEXLIVE_VERSION} AS base

# NODE_VERSION passed at build time (e.g., 20.20.0)
ARG NODE_VERSION=20.20.0

# Install Node.js
RUN apt-get update && apt-get install -y ca-certificates curl gnupg xz-utils && \
    ARCH= && dpkgArch="$(dpkg --print-architecture)" \
    && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
    esac \
    && echo "Downloading Node.js v${NODE_VERSION} for ${ARCH}..." \
    && curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz | tar -xJ -C /usr/local --strip-components=1 \
    && rm -rf /var/lib/apt/lists/*

# Verify installations
RUN node -v && npm -v && tex --version
