#!/bin/bash
# Build a sparse HFS+ root image on Linux (requires hfsprogs and root).
# Usage: sudo tools/mkiosroot-linux.sh [OUT.img] [SIZE]
set -euo pipefail
repo=$(cd "$(dirname "$0")/.." && pwd)
out=${1:-$repo/out/iosroot.img}
size=${2:-28G}
command -v mkfs.hfsplus >/dev/null || { echo "install hfsprogs (mkfs.hfsplus)" >&2; exit 1; }
[[ $(id -u) -eq 0 ]] || { echo "run as root" >&2; exit 1; }
mkdir -p "$(dirname "$out")"
[[ ! -e $out ]] || { echo "refusing to overwrite existing image: $out" >&2; exit 1; }
truncate -s "$size" "$out"
if ! mkfs.hfsplus -s -J -v iOSRoot "$out"; then rm -f "$out"; exit 1; fi
echo "Created $out ($size). Mount with ownership enabled before root-finalize.sh."
