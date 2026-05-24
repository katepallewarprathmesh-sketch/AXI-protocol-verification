// Simple AXI4 memory slave DUT with configurable ready latency
module axi_slave_mem #(
  parameter int ADDR_WIDTH = 32,
  parameter int DATA_WIDTH = 32,
  parameter int ID_WIDTH   = 4,
  parameter int STRB_WIDTH = DATA_WIDTH / 8,
  parameter int MEM_BYTES  = 4096,
  parameter int AW_READY_DELAY = 0,
  parameter int W_READY_DELAY  = 0,
  parameter int B_VALID_DELAY  = 0,
  parameter int AR_READY_DELAY = 0,
  parameter int R_VALID_DELAY  = 0
)(
  input  logic                  aclk,
  input  logic                  aresetn,
  // AW
  input  logic [ID_WIDTH-1:0]   awid,
  input  logic [ADDR_WIDTH-1:0] awaddr,
  input  logic [7:0]            awlen,
  input  logic [2:0]            awsize,
  input  logic [1:0]            awburst,
  input  logic                  awvalid,
  output logic                  awready,
  // W
  input  logic [DATA_WIDTH-1:0] wdata,
  input  logic [STRB_WIDTH-1:0] wstrb,
  input  logic                  wlast,
  input  logic                  wvalid,
  output logic                  wready,
  // B
  output logic [ID_WIDTH-1:0]   bid,
  output logic [1:0]            bresp,
  output logic                  bvalid,
  input  logic                  bready,
  // AR
  input  logic [ID_WIDTH-1:0]   arid,
  input  logic [ADDR_WIDTH-1:0] araddr,
  input  logic [7:0]            arlen,
  input  logic [2:0]            arsize,
  input  logic [1:0]            arburst,
  input  logic                  arvalid,
  output logic                  arready,
  // R
  output logic [ID_WIDTH-1:0]   rid,
  output logic [DATA_WIDTH-1:0] rdata,
  output logic [1:0]            rresp,
  output logic                  rlast,
  output logic                  rvalid,
  input  logic                  rready
);

  localparam int MEM_WORDS = MEM_BYTES / (DATA_WIDTH / 8);
  localparam int AW_W = $clog2(MEM_WORDS);

  logic [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];

  // Write FSM
  typedef enum logic [1:0] { W_IDLE, W_DATA, W_RESP } w_state_e;
  w_state_e w_state, w_nstate;
  logic [7:0] w_beat_cnt, w_beat_max;
  logic [ID_WIDTH-1:0]   w_id_q;
  logic [ADDR_WIDTH-1:0] w_addr_q;
  logic [2:0]            w_size_q;
  logic [1:0]            w_burst_q;
  logic [ADDR_WIDTH-1:0] w_cur_addr;
  logic [AW_W-1:0]       w_idx;

  // Read FSM
  typedef enum logic [1:0] { R_IDLE, R_DATA } r_state_e;
  r_state_e r_state, r_nstate;
  logic [7:0] r_beat_cnt, r_beat_max;
  logic [ID_WIDTH-1:0]   r_id_q;
  logic [ADDR_WIDTH-1:0] r_addr_q;
  logic [2:0]            r_size_q;
  logic [1:0]            r_burst_q;
  logic [ADDR_WIDTH-1:0] r_cur_addr;
  logic [AW_W-1:0]       r_idx;

  // Delay counters
  logic [3:0] aw_dly, w_dly, b_dly, ar_dly, r_dly;

  function automatic logic [ADDR_WIDTH-1:0] next_addr(
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [2:0] size,
    input logic [1:0] burst,
    input logic [7:0] beat,
    input logic [7:0] len
  );
    logic [ADDR_WIDTH-1:0] a;
    int unsigned bytes;
    bytes = 1 << size;
    a = addr;
    if (burst == 2'b01) begin // INCR
      a = addr + (beat + 1) * bytes;
    end else if (burst == 2'b10) begin // WRAP
      int wrap_bound = ((len + 1) * bytes);
      a = addr + (beat + 1) * bytes;
      if ((a % wrap_bound) == 0 && beat != len)
        a = addr - (len * bytes);
    end
    return a;
  endfunction

  function automatic logic [AW_W-1:0] addr_to_idx(input logic [ADDR_WIDTH-1:0] a);
    return a[AW_W+$clog2(STRB_WIDTH)-1:$clog2(STRB_WIDTH)];
  endfunction

  // Write state machine
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      w_state <= W_IDLE;
      w_id_q <= '0;
      w_addr_q <= '0;
      w_size_q <= '0;
      w_burst_q <= '0;
      w_beat_cnt <= '0;
      w_beat_max <= '0;
      w_cur_addr <= '0;
      aw_dly <= '0;
      w_dly <= '0;
      b_dly <= '0;
    end else begin
      w_state <= w_nstate;
      if (awvalid && awready) begin
        w_id_q <= awid;
        w_addr_q <= awaddr;
        w_size_q <= awsize;
        w_burst_q <= awburst;
        w_beat_max <= awlen;
        w_cur_addr <= awaddr;
        w_beat_cnt <= 0;
      end
      if (wvalid && wready) begin
        w_idx <= addr_to_idx(w_cur_addr);
        for (int i = 0; i < STRB_WIDTH; i++)
          if (wstrb[i]) mem[addr_to_idx(w_cur_addr)][8*i+:8] <= wdata[8*i+:8];
        if (!wlast) begin
          w_beat_cnt <= w_beat_cnt + 1;
          w_cur_addr <= next_addr(w_addr_q, w_size_q, w_burst_q, w_beat_cnt, w_beat_max);
        end
      end
      if (awvalid && awready) aw_dly <= 0;
      else if (w_state == W_IDLE && awvalid) aw_dly <= AW_READY_DELAY;
      else if (aw_dly > 0) aw_dly <= aw_dly - 1;
      if (awvalid && awready) w_dly <= W_READY_DELAY;
      else if (w_dly > 0) w_dly <= w_dly - 1;
      if (w_nstate == W_RESP) b_dly <= B_VALID_DELAY;
      else if (b_dly > 0) b_dly <= b_dly - 1;
    end
  end

  always_comb begin
    w_nstate = w_state;
    awready = 1'b0;
    wready  = 1'b0;
    bvalid  = 1'b0;
    bid     = w_id_q;
    bresp   = 2'b00;
    case (w_state)
      W_IDLE: begin
        if (awvalid && aw_dly == 0) begin
          awready = 1'b1;
          w_nstate = W_DATA;
        end
      end
      W_DATA: begin
        if (w_dly == 0) begin
          wready = 1'b1;
          if (wvalid && wready)
            w_nstate = wlast ? W_RESP : W_DATA;
        end
      end
      W_RESP: begin
        if (b_dly == 0) begin
          bvalid = 1'b1;
          if (bvalid && bready) w_nstate = W_IDLE;
        end
      end
    endcase
  end

  // Read state machine
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      r_state <= R_IDLE;
      r_id_q <= '0;
      r_addr_q <= '0;
      r_size_q <= '0;
      r_burst_q <= '0;
      r_beat_cnt <= '0;
      r_beat_max <= '0;
      r_cur_addr <= '0;
      ar_dly <= '0;
      r_dly <= '0;
    end else begin
      r_state <= r_nstate;
      if (arvalid && arready) begin
        r_id_q <= arid;
        r_addr_q <= araddr;
        r_size_q <= arsize;
        r_burst_q <= arburst;
        r_beat_max <= arlen;
        r_cur_addr <= araddr;
        r_beat_cnt <= 0;
      end
      if (rvalid && rready) begin
        if (!rlast) begin
          r_beat_cnt <= r_beat_cnt + 1;
          r_cur_addr <= next_addr(r_addr_q, r_size_q, r_burst_q, r_beat_cnt, r_beat_max);
        end
      end
      if (arvalid && arready) ar_dly <= 0;
      else if (r_state == R_IDLE && arvalid) ar_dly <= AR_READY_DELAY;
      else if (ar_dly > 0) ar_dly <= ar_dly - 1;
      if (arvalid && arready) r_dly <= R_VALID_DELAY;
      else if (r_dly > 0) r_dly <= r_dly - 1;
    end
  end

  always_comb begin
    r_nstate = r_state;
    arready = 1'b0;
    rvalid  = 1'b0;
    rid     = r_id_q;
    rdata   = '0;
    rresp   = 2'b00;
    rlast   = 1'b0;
    case (r_state)
      R_IDLE: begin
        if (arvalid && ar_dly == 0) begin
          arready = 1'b1;
          r_nstate = R_DATA;
        end
      end
      R_DATA: begin
        if (r_dly == 0) begin
          r_idx = addr_to_idx(r_cur_addr);
          rdata = mem[r_idx];
          rlast = (r_beat_cnt == r_beat_max);
          rvalid = 1'b1;
          if (rvalid && rready)
            r_nstate = rlast ? R_IDLE : R_DATA;
        end
      end
    endcase
  end

endmodule
