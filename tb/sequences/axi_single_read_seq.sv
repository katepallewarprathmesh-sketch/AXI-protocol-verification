class axi_single_read_seq extends axi_base_seq;
  `uvm_object_utils(axi_single_read_seq)

  rand logic [AXI_ADDR_WIDTH-1:0] addr;
  rand logic [AXI_ID_WIDTH-1:0] id;

  constraint c_addr_align { addr[1:0] == 2'b00; }

  function new(string name = "axi_single_read_seq");
    super.new(name);
  endfunction

  task body();
    axi_transaction tr = create_xact(AXI_READ);
    tr.addr  = addr;
    tr.id    = id;
    tr.len   = 0;
    tr.size  = $clog2(AXI_STRB_WIDTH);
    tr.burst = AXI_INCR;
    `uvm_info("SEQ", tr.convert2string(), UVM_MEDIUM)
    start_item(tr);
    finish_item(tr);
  endtask

endclass
