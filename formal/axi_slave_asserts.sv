// Slave-side safety assertions for formal
module axi_slave_asserts #(
  parameter int ID_WIDTH = 4
)(
  input  logic                  aclk,
  input  logic                  aresetn,
  input  logic [1:0]            bresp,
  input  logic                  bvalid,
  input  logic [1:0]            rresp,
  input  logic                  rvalid,
  input  logic                  rlast
);

  // DUT should only return OKAY on happy path
  assert property (@(posedge aclk) disable iff (!aresetn)
    bvalid |-> bresp == 2'b00);

  assert property (@(posedge aclk) disable iff (!aresetn)
    rvalid |-> rresp == 2'b00);

endmodule
