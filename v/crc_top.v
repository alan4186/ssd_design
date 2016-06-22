module crc_top(
  input clk,
  input rst,

  // fifo buffer 
  input [7:0] byte_in,
  input wrreq,

  output buffer_full,

  // crc
  output crc_done,
  output [15:0] crc_value

  // for testing
  //input en,
  //input load
);

//===========================================================================
// macro declarations
//===========================================================================

//===========================================================================
// Parameter declarations
//===========================================================================

//===========================================================================
// Reg/Wire declarations for internal signals
//===========================================================================

wire empty;
wire shiftout;
wire [7:0] buffer_q;
wire enable;
wire rdreq;
//===========================================================================
// Assign statments
//===========================================================================

//===========================================================================
// Wire up modules
//===========================================================================

crc_16 crc_16_0(
  .clk(clk),
  .rst(rst),
  .data_in_buf(!empty),
  .bit_in(shiftout),
  .crc_value(crc_value),
  .rdreq(rdreq),
  .enable(enable),
  .crc_done(crc_done)
);

crc_buffer crc_buffer_0(
  .aclr(!rst),
  .clock(clk),
  .data(byte_in),
  .rdreq(rdreq),
  .wrreq(wrreq),
  .empty(empty),
  .full(buffer_full),
  .q(buffer_q)
);

crc_byte_2_bit crc_b2b0(
  .clk(clk),
  .rst(rst),
  .data(buffer_q),
  .enable(enable),
  .load(rdreq),
  .shiftout(shiftout)

);


endmodule
