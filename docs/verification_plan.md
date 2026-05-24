# AXI4 Verification Plan

## Scope

| Parameter | Value |
|-----------|-------|
| Protocol | AXI4 full (not Lite) |
| Data width | 32 bits |
| Address width | 32 bits |
| ID width | 4 bits |
| DUT | `axi_slave_mem` — byte-addressable SRAM slave |
| Methodology | UVM 1.2, SystemVerilog |

## Verification Goals

1. Prove correct read/write data integrity via memory scoreboard
2. Exercise single-beat and incremental burst (INCR) transfers
3. Collect functional coverage on transaction type, length, size, burst, response
4. Check AXI handshake stability with SVA bind module

## Test Suite

| Test | Description | Pass Criteria |
|------|-------------|---------------|
| `axi_smoke_test` | 3 write/read pairs | 0 UVM errors/fatals, scoreboard clean |
| `axi_burst_test` | 5 INCR bursts (len 1–7) | Write then read-back match |
| `axi_rand_test` | 5–20 random write+read pairs | Randomized delays and lengths |

## Coverage Targets

- Transaction type (read/write): 100%
- Burst length bins: single, short burst, long burst
- Cross: type × length, burst × size
- Response OKAY on all happy-path tests

## Regression

```bash
cd sim
make regression        # Windows PowerShell
./regression.sh        # Linux
```

## Sign-off Checklist

- [ ] All regression tests PASS
- [ ] Functional coverage ≥ 90% (or waived with justification)
- [ ] No assertion failures
- [ ] No protocol SVA failures on master interface
