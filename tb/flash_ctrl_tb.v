`timescale 1ns/100ps
module flash_ctrl_tb;
//===========================================================================
// parameters
//===========================================================================
parameter tic = 6.25;
parameter tictoc = 12.5;


//===========================================================================
// REG and WIRE declaration
//===========================================================================
reg clk;
reg rst;

wire data_oe;
reg [7:0] core_data_out;
wire [7:0] core_data_in;
reg [31:0] instruction;
reg c_data_in_rdy;
reg c_data_out_rdy;
reg iq_empty;
wire ack_mode_read;
wire req_core_data;
wire output_dval;

wire oCE_N;
wire oCLE;
wire oALE;
wire oWE_N;
wire oRE_N;
wire oWP_N;
reg iRB_N;

//===========================================================================
// Device Under Test
//===========================================================================
flash_ctrl dut(
  // clock and reset
  .clk(clk), // probably 80 Mhz PLL
  .rst(rst),     
  // inout direction variable
  .data_oe(data_oe),
  // core side 
  .core_data_out(core_data_out), // data coming from core module
  .core_data_in(core_data_in), // data going to core module
  .instruction(instruction),  
  .c_data_in_rdy(c_data_in_rdy),  // the (probably inverted) read_empty signal from the data fifo
  .c_data_out_rdy(c_data_out_rdy), // the fifo full signal for the core_data_out queue
  .iq_empty(iq_empty), // the empty signal for the instruction queue fifo
  .ack_mode_read(ack_mode_read), // the read request signal for show ahead fifo with flash mode commands
  .req_core_data(req_core_data), // read request signal to data fifo
  .output_dval(output_dval), // signal to indicate flash_q should be latched output flash_rdy,

  // flash control signals
  .oCE_N(oCE_N),
  .oCLE(oCLE),
  .oALE(oALE),
  .oWE_N(oWE_N), 
  .oRE_N(oRE_N),
  .oWP_N(oWP_N),
  .iRB_N(iRB_N),
);


//===========================================================================
// tasks 
//===========================================================================
  
  // tasks for each fash mode
  // standby
  // bus idle
  // command input
  // addres input
  // data input
  // data output begin
  // data output end
  // write protect
  
  // these features need verified
  // repeat counter test
  // command queue under flow test
  // data queue under flow test
  //

//===========================================================================
// Always blocks
//===========================================================================
always
  #tic clk = !clk;


endmodule
