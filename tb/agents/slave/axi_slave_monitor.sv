// Passive monitor on slave interface (observes DUT responses)
class axi_slave_monitor extends uvm_monitor;
  `uvm_component_utils(axi_slave_monitor)

  virtual axi_if vif;
  uvm_analysis_port #(axi_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface not set for axi_slave_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.aclk);
      if (vif.bvalid && vif.bready) begin
        axi_transaction tr = axi_transaction::type_id::create("slv_b");
        tr.xact_type = AXI_WRITE;
        tr.id = vif.bid;
        tr.resp = new[1];
        tr.resp[0] = axi_resp_e'(vif.bresp);
        ap.write(tr);
      end
    end
  endtask

endclass
