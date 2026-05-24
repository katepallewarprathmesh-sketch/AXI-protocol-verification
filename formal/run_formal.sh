#!/usr/bin/env bash
# SymbiYosys formal runner
set -euo pipefail
cd "$(dirname "$0")"

TASK="${1:-all}"

if ! command -v sby >/dev/null 2>&1; then
  echo "sby not found. Install OSS CAD Suite and add bin/ to PATH."
  exit 1
fi

case "$TASK" in
  all)        make all ;;
  handshake)  make handshake ;;
  slave)      make slave ;;
  *) echo "Usage: $0 [all|handshake|slave]"; exit 1 ;;
esac
