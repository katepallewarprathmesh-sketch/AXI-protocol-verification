class axi_master_agent extends uvm_agent;
  `uvm_component_utils(axi_master_agent)

  axi_master_driver    driver;
  axi_master_monitor   monitor;
  axi_master_sequencer sequencer;
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = axi_master_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      driver    = axi_master_driver::type_id::create("driver", this);
      sequencer = axi_master_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

  function uvm_analysis_port #(axi_transaction) get_monitor_port();
    return monitor.ap;
  endfunction

endclass
