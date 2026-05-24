// Legal AXI4 master assumptions for formal (SymbiYosys)
module axi_master_assumes #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int STRB_WIDTH = DATA_WIDTH / 8
)(
  input  logic                  aclk,
  input  logic                  aresetn,
  input  logic [ID_WIDTH-1:0]   awid,
  input  logic [ADDR_WIDTH-1:0] awaddr,
  input  logic [7:0]            awlen,
  input  logic [2:0]            awsize,
  input  logic [1:0]            awburst,
  input  logic                  awvalid,
  input  logic                  awready,
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic [STRB_WIDTH-1:0] wstrb,
  input  logic                  wlast,
  input  logic                  wvalid,
  input  logic                  wready,
  input  logic                  bready,
  input  logic [ID_WIDTH-1:0]   arid,
  input  logic [ADDR_WIDTH-1:0] araddr,
  input  logic [7:0]            arlen,
  input  logic [2:0]            arsize,
  input  logic [1:0]            arburst,
  input  logic                  arvalid,
  input  logic                  arready,
  input  logic                  rready
);

  // Handshake stability (master-driven channels)
  property aw_stable;
    @(posedge aclk) disable iff (!aresetn)
      awvalid && !awready |=> awvalid;
  endproperty
  assume property (aw_stable);

  property w_stable;
    @(posedge aclk) disable iff (!aresetn)
      wvalid && !wready |=> wvalid;
  endproperty
  assume property (w_stable);

  property ar_stable;
    @(posedge aclk) disable iff (!aresetn)
      arvalid && !arready |=> arvalid;
  endproperty
  assume property (ar_stable);

  // Only INCR bursts in formal (matches cocotb smoke tests)
  assume property (@(posedge aclk) disable iff (!aresetn)
    awvalid |-> awburst == 2'b01);
  assume property (@(posedge aclk) disable iff (!aresetn)
    arvalid |-> arburst == 2'b01);

  // Full-word transfers
  localparam int SIZE_BITS = $clog2(STRB_WIDTH);
  assume property (@(posedge aclk) disable iff (!aresetn)
    awvalid |-> awsize == SIZE_BITS);
  assume property (@(posedge aclk) disable iff (!aresetn)
    arvalid |-> arsize == SIZE_BITS);

endmodule
