class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_master_agent master_agent;
  axi_slave_agent  slave_agent;
  axi_scoreboard   scoreboard;
  axi_coverage     coverage;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    master_agent = axi_master_agent::type_id::create("master_agent", this);
    slave_agent  = axi_slave_agent::type_id::create("slave_agent", this);
    scoreboard   = axi_scoreboard::type_id::create("scoreboard", this);
    coverage     = axi_coverage::type_id::create("coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    master_agent.monitor.ap.connect(scoreboard.master_imp);
    master_agent.monitor.ap.connect(coverage.analysis_export);
  endfunction

endclass
