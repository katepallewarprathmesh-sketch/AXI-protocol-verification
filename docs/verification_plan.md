# AXI4 Verification Plan

**Protocol reference:** [arm_axi_references.md](arm_axi_references.md) — official Arm IHI 0022 / IHI 0051 links and signal glossary.

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
make fast-regression   # Verilator + cocotb
make uvm-regression    # Questa/VCS UVM
```

## Tool flows

| Stage | Tool | Location |
|-------|------|----------|
| Fast regression | Verilator + cocotb | `cocotb/`, `sim/Makefile.verilator` |
| Protocol debug | cocotb + GTKWave | `sim/waves.gtkw` |
| Formal | SymbiYosys | `formal/*.sby` |
| UVM signoff | Questa/VCS | `tb/tests/` |

See [dv_flow.md](dv_flow.md).

## Sign-off Checklist

- [ ] Cocotb fast regression PASS (`make fast-regression`)
- [ ] SymbiYosys formal PASS (`cd formal && make`)
- [ ] UVM regression PASS (`make uvm-regression`)
- [ ] Functional coverage ≥ 90% on Questa (or waived)
- [ ] No SVA failures in UVM sim
