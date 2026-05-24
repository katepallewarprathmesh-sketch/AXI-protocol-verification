class axi_burst_seq extends axi_base_seq;
  `uvm_object_utils(axi_burst_seq)

  rand logic [AXI_ADDR_WIDTH-1:0] addr;
  rand logic [7:0] len;
  rand axi_burst_e burst;

  constraint c_len   { len inside {[1:7]}; }
  constraint c_addr  { addr[1:0] == 2'b00; addr < AXI_MEM_SIZE - 256; }
  constraint c_burst { burst == AXI_INCR; }

  function new(string name = "axi_burst_seq");
    super.new(name);
  endfunction

  task body();
    axi_transaction wr, rd;
    wr = create_xact(AXI_WRITE);
    rd = create_xact(AXI_READ);
    if (!wr.randomize() with {
      xact_type == AXI_WRITE;
      addr == local::addr;
      len == local::len;
      burst == local::burst;
      size == $clog2(AXI_STRB_WIDTH);
    }) `uvm_fatal("SEQ", "burst write randomize failed")
    foreach (wr.data[i]) wr.data[i] = addr + i;
    rd.addr  = wr.addr;
    rd.id    = wr.id + 1;
    rd.len   = wr.len;
    rd.size  = wr.size;
    rd.burst = wr.burst;
    rd.xact_type = AXI_READ;
    start_item(wr); finish_item(wr);
    start_item(rd); finish_item(rd);
  endtask

endclass
