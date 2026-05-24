class axi_master_driver extends uvm_driver #(axi_transaction);
  `uvm_component_utils(axi_master_driver)

  virtual axi_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "virtual interface not set for axi_master_driver")
  endfunction

  task reset_signals();
    vif.awvalid <= 0;
    vif.wvalid  <= 0;
    vif.bready  <= 0;
    vif.arvalid <= 0;
    vif.rready  <= 0;
    vif.awid <= 0; vif.awaddr <= 0; vif.awlen <= 0;
    vif.awsize <= 0; vif.awburst <= 0; vif.awlock <= 0;
    vif.awcache <= 0; vif.awprot <= 0; vif.awqos <= 0;
    vif.wdata <= 0; vif.wstrb <= 0; vif.wlast <= 0;
    vif.arid <= 0; vif.araddr <= 0; vif.arlen <= 0;
    vif.arsize <= 0; vif.arburst <= 0; vif.arlock <= 0;
    vif.arcache <= 0; vif.arprot <= 0; vif.arqos <= 0;
  endtask

  task run_phase(uvm_phase phase);
    reset_signals();
    forever begin
      seq_item_port.get_next_item(req);
      if (req.xact_type == AXI_WRITE)
        drive_write(req);
      else
        drive_read(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_write(axi_transaction tr);
    repeat (tr.aw_delay) @(posedge vif.aclk);
    // AW channel
    vif.awid    <= tr.id;
    vif.awaddr  <= tr.addr;
    vif.awlen   <= tr.len;
    vif.awsize  <= tr.size;
    vif.awburst <= tr.burst;
    vif.awvalid <= 1;
    do @(posedge vif.aclk); while (!vif.awready);
    vif.awvalid <= 0;

    // W channel
    for (int i = 0; i <= tr.len; i++) begin
      repeat (tr.w_delay[i]) @(posedge vif.aclk);
      vif.wdata  <= tr.data[i];
      vif.wstrb  <= tr.strb[i];
      vif.wlast  <= (i == tr.len);
      vif.wvalid <= 1;
      do @(posedge vif.aclk); while (!vif.wready);
      vif.wvalid <= 0;
    end

    // B channel
    vif.bready <= 1;
    repeat (tr.b_delay) @(posedge vif.aclk);
    do @(posedge vif.aclk); while (!vif.bvalid);
    tr.resp = new[1];
    tr.resp[0] = axi_resp_e'(vif.bresp);
    vif.bready <= 0;
  endtask

  task drive_read(axi_transaction tr);
    repeat (tr.ar_delay) @(posedge vif.aclk);
    vif.arid    <= tr.id;
    vif.araddr  <= tr.addr;
    vif.arlen   <= tr.len;
    vif.arsize  <= tr.size;
    vif.arburst <= tr.burst;
    vif.arvalid <= 1;
    do @(posedge vif.aclk); while (!vif.arready);
    vif.arvalid <= 0;

    tr.data = new[tr.len + 1];
    tr.resp = new[tr.len + 1];
    vif.rready <= 1;
    for (int i = 0; i <= tr.len; i++) begin
      repeat (tr.r_delay[i]) @(posedge vif.aclk);
      do @(posedge vif.aclk); while (!vif.rvalid);
      tr.data[i] = vif.rdata;
      tr.resp[i] = axi_resp_e'(vif.rresp);
      if (vif.rlast && i != tr.len)
        `uvm_error("DRV", $sformatf("RLAST early at beat %0d", i))
      if (!vif.rlast && i == tr.len)
        `uvm_error("DRV", "RLAST missing on final beat")
    end
    vif.rready <= 0;
  endtask

endclass
