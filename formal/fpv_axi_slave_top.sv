// Formal top: DUT + master assumptions + protocol / slave checks
module fpv_axi_slave_top;

  localparam int ADDR_WIDTH = 32;
  localparam int DATA_WIDTH = 32;
  localparam int ID_WIDTH   = 4;
  localparam int STRB_WIDTH = DATA_WIDTH / 8;

  logic                  aclk;
  logic                  aresetn;

  logic [ID_WIDTH-1:0]   awid;
  logic [ADDR_WIDTH-1:0] awaddr;
  logic [7:0]            awlen;
  logic [2:0]            awsize;
  logic [1:0]            awburst;
  logic                  awvalid;
  logic                  awready;

  logic [DATA_WIDTH-1:0] wdata;
  logic [STRB_WIDTH-1:0] wstrb;
  logic                  wlast;
  logic                  wvalid;
  logic                  wready;

  logic [ID_WIDTH-1:0]   bid;
  logic [1:0]            bresp;
  logic                  bvalid;
  logic                  bready;

  logic [ID_WIDTH-1:0]   arid;
  logic [ADDR_WIDTH-1:0] araddr;
  logic [7:0]            arlen;
  logic [2:0]            arsize;
  logic [1:0]            arburst;
  logic                  arvalid;
  logic                  arready;

  logic [ID_WIDTH-1:0]   rid;
  logic [DATA_WIDTH-1:0] rdata;
  logic [1:0]            rresp;
  logic                  rlast;
  logic                  rvalid;
  logic                  rready;

  initial begin
    aclk = 0;
    forever #5 aclk = ~aclk;
  end

  initial begin
    aresetn = 0;
    repeat (3) @(posedge aclk);
    aresetn = 1;
  end

  axi_slave_mem #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH),
    .MEM_BYTES  (4096)
  ) dut (
    .aclk, .aresetn,
    .awid, .awaddr, .awlen, .awsize, .awburst, .awvalid, .awready,
    .wdata, .wstrb, .wlast, .wvalid, .wready,
    .bid, .bresp, .bvalid, .bready,
    .arid, .araddr, .arlen, .arsize, .arburst, .arvalid, .arready,
    .rid, .rdata, .rresp, .rlast, .rvalid, .rready
  );

  axi_master_assumes #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
  ) master_assumes (
    .aclk, .aresetn,
    .awid, .awaddr, .awlen, .awsize, .awburst, .awvalid, .awready,
    .wdata, .wstrb, .wlast, .wvalid, .wready, .bready,
    .arid, .araddr, .arlen, .arsize, .arburst, .arvalid, .arready,
    .rready
  );

  axi_slave_asserts #(.ID_WIDTH(ID_WIDTH)) slave_checks (
    .aclk, .aresetn, .bresp, .bvalid, .rresp, .rvalid, .rlast
  );

  axi_protocol_assertions #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
  ) protocol_checks (
    .aclk, .aresetn,
    .awid, .awaddr, .awlen, .awsize, .awburst, .awvalid, .awready,
    .wdata, .wstrb, .wlast, .wvalid, .wready,
    .bid, .bresp, .bvalid, .bready,
    .arid, .araddr, .arlen, .arsize, .arburst, .arvalid, .arready,
    .rid, .rdata, .rresp, .rlast, .rvalid, .rready
  );

endmodule
