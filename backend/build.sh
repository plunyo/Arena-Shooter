#!/usr/bin/env bash
set -euo pipefail

# Usage: ./build.sh windows|linux amd64|arm64|arm [optimize] [run]

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
    echo "Usage: $0 windows|linux amd64|arm64|arm [optimize] [run]"
    exit 1
fi

OS_ARG="$1"
ARCH_ARG="$2"
OPTIMIZE_ARG="${3:-false}"
RUN_ARG="${4:-false}"

case "$OS_ARG" in
    windows) GOOS="windows" ;;
    linux)   GOOS="linux" ;;
    *) echo "Invalid OS. Use 'windows' or 'linux'." ; exit 1 ;;
esac

case "$ARCH_ARG" in
    amd64)  GOARCH="amd64" ;;
    arm64)  GOARCH="arm64" ;;
    arm)    GOARCH="arm" ;;
    *) echo "Invalid arch. Use 'amd64', 'arm64', or 'arm'." ; exit 1 ;;
esac

GOARM="${GOARM:-7}"

BUILD_DIR="build"
mkdir -p "$BUILD_DIR"

OUTPUT="${BUILD_DIR}/build-${GOOS}-${GOARCH}"
if [ "$GOOS" = "windows" ]; then
    OUTPUT="${OUTPUT}.exe"
fi

echo "Building $OUTPUT for $GOOS-$GOARCH (optimize=${OPTIMIZE_ARG})..."

export GOOS
export GOARCH
export GOARM

# detect if we have cgo-dependent packages (like go-enet)
CGO_ENABLED=0
if grep -qr "github.com/codecat/go-enet" .; then
    echo "Detected go-enet, enabling CGO..."
    CGO_ENABLED=1
fi
export CGO_ENABLED

# set ldflags for optimization
if [ "$OPTIMIZE_ARG" = "true" ]; then
    LDFLAGS='-s -w'
    TRIMPATH='-trimpath'
else
    LDFLAGS=''
    TRIMPATH=''
fi

# build
if [ -n "$LDFLAGS" ]; then
    go build -ldflags="$LDFLAGS" $TRIMPATH -o "$OUTPUT" .
else
    go build -o "$OUTPUT" .
fi

echo "go build finished: $(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT") bytes"

# optional UPX compression
if [ "$OPTIMIZE_ARG" = "true" ]; then
    if command -v upx >/dev/null 2>&1; then
        echo "Compressing with upx..."
        upx --best --ultra-brute "$OUTPUT" || echo "UPX failed; leaving binary uncompressed."
        echo "After UPX: $(stat -c%s "$OUTPUT" 2>/dev/null || stat -f%z "$OUTPUT") bytes"
    else
        echo "UPX not found. Install upx to pack the binary: https://upx.github.io/"
    fi
fi

echo "Build complete: $OUTPUT"

# run immediately if requested and on host OS
if [ "$RUN_ARG" = "true" ]; then
    if [ "$GOOS" = "$(uname | tr '[:upper:]' '[:lower:]')" ]; then
        echo "Running $OUTPUT..."
        "$OUTPUT"
    else
        echo "Skipping run: built OS ($GOOS) does not match host OS."
    fi
fi
