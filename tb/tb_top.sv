`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import axi_pkg::*;

  logic aclk;
  logic aresetn;

  axi_if #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH(AXI_ID_WIDTH)
  ) axi_bus(.aclk(aclk), .aresetn(aresetn));

  axi_slave_mem #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH(AXI_ID_WIDTH),
    .MEM_BYTES(AXI_MEM_SIZE)
  ) dut (
    .aclk    (aclk),
    .aresetn (aresetn),
    .awid    (axi_bus.awid),    .awaddr  (axi_bus.awaddr),
    .awlen   (axi_bus.awlen),   .awsize  (axi_bus.awsize),
    .awburst (axi_bus.awburst), .awlock  (axi_bus.awlock),
    .awcache (axi_bus.awcache), .awprot  (axi_bus.awprot),
    .awvalid (axi_bus.awvalid), .awready (axi_bus.awready),
    .wdata   (axi_bus.wdata),   .wstrb   (axi_bus.wstrb),
    .wlast   (axi_bus.wlast),   .wvalid  (axi_bus.wvalid),
    .wready  (axi_bus.wready),
    .bid     (axi_bus.bid),     .bresp   (axi_bus.bresp),
    .bvalid  (axi_bus.bvalid),  .bready  (axi_bus.bready),
    .arid    (axi_bus.arid),    .araddr  (axi_bus.araddr),
    .arlen   (axi_bus.arlen),   .arsize  (axi_bus.arsize),
    .arburst (axi_bus.arburst), .arlock  (axi_bus.arlock),
    .arcache (axi_bus.arcache), .arprot  (axi_bus.arprot),
    .arvalid (axi_bus.arvalid), .arready (axi_bus.arready),
    .rid     (axi_bus.rid),     .rdata   (axi_bus.rdata),
    .rresp   (axi_bus.rresp),   .rlast   (axi_bus.rlast),
    .rvalid  (axi_bus.rvalid),  .rready  (axi_bus.rready)
  );

  axi_protocol_assertions #(
    .ADDR_WIDTH(AXI_ADDR_WIDTH),
    .DATA_WIDTH(AXI_DATA_WIDTH),
    .ID_WIDTH(AXI_ID_WIDTH)
  ) axi_sva (
    .aclk(aclk), .aresetn(aresetn),
    .awid(axi_bus.awid), .awaddr(axi_bus.awaddr), .awlen(axi_bus.awlen),
    .awsize(axi_bus.awsize), .awburst(axi_bus.awburst),
    .awvalid(axi_bus.awvalid), .awready(axi_bus.awready),
    .wdata(axi_bus.wdata), .wstrb(axi_bus.wstrb), .wlast(axi_bus.wlast),
    .wvalid(axi_bus.wvalid), .wready(axi_bus.wready),
    .bid(axi_bus.bid), .bresp(axi_bus.bresp),
    .bvalid(axi_bus.bvalid), .bready(axi_bus.bready),
    .arid(axi_bus.arid), .araddr(axi_bus.araddr), .arlen(axi_bus.arlen),
    .arsize(axi_bus.arsize), .arburst(axi_bus.arburst),
    .arvalid(axi_bus.arvalid), .arready(axi_bus.arready),
    .rid(axi_bus.rid), .rdata(axi_bus.rdata), .rresp(axi_bus.rresp),
    .rlast(axi_bus.rlast), .rvalid(axi_bus.rvalid), .rready(axi_bus.rready)
  );

  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;  // 100 MHz
  end

  initial begin
    aresetn = 0;
    repeat (5) @(posedge aclk);
    aresetn = 1;
  end

  initial begin
    uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top.env.master_agent*", "vif", axi_bus);
    uvm_config_db#(virtual axi_if)::set(null, "uvm_test_top.env.slave_agent*",  "vif", axi_bus);
    run_test();
  end

  initial begin
    string test_name;
    if ($value$plusargs("UVM_TESTNAME=%s", test_name))
      uvm_config_db#(string)::set(null, "", "default_test", test_name);
  end

endmodule
