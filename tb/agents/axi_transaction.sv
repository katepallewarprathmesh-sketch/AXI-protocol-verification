// UVM transaction representing an AXI burst (write or read)
class axi_transaction extends uvm_sequence_item;

  rand axi_xact_type_e   xact_type;
  rand logic [AXI_ID_WIDTH-1:0]     id;
  rand logic [AXI_ADDR_WIDTH-1:0]   addr;
  rand logic [7:0]                  len;      // beats - 1
  rand logic [2:0]                  size;     // log2(bytes per beat)
  rand axi_burst_e                  burst;
  rand logic [AXI_DATA_WIDTH-1:0]   data[];
  rand logic [AXI_STRB_WIDTH-1:0]   strb[];
  rand axi_resp_e                   resp[];
  rand int unsigned                 aw_delay;
  rand int unsigned                 w_delay[];
  rand int unsigned                 b_delay;
  rand int unsigned                 ar_delay;
  rand int unsigned                 r_delay[];

  constraint c_len_data {
    data.size() == len + 1;
    strb.size() == len + 1;
    resp.size() == (xact_type == AXI_READ) ? len + 1 : 0;
    w_delay.size() == (xact_type == AXI_WRITE) ? len + 1 : 0;
    r_delay.size() == (xact_type == AXI_READ) ? len + 1 : 0;
  }

  constraint c_valid_size {
    size inside {[0:$clog2(AXI_STRB_WIDTH)]};
  }

  constraint c_burst_legal {
    burst inside {AXI_INCR, AXI_FIXED};
  }

  constraint c_delays {
    aw_delay inside {[0:3]};
    b_delay inside {[0:3]};
    ar_delay inside {[0:3]};
    foreach (w_delay[i]) w_delay[i] inside {[0:2]};
    foreach (r_delay[i]) r_delay[i] inside {[0:2]};
  }

  `uvm_object_utils_begin(axi_transaction)
    `uvm_field_enum(axi_xact_type_e, xact_type, UVM_DEFAULT)
    `uvm_field_int(id,   UVM_DEFAULT)
    `uvm_field_int(addr, UVM_HEX | UVM_DEFAULT)
    `uvm_field_int(len,  UVM_DEFAULT)
    `uvm_field_int(size, UVM_DEFAULT)
    `uvm_field_enum(axi_burst_e, burst, UVM_DEFAULT)
    `uvm_field_array_int(data, UVM_HEX | UVM_DEFAULT)
    `uvm_field_array_int(strb, UVM_HEX | UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "axi_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("%s id=0x%0h addr=0x%0h len=%0d size=%0d burst=%s",
      xact_type.name(), id, addr, len, size, burst.name());
  endfunction

  function void post_randomize();
    foreach (strb[i])
      if (strb[i] == '0)
        strb[i] = {AXI_STRB_WIDTH{1'b1}};
  endfunction

endclass
