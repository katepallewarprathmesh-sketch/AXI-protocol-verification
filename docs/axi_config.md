# AXI Configuration

## Interface

File: `tb/interfaces/axi_if.sv`

Parameterized by `ADDR_WIDTH`, `DATA_WIDTH`, `ID_WIDTH`. Provides `master`, `slave`, and `monitor` modports plus clocking blocks.

## DUT

File: `rtl/axi_slave_mem.sv`

- 4 KB memory (`MEM_BYTES = 4096`)
- Supports INCR and WRAP burst addressing (WRAP lightly exercised)
- Optional ready/valid delay parameters for stall testing

## UVM Hierarchy

```
uvm_test_top
└── env
    ├── master_agent (ACTIVE)
    │   ├── driver
    │   ├── monitor → scoreboard, coverage
    │   └── sequencer
    └── slave_agent (PASSIVE monitor)
```

## Running Simulations

Requires Questa/ModelSim or VCS with UVM 1.2.

```bash
cd sim
make compile
make run TEST=axi_smoke_test
make wave TEST=axi_smoke_test   # GUI waves
```

Environment variables (optional):

- `UVM_HOME` — path to UVM source if not using simulator-bundled UVM
- `SIMULATOR=questa|vcs`
