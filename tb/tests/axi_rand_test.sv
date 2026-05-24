class axi_rand_test extends axi_base_test;
  `uvm_component_utils(axi_rand_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    axi_rand_seq seq;
    phase.raise_objection(this);
    seq = axi_rand_seq::type_id::create("rand_seq");
    if (!seq.randomize())
      `uvm_fatal("TEST", "rand seq randomize failed")
    seq.start(env.master_agent.sequencer);
    #500ns;
    phase.drop_objection(this);
  endtask

endclass
