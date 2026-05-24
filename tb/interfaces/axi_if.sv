// AXI4 full interface for UVM verification
interface axi_if #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int STRB_WIDTH = DATA_WIDTH / 8
)(
  input logic aclk,
  input logic aresetn
);

  // Write address channel
  logic [ID_WIDTH-1:0]     awid;
  logic [ADDR_WIDTH-1:0]   awaddr;
  logic [7:0]              awlen;
  logic [2:0]              awsize;
  logic [1:0]              awburst;
  logic                    awlock;
  logic [3:0]              awcache;
  logic [2:0]              awprot;
  logic [3:0]              awqos;
  logic                    awvalid;
  logic                    awready;

  // Write data channel
  logic [DATA_WIDTH-1:0]   wdata;
  logic [STRB_WIDTH-1:0]   wstrb;
  logic                    wlast;
  logic                    wvalid;
  logic                    wready;

  // Write response channel
  logic [ID_WIDTH-1:0]     bid;
  logic [1:0]              bresp;
  logic                    bvalid;
  logic                    bready;

  // Read address channel
  logic [ID_WIDTH-1:0]     arid;
  logic [ADDR_WIDTH-1:0]   araddr;
  logic [7:0]              arlen;
  logic [2:0]              arsize;
  logic [1:0]              arburst;
  logic                    arlock;
  logic [3:0]              arcache;
  logic [2:0]              arprot;
  logic [3:0]              arqos;
  logic                    arvalid;
  logic                    arready;

  // Read data channel
  logic [ID_WIDTH-1:0]     rid;
  logic [DATA_WIDTH-1:0]   rdata;
  logic [1:0]              rresp;
  logic                    rlast;
  logic                    rvalid;
  logic                    rready;

  modport master (
    output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos,
           awvalid, wdata, wstrb, wlast, wvalid, bready,
           arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos,
           arvalid, rready,
    input  awready, wready, bid, bresp, bvalid,
           arready, rid, rdata, rresp, rlast, rvalid
  );

  modport slave (
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos,
           awvalid, wdata, wstrb, wlast, wvalid, bready,
           arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos,
           arvalid, rready,
    output awready, wready, bid, bresp, bvalid,
           arready, rid, rdata, rresp, rlast, rvalid
  );

  modport monitor (
    input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos,
          awvalid, awready, wdata, wstrb, wlast, wvalid, wready,
          bid, bresp, bvalid, bready,
          arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos,
          arvalid, arready, rid, rdata, rresp, rlast, rvalid, rready
  );

  clocking master_cb @(posedge aclk);
    default input #1step output #0;
    output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awvalid;
    output wdata, wstrb, wlast, wvalid;
    output bready;
    output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arvalid;
    output rready;
    input  awready, wready, bid, bresp, bvalid;
    input  arready, rid, rdata, rresp, rlast, rvalid;
  endclocking

  clocking slave_cb @(posedge aclk);
    default input #1step output #0;
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awvalid;
    input  wdata, wstrb, wlast, wvalid;
    input  bready;
    input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arvalid;
    input  rready;
    output awready, wready, bid, bresp, bvalid;
    output arready, rid, rdata, rresp, rlast, rvalid;
  endclocking

endinterface
