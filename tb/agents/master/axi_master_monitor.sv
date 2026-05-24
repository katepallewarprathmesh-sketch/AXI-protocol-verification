class axi_master_monitor extends uvm_monitor;
  `uvm_component_utils(axi_master_monitor)

  virtual axi_if vif;
  uvm_analysis_port #(axi_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface not set for axi_master_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      axi_transaction tr;
      @(posedge vif.aclk);
      if (vif.awvalid && vif.awready)
        collect_write(tr);
      else if (vif.arvalid && vif.arready)
        collect_read(tr);
    end
  endtask

  task collect_write(output axi_transaction tr);
    tr = axi_transaction::type_id::create("mon_wr");
    tr.xact_type = AXI_WRITE;
    tr.id    = vif.awid;
    tr.addr  = vif.awaddr;
    tr.len   = vif.awlen;
    tr.size  = vif.awsize;
    tr.burst = axi_burst_e'(vif.awburst);
    tr.data  = new[tr.len + 1];
    tr.strb  = new[tr.len + 1];
    for (int i = 0; i <= tr.len; i++) begin
      do @(posedge vif.aclk); while (!(vif.wvalid && vif.wready));
      tr.data[i] = vif.wdata;
      tr.strb[i] = vif.wstrb;
    end
    do @(posedge vif.aclk); while (!(vif.bvalid && vif.bready));
    tr.resp = new[1];
    tr.resp[0] = axi_resp_e'(vif.bresp);
    ap.write(tr);
  endtask

  task collect_read(output axi_transaction tr);
    tr = axi_transaction::type_id::create("mon_rd");
    tr.xact_type = AXI_READ;
    tr.id    = vif.arid;
    tr.addr  = vif.araddr;
    tr.len   = vif.arlen;
    tr.size  = vif.arsize;
    tr.burst = axi_burst_e'(vif.arburst);
    tr.data  = new[tr.len + 1];
    tr.resp  = new[tr.len + 1];
    for (int i = 0; i <= tr.len; i++) begin
      do @(posedge vif.aclk); while (!(vif.rvalid && vif.rready));
      tr.data[i] = vif.rdata;
      tr.resp[i] = axi_resp_e'(vif.rresp);
    end
    ap.write(tr);
  endtask

endclass
