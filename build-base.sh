#!/bin/bash
set -e

# Configuration
TEXLIVE_VERSION=${TEXLIVE_VERSION:-latest}
IMAGE_NAME=${IMAGE_NAME:-texlive-node}

# Function to check if version $1 >= $2 (Node.js)
version_ge() {
    awk -v v1="$1" -v v2="$2" 'BEGIN {
        split(v1, a, "."); split(v2, b, ".");
        for (i=1; i<=3; i++) {
            if (a[i]+0 > b[i]+0) exit 0;
            if (a[i]+0 < b[i]+0) exit 1;
        }
        exit 0;
    }'
}

# Function to check if TeXLive version $1 >= $2
texlive_ge() {
    # If using "latest", we assume it satisfies requirements
    if [ "$1" = "latest" ]; then return 0; fi

    # Extract digits only (e.g., TL2024-historic -> 2024)
    local v1=$(echo "$1" | sed 's/[^0-9]//g')
    local v2=$(echo "$2" | sed 's/[^0-9]//g')
    
    if [ -z "$v1" ] || [ -z "$v2" ]; then return 1; fi

    if [ "$v1" -ge "$v2" ]; then
        return 0
    else
        return 1
    fi
}

# Argument Parsing
FORCE_BUILD=false
REQUIRED_NODE=""
REQUIRED_TL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --force)
      FORCE_BUILD=true
      shift
      ;;
    -*)
      echo "⚠️  Unknown option: $1" >&2
      shift
      ;;
    *)
      if [ -z "$REQUIRED_NODE" ]; then
        REQUIRED_NODE="$1"
      elif [ -z "$REQUIRED_TL" ]; then
        REQUIRED_TL="$1"
      fi
      shift
      ;;
  esac
done

# Function to get versions to build
get_versions() {
  local input_node="$1"
  local results=()

  # If manual version provided
  if [ -n "$input_node" ]; then
    if [ "$FORCE_BUILD" = true ]; then
      results+=("$input_node")
    else
      # Check against constraints
      local major=$(echo "$input_node" | cut -d. -f1)
      local config_ver=$(grep "^$major\." node-versions.txt | head -n1 || true)
      
      local should=false
      if [ -n "$config_ver" ]; then
        if version_ge "$input_node" "$config_ver"; then should=true; fi
      else
        # Major not in config. Check if it's a newer Major version
        MAX_MAJOR=$(cut -d. -f1 node-versions.txt | sort -rn | head -n1)
        if [ "$major" -gt "$MAX_MAJOR" ]; then
          should=true
        fi
      fi

      if [ "$should" = true ]; then
        results+=("$input_node")
      else
        echo "ℹ️  Req: $input_node < Config: $config_ver (Skipping)" >&2
      fi
    fi
  else
    # Use all from node-versions.txt
    while IFS= read -r line; do
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      results+=("$line")
    done < node-versions.txt
  fi
  echo "${results[@]}"
}

# 1. Determine Node.js versions to build
NODE_VERSIONS=($(get_versions "$REQUIRED_NODE"))

if [ "${#NODE_VERSIONS[@]}" -eq 0 ] && [ "$FORCE_BUILD" = false ]; then
  echo "⚠️  No Node.js versions to build based on criteria. Use --force to override." >&2
  exit 0
fi

# 2. Check TeXLive Version (if provided or default)
TEXLIVE_VERSION="${REQUIRED_TL:-latest}"

if [ -f texlive-versions.txt ]; then
  REQUIRED_TL=$(cat texlive-versions.txt | grep -v '^#' | head -n 1 || true)
fi

if [ -n "$REQUIRED_TL" ] && [ "$FORCE_BUILD" = false ]; then
  if ! texlive_ge "$TEXLIVE_VERSION" "$REQUIRED_TL"; then
    echo "⚠️  Skipping build: TeXLive $TEXLIVE_VERSION < Required $REQUIRED_TL (Use --force to override)" >&2
    exit 0
  fi
fi

echo "🚀 Starting build for Node: ${NODE_VERSIONS[*]} | TeXLive: $TEXLIVE_VERSION"

echo "=================================================================="
echo "Build Configuration (Base Image)"
echo " - TeXLive Version: ${TEXLIVE_VERSION}"
echo " - Node Versions:   ${NODE_VERSIONS[*]}"
echo "=================================================================="

for node_ver in "${NODE_VERSIONS[@]}"; do
    BASE_TAG="${TEXLIVE_VERSION}-${node_ver}"
    
    echo ""
    echo ">> Building Base Image: ${IMAGE_NAME}:${BASE_TAG} (Multi-arch via buildx)"
    
    docker buildx build \
        -f images/base/Dockerfile \
        --platform linux/amd64,linux/arm64 \
        --build-arg TEXLIVE_VERSION=${TEXLIVE_VERSION} \
        --build-arg NODE_VERSION=${node_ver} \
        -t ${IMAGE_NAME}:${BASE_TAG} .
    
    echo "   ✅ Base Built: ${IMAGE_NAME}:${BASE_TAG}"
done

echo ""
echo "=================================================================="
echo "🎉 Base images build completed successfully!"
