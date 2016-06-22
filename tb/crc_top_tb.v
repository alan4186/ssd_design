`timescale 1ns/10ps
module crc_top_tb;
//===========================================================================
// REG and WIRE declaration
//===========================================================================
reg clk;
reg rst;

reg [7:0] data;
reg wr_enable;

wire buffer_full;
wire crc_done;
wire [15:0] crc_value;

//===========================================================================
// Device Under Test
//===========================================================================
crc_top dut(
  .clk(clk),
  .rst(rst),
  .byte_in(data),
  .wrreq(wr_enable),
  .buffer_full(buffer_full),
  .crc_done(crc_done),
  .crc_value(crc_value)
);

//===========================================================================
// Always blocks
//===========================================================================
always
  #5 clk = !clk;

always
  #10 data = 8'd0;//$random;
//===========================================================================
// initial blocks
//===========================================================================
initial begin
  rst = 1'b1;
  clk = 1'b1;
  wr_enable = 1'b0;
  data = 8'd0;
  
  #10
  rst = 1'b0;
  #30
  rst = 1'b1;
  
  #20
  wr_enable = 1'b1;
 
  #20
  wr_enable = 1'b0;

  #240
  $stop;
  


end



endmodule
