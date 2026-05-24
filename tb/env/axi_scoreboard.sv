// Memory-backed scoreboard: records writes, checks reads
class axi_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp #(axi_transaction, axi_scoreboard) master_imp;

  logic [7:0] mem [0:AXI_MEM_SIZE-1];
  int unsigned wr_count, rd_count, err_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    master_imp = new("master_imp", this);
  endfunction

  function void write(axi_transaction tr);
    if (tr.xact_type == AXI_WRITE)
      record_write(tr);
    else
      check_read(tr);
  endfunction

  function void record_write(axi_transaction tr);
    int unsigned bytes = 1 << tr.size;
    logic [AXI_ADDR_WIDTH-1:0] cur = tr.addr;
    wr_count++;
    for (int i = 0; i <= tr.len; i++) begin
      for (int b = 0; b < AXI_STRB_WIDTH; b++) begin
        if (tr.strb[i][b] && cur + b < AXI_MEM_SIZE)
          mem[cur + b] = tr.data[i][8*b +: 8];
      end
      if (tr.burst == AXI_INCR)
        cur += bytes;
    end
    if (tr.resp.size() > 0 && tr.resp[0] != AXI_OKAY) begin
      err_count++;
      `uvm_error("SCB", $sformatf("Write response not OKAY: %s", tr.resp[0].name()))
    end
  endfunction

  function void check_read(axi_transaction tr);
    int unsigned bytes = 1 << tr.size;
    logic [AXI_ADDR_WIDTH-1:0] cur = tr.addr;
    rd_count++;
    for (int i = 0; i <= tr.len; i++) begin
      logic [AXI_DATA_WIDTH-1:0] expected = '0;
      for (int b = 0; b < AXI_STRB_WIDTH; b++) begin
        if (cur + b < AXI_MEM_SIZE)
          expected[8*b +: 8] = mem[cur + b];
      end
      if (tr.data[i] !== expected) begin
        err_count++;
        `uvm_error("SCB", $sformatf(
          "Read mismatch beat %0d addr=0x%0h exp=0x%0h got=0x%0h",
          i, cur, expected, tr.data[i]))
      end
      if (tr.resp[i] != AXI_OKAY) begin
        err_count++;
        `uvm_error("SCB", $sformatf("Read response not OKAY beat %0d", i))
      end
      if (tr.burst == AXI_INCR)
        cur += bytes;
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SCB", $sformatf("Writes=%0d Reads=%0d Errors=%0d",
      wr_count, rd_count, err_count), UVM_LOW)
  endfunction

endclass
