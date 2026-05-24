# AXI Protocol Verification

Multi-flow AXI4 verification: **Verilator** (fast), **cocotb** (debug), **SymbiYosys** (formal), **UVM** (signoff).

## Tool matrix

| Task | Tool | Command |
|------|------|---------|
| Fast regression | Verilator + cocotb + cocotbext-axi | `cd sim && make fast-regression` |
| Protocol debug | cocotb + GTKWave | `cd sim && make cocotb-waves` |
| Formal checks | SymbiYosys | `cd formal && make` |
| UVM regression | Questa / VCS | `cd sim && make uvm-regression` |

Details: [docs/dv_flow.md](docs/dv_flow.md)

## Project structure

```
rtl/axi_slave_mem.sv          # DUT
tb/                           # UVM env, SVA, cocotb top
cocotb/                       # Python tests (cocotbext-axi)
formal/                       # SymbiYosys (.sby)
sim/                          # Makefiles, waves, scripts
docs/                         # Plans and flow guide
```

## Quick start

### 1. Fast regression (recommended first)

```bash
pip install -r requirements.txt
cd sim
make fast-regression
```

Windows:

```powershell
pip install -r requirements.txt
cd sim
.\run_cocotb.ps1 -Regression
```

### 2. Protocol debug with waves

```bash
cd sim
make cocotb-waves MODULE=test_smoke
gtkwave sim_build/dump.fst waves.gtkw
```

### 3. Formal

```bash
cd formal
make
```

### 4. UVM (Questa / VCS)

```bash
cd sim
make compile
make uvm-run TEST=axi_smoke_test
make uvm-regression
```

## Cocotb tests

| Module | Description |
|--------|-------------|
| `test_smoke` | Single write/read pairs |
| `test_burst` | Multi-byte INCR bursts |
| `test_random` | Random address/data stress |

## UVM tests

| Test | Description |
|------|-------------|
| `axi_smoke_test` | Write/read pairs + scoreboard |
| `axi_burst_test` | INCR bursts |
| `axi_rand_test` | Random traffic |

## License

GNU GPL v3 — see [LICENSE](LICENSE).
