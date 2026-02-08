# texlive-node

이 프로젝트는 [texlive/texlive](https://hub.docker.com/r/texlive/texlive) 공식 이미지를 기반으로, **Node.js 런타임**과 **최신 한글 폰트**가 포함된 최적화된 Docker 이미지를 제공합니다. 스마트 버전 관리 기능을 통해 효율적인 빌드 및 배포를 지원합니다.

## 📦 이미지 종류 (Images)

### 1. 기본 이미지 (Base Image)
TeXLive의 기본 기능과 Node.js 환경이 통합된 이미지입니다.
- **이미지 태그 패턴**: `${DOCKER_ORG}/texlive-node:<texlive-version>-<node-version>`
- **핵심 전략**:
  - **베이스 소스**: 공식 `texlive/texlive:latest`를 기본으로 사용합니다. 필요시 `TL2024-historic` 등 특정 연도 버전 고정이 가능합니다.
  - **런타임**: Node.js **v24.13.0+** 최신 환경을 지원합니다.

### 2. 한국어 지원 이미지 (Korean Support Image)
기본 이미지 위에 한국어 렌더링을 위한 필수 패키지와 최신 폰트가 추가되었습니다.
- **태그 접미사**: `-ko`
- **추가 설치 항목**:
  1. **TeX 패키지**: `kotex`, `cjk-ko`, `xetexko`, `nanumfonts` 등
  2. **시스템 폰트**: 나눔, Noto Sans CJK, 백묵, 은 글꼴 등
  3. **커스텀 폰트**:
     - **[나눔스퀘어 네오 (NanumSquare Neo)](https://github.com/moonspam/NanumSquareNeo)**
     - [Pretendard](https://github.com/orioncactus/pretendard)
     - [Inter](https://github.com/rsms/inter)

## 🚀 빌드 및 CI 전략

이 프로젝트는 독립적인 빌드와 유연성을 극대화하기 위해 **분리된 CI(Decoupled CI)** 구조를 사용합니다.

### 1. 독립적인 워크플로우
- **[Base 이미지 빌드](.github/workflows/build-base.yml)**: 
  - Node.js 패치 버전을 자동 감지하여 기본 TeXLive + Node 환경을 구축합니다.
  - `${DOCKER_ORG}/texlive-node:<tl>-<node>` 태그로 푸시합니다.
- **[한국어 이미지 빌드](.github/workflows/build-ko.yml)**:
  - 한국어 폰트 및 패키지 강화 작업을 수행합니다.
  - **의존성 자동 감지**: 빌드 시작 전 Docker Hub에서 필요한 Base 이미지가 있는지 먼저 확인합니다. 이를 통해 KO 이미지만 나중에 따로 빌드하거나 업데이트하는 것이 가능합니다.

### 2. TeXLive 버전 관리
- **기본값 (Default)**: 별도의 설정이 없으면 공식 `latest` 태그를 사용합니다.
- **버전 고정**: 특정 연도 버전이 필요한 경우 `texlive-versions.txt`에 명시하면 됩니다 (예: `TL2024-historic`).
- **스마트 빌드**: 주간 자동 빌드 시 설정 파일에 기술된 (혹은 `latest`) 버전을 기준으로 매트릭스를 구성합니다.

### 3. 수동 빌드 및 로컬 환경
- GitHub Actions UI에서 원하는 버전 조합을 직접 입력하여 빌드할 수 있습니다.
- 로컬 개발 시 `./build-base.sh` 등에 `--force` 플래그를 사용하여 버전 제약 조건을 무시할 수 있습니다.

