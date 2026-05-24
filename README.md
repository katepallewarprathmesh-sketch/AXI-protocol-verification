# AXI Protocol Verification

Complete ASIC-style design verification (DV) flow for **AXI4** using **SystemVerilog** and **UVM 1.2**.

## Project Structure

```
rtl/                    # DUT: axi_slave_mem (AXI4 SRAM slave)
tb/
  interfaces/           # axi_if
  pkg/                  # axi_types, axi_pkg
  agents/               # Master/slave UVM agents
  env/                  # Environment, scoreboard, coverage
  sequences/            # Directed and random sequences
  tests/                # UVM tests
  assertions/           # Protocol SVA
  tb_top.sv             # Top-level testbench
sim/                    # Makefile, compile.f, regression
docs/                   # Verification plan and configuration
```

## Quick Start

Requires **Questa/ModelSim** or **Synopsys VCS** with UVM 1.2.

```bash
cd sim
make compile
make run TEST=axi_smoke_test
make regression
```

Windows (PowerShell):

```powershell
cd sim
make compile
make run TEST=axi_smoke_test
.\regression.ps1
```

## Tests

| Test | Purpose |
|------|---------|
| `axi_smoke_test` | Basic write/read pairs |
| `axi_burst_test` | INCR burst write + readback |
| `axi_rand_test` | Randomized traffic with scoreboard check |

## DV Flow

1. **Compile** — RTL + UVM TB (`make compile`)
2. **Run** — Single test with seed (`make run TEST=... SEED=...`)
3. **Check** — UVM report summary, scoreboard, SVA
4. **Coverage** — Functional covergroups in `axi_coverage`
5. **Regression** — `make regression` or `regression.ps1`

See [docs/verification_plan.md](docs/verification_plan.md) for coverage goals and sign-off criteria.

## License

GNU GPL v3 — see [LICENSE](LICENSE).
