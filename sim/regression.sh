#!/usr/bin/env bash
# AXI UVM regression (Linux/macOS + Questa)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p logs

TESTS=(axi_smoke_test axi_burst_test axi_rand_test)
PASS=0
FAIL=0

for t in "${TESTS[@]}"; do
  echo "========== Running $t =========="
  if make run TEST="$t" SEED=1 2>&1 | tee "logs/regression_${t}.log"; then
    if grep -qE "UVM_ERROR\s*:\s*0" "logs/regression_${t}.log" && \
       grep -qE "UVM_FATAL\s*:\s*0" "logs/regression_${t}.log"; then
      echo "PASS: $t"
      PASS=$((PASS + 1))
    else
      echo "FAIL: $t"
      FAIL=$((FAIL + 1))
    fi
  else
    echo "FAIL: $t (sim error)"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "========== Regression Summary =========="
echo "Passed: $PASS  Failed: $FAIL"
[[ $FAIL -eq 0 ]]
