// AXI4 protocol assertions bound to axi_if
module axi_protocol_assertions #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int STRB_WIDTH = DATA_WIDTH / 8
)(
  input logic aclk,
  input logic aresetn,
  // AW
  input logic [ID_WIDTH-1:0]   awid,
  input logic [ADDR_WIDTH-1:0] awaddr,
  input logic [7:0]            awlen,
  input logic [2:0]            awsize,
  input logic [1:0]            awburst,
  input logic                  awvalid,
  input logic                  awready,
  // W
  input logic [DATA_WIDTH-1:0] wdata,
  input logic [STRB_WIDTH-1:0] wstrb,
  input logic                  wlast,
  input logic                  wvalid,
  input logic                  wready,
  // B
  input logic [ID_WIDTH-1:0]   bid,
  input logic [1:0]            bresp,
  input logic                  bvalid,
  input logic                  bready,
  // AR
  input logic [ID_WIDTH-1:0]   arid,
  input logic [ADDR_WIDTH-1:0] araddr,
  input logic [7:0]            arlen,
  input logic [2:0]            arsize,
  input logic [1:0]            arburst,
  input logic                  arvalid,
  input logic                  arready,
  // R
  input logic [ID_WIDTH-1:0]   rid,
  input logic [DATA_WIDTH-1:0] rdata,
  input logic [1:0]            rresp,
  input logic                  rlast,
  input logic                  rvalid,
  input logic                  rready
);

  // Stability: valid must hold until handshake
  property p_aw_stable;
    @(posedge aclk) disable iff (!aresetn)
      awvalid && !awready |=> awvalid;
  endproperty
  assert property (p_aw_stable) else $error("AXI_SVA: AWVALID dropped before AWREADY");

  property p_w_stable;
    @(posedge aclk) disable iff (!aresetn)
      wvalid && !wready |=> wvalid;
  endproperty
  assert property (p_w_stable) else $error("AXI_SVA: WVALID dropped before WREADY");

  property p_ar_stable;
    @(posedge aclk) disable iff (!aresetn)
      arvalid && !arready |=> arvalid;
  endproperty
  assert property (p_ar_stable) else $error("AXI_SVA: ARVALID dropped before ARREADY");

  property p_r_stable;
    @(posedge aclk) disable iff (!aresetn)
      rvalid && !rready |=> rvalid;
  endproperty
  assert property (p_r_stable) else $error("AXI_SVA: RVALID dropped before RREADY");

  property p_b_stable;
    @(posedge aclk) disable iff (!aresetn)
      bvalid && !bready |=> bvalid;
  endproperty
  assert property (p_b_stable) else $error("AXI_SVA: BVALID dropped before BREADY");

  // WLAST must be 1 on final beat of burst (tracked simplistically when AW accepted)
  logic [7:0] w_beat_cnt, w_len_latched;
  logic       w_active;

  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      w_active <= 0;
      w_beat_cnt <= 0;
      w_len_latched <= 0;
    end else begin
      if (awvalid && awready) begin
        w_active <= 1;
        w_len_latched <= awlen;
        w_beat_cnt <= 0;
      end else if (w_active && wvalid && wready) begin
        if (wlast)
          w_active <= 0;
        else
          w_beat_cnt <= w_beat_cnt + 1;
      end
    end
  end

  property p_wlast_final;
    @(posedge aclk) disable iff (!aresetn)
      wvalid && wready && w_active && (w_beat_cnt == w_len_latched) |-> wlast;
  endproperty
  assert property (p_wlast_final) else $error("AXI_SVA: WLAST not set on final W beat");

endmodule
