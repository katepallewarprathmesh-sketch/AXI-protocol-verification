class axi_slave_agent extends uvm_agent;
  `uvm_component_utils(axi_slave_agent)

  axi_slave_monitor monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = axi_slave_monitor::type_id::create("monitor", this);
  endfunction

endclass
