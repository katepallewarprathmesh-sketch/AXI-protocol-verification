class axi_single_write_seq extends axi_base_seq;
  `uvm_object_utils(axi_single_write_seq)

  rand logic [AXI_ADDR_WIDTH-1:0] addr;
  rand logic [AXI_DATA_WIDTH-1:0] data;
  rand logic [AXI_ID_WIDTH-1:0] id;

  constraint c_addr_align { addr[1:0] == 2'b00; }

  function new(string name = "axi_single_write_seq");
    super.new(name);
  endfunction

  task body();
    axi_transaction tr = create_xact(AXI_WRITE);
    tr.addr  = addr;
    tr.id    = id;
    tr.len   = 0;
    tr.size  = $clog2(AXI_STRB_WIDTH);
    tr.burst = AXI_INCR;
    tr.data  = new[1];
    tr.strb  = new[1];
    tr.data[0] = data;
    tr.strb[0] = {AXI_STRB_WIDTH{1'b1}};
    `uvm_info("SEQ", tr.convert2string(), UVM_MEDIUM)
    start_item(tr);
    finish_item(tr);
  endtask

endclass
