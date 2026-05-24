class axi_rand_seq extends axi_base_seq;
  `uvm_object_utils(axi_rand_seq)

  rand int unsigned num_xacts;

  constraint c_num { num_xacts inside {[5:20]}; }

  function new(string name = "axi_rand_seq");
    super.new(name);
  endfunction

  task body();
    for (int i = 0; i < num_xacts; i++) begin
      axi_transaction tr = axi_transaction::type_id::create($sformatf("rand_%0d", i));
      if (!tr.randomize() with {
        addr[1:0] == 2'b00;
        addr < AXI_MEM_SIZE - 128;
        len inside {[0:7]};
        size == $clog2(AXI_STRB_WIDTH);
        burst inside {AXI_INCR, AXI_FIXED};
      })
        `uvm_fatal("SEQ", "randomize failed")
      start_item(tr);
      finish_item(tr);
      if (tr.xact_type == AXI_WRITE) begin
        axi_transaction rd = axi_transaction::type_id::create("rd_follow");
        rd.xact_type = AXI_READ;
        rd.addr  = tr.addr;
        rd.len   = tr.len;
        rd.size  = tr.size;
        rd.burst = tr.burst;
        rd.id    = tr.id;
        start_item(rd);
        finish_item(rd);
      end
    end
  endtask

endclass
