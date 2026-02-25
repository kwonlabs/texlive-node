# texlive-node

Optimized multi-architecture (`amd64`, `arm64`) Docker image combining TeXLive, Node.js, and Korean fonts with smart version management.

## 📦 Images

### Docker Hub
Pull the image directly:
```bash
docker pull makye/texlive-node:TL2024-historic-24.13.0-ko
```

### 1. Base Image
Integrates TeXLive's core functionality with a Node.js environment.
- **Image Tag Pattern**: `${DOCKER_ORG}/texlive-node:<texlive-version>-<node-version>`
- **Core Strategy**: 
  - **Base Source**: Defaults to `texlive/texlive:latest`. Custom year versions (e.g., `TL2024-historic`) can be pinned if needed.
  - **Runtime**: Node.js **Latest Stable LTS** (v24.13.0+).

### 2. Korean Support Image
An extended image adding essential packages and fonts for Korean rendering.
- **Tag Suffix**: `-ko`
- **Additions**:
  1.  **TeX Packages (via `tlmgr`)**: `kotex`, `cjk-ko`, `xetexko`, etc.
  2.  **System Fonts**: Nanum, Noto Sans CJK, Baekmuk, UnFonts.
  3.  **Custom Fonts**:
      - [NanumSquare Neo](https://github.com/moonspam/NanumSquareNeo)
      - [Pretendard](https://github.com/orioncactus/pretendard)
      - [Inter](https://github.com/rsms/inter)

## 🚀 Build & CI Strategy

The project uses a unified **CI Architecture** to efficiently build and publish multi-architecture Docker images (`linux/amd64`, `linux/arm64`).

### 1. Unified Workflow
- **[Build & Publish Images](.github/workflows/build.yml)**: 
  - Automatically discovers the single latest Node.js LTS release.
  - Checks if the images are already built on Docker Hub to skip unnecessary builds.
  - Builds the foundational environment (Base image) via Docker Buildx/QEMU and pushes it.
  - Sequentially builds the Korean image relying on the newly published Base image and pushes it.
  - Leverages GitHub Actions caching (`type=gha`) for fast, optimized rebuilds.

### 2. TeXLive Versioning (Smart Discovery)
- **Default**: The system defaults to the `latest` official TeXLive image.
- **Stable Pinning**: If you need a specific year, add it to `texlive-versions.txt` (e.g., `TL2024-historic`).
- **Discovery**: In automated weekly runs, the system targets the single latest LTS version and the configured TeXLive version (or `latest` if empty).

### 3. Manual Build (Workflow Dispatch)
- Manually trigger any version combination via the GitHub Actions UI.
- Local developers can use the `--force` flag with `build-base.sh` or `build-ko.sh` to bypass baseline checks.

