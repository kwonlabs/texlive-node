# syntax=docker/dockerfile:1

# ==============================================================================
# Dockerfile.ko
# Builds: texlive-node-ko
# Base: texlive-node (local image from Dockerfile.base)
# ==============================================================================

# BASE_IMAGE_TAG passed at build time (e.g., TL2024-20.20.0)
ARG BASE_IMAGE_NAME=texlive-node
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS korean

# 1. Install System Fonts & Utilities
# Includes Nanum, Baekmuk, Un-fonts, and Noto families
RUN apt-get update && apt-get install -y \
    fonts-nanum \
    fonts-nanum-extra \
    fonts-unfonts-core \
    fonts-unfonts-extra \
    fonts-baekmuk \
    fonts-noto-cjk \
    fonts-noto-core \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Custom Fonts (Pretendard, Inter, NanumSquareNeo)
RUN mkdir -p /usr/share/fonts/truetype/pretendard && \
    curl -fSL https://github.com/orioncactus/pretendard/releases/download/v1.3.9/Pretendard-1.3.9.zip -o pretendard.zip && \
    unzip -q pretendard.zip -d /usr/share/fonts/truetype/pretendard && \
    rm pretendard.zip

RUN mkdir -p /usr/share/fonts/truetype/inter && \
    curl -fSL https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip -o inter.zip && \
    unzip -q inter.zip -d /usr/share/fonts/truetype/inter && \
    rm inter.zip

RUN mkdir -p /usr/share/fonts/truetype/nanumsquareneo && \
    curl -fSL https://github.com/moonspam/NanumSquareNeo/archive/refs/tags/v1.0.0.zip -o nanumsquareneo.zip && \
    unzip -q nanumsquareneo.zip -d /usr/share/fonts/truetype/nanumsquareneo && \
    rm nanumsquareneo.zip

# 3. Install TeX Packages (tlmgr)
# Core Korean support via collection-langkorean
RUN tlmgr update --self && \
    tlmgr install \
    collection-langkorean \
    baekmuk \
    unfonts-core \
    unfonts-extra && \
    tlmgr path add

# 4. Update Font Maps
RUN mktexlsr && \
    fc-cache -fv

# Set environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8
