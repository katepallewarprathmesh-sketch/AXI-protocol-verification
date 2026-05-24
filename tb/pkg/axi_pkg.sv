package axi_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import axi_types::*;

  `include "axi_transaction.sv"

  `include "axi_master_sequencer.sv"
  `include "axi_master_driver.sv"
  `include "axi_master_monitor.sv"
  `include "axi_master_agent.sv"

  `include "axi_slave_monitor.sv"
  `include "axi_slave_agent.sv"

  `include "axi_scoreboard.sv"
  `include "axi_coverage.sv"
  `include "axi_env.sv"

  `include "axi_base_seq.sv"
  `include "axi_single_write_seq.sv"
  `include "axi_single_read_seq.sv"
  `include "axi_write_read_seq.sv"
  `include "axi_burst_seq.sv"
  `include "axi_rand_seq.sv"

  `include "axi_base_test.sv"
  `include "axi_smoke_test.sv"
  `include "axi_burst_test.sv"
  `include "axi_rand_test.sv"

endpackage
