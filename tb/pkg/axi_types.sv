// Shared AXI types and parameters for verification
package axi_types;

  parameter int AXI_ADDR_WIDTH = 32;
  parameter int AXI_DATA_WIDTH = 32;
  parameter int AXI_ID_WIDTH   = 4;
  parameter int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  parameter int AXI_MEM_SIZE   = 4096;  // bytes

  typedef enum logic [1:0] {
    AXI_FIXED = 2'b00,
    AXI_INCR  = 2'b01,
    AXI_WRAP  = 2'b10
  } axi_burst_e;

  typedef enum logic [1:0] {
    AXI_OKAY   = 2'b00,
    AXI_EXOKAY = 2'b01,
    AXI_SLVERR = 2'b10,
    AXI_DECERR = 2'b11
  } axi_resp_e;

  typedef enum { AXI_WRITE, AXI_READ } axi_xact_type_e;

endpackage
