// Functional coverage for AXI master transactions
class axi_coverage extends uvm_subscriber #(axi_transaction);
  `uvm_component_utils(axi_coverage)

  axi_transaction tr;

  covergroup axi_cg;
    option.per_instance = 1;
    cp_type:  coverpoint tr.xact_type { bins write = {AXI_WRITE}; bins read = {AXI_READ}; }
    cp_len:   coverpoint tr.len { bins single = {0}; bins burst4 = {[1:3]}; bins long = {[4:15]}; }
    cp_size:  coverpoint tr.size;
    cp_burst: coverpoint tr.burst;
    cp_resp:  coverpoint tr.resp[0] iff (tr.resp.size() > 0 && tr.xact_type == AXI_WRITE);
    cross_type_len: cross cp_type, cp_len;
    cross_burst_size: cross cp_burst, cp_size;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    axi_cg = new();
  endfunction

  function void write(axi_transaction t);
    tr = t;
    axi_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("AXI coverage: %.2f%%", axi_cg.get_coverage()), UVM_LOW)
  endfunction

endclass
