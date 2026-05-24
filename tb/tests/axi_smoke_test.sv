class axi_smoke_test extends axi_base_test;
  `uvm_component_utils(axi_smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_write_read_seq seq;
    phase.raise_objection(this);
    seq = axi_write_read_seq::type_id::create("seq");
    seq.num_pairs = 3;
    if (!seq.randomize())
      `uvm_fatal("TEST", "sequence randomize failed")
    seq.start(env.master_agent.sequencer);
    #200ns;
    phase.drop_objection(this);
  endtask

endclass
