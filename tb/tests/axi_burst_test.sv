class axi_burst_test extends axi_base_test;
  `uvm_component_utils(axi_burst_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_burst_seq seq;
    phase.raise_objection(this);
    repeat (5) begin
      seq = axi_burst_seq::type_id::create("burst_seq");
      if (!seq.randomize())
        `uvm_fatal("TEST", "burst seq randomize failed")
      seq.start(env.master_agent.sequencer);
    end
    #300ns;
    phase.drop_objection(this);
  endtask

endclass
