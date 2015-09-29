module level_one_tester(
	inout wire[0:8] padio,
	output clk,
	output wr,
	output ale,
	output cle,
	output ce1,
	output ce2,
	output wp,
	input rb1,
	input rb2,
	// controler ports
	input clock_100,
	input rst,
	input [7:0] shift_in,
	output rb1_ctrl,
	output rb2_ctrl,
	input [7:0] datain_h,
	input [7:0] datain_l,
	output [7:0] dataout_h,
	output [7:0] dataout_l
);
reg [2:0] cmd_array ;
wire [7:0] shift_out;

fifo cmd_queue(clk,shift_in,1'b1,1'b1,shift_out);

level_one channel_one(	
	 clk,
	 wr,
	 ale,
	 cle,
	 ce1,
	 ce2,
	 wp,
	 rb1,
	 rb2,
	// controler ports
	 clock_100,
	 rst,
	 shift_out,
	 rb1_ctrl,
	 rb2_ctrl,
	 1'd0,
 	datain_h,
	datain_l,
	dataout_h,
	dataout_l,
	padio
);


//module level_one (
//	output clk,
//	output wr,
//	output ale,
//	output cle,
//	output ce1,
//	output ce2,
//	output wp,
//	input rb1,
//	input rb2,
//	// controler ports
//	input clock_100,
//	input rst,
//	input wire [0:cmd_width_short] cmd,
//	output rb1_ctrl,
//	output rb2_ctrl,
//	input ce,
//	// ddr_dq ports
//	input   [8:0]  datain_h,
//	input   [8:0]  datain_l,
//	output   [8:0]  dataout_h,
//	output   [8:0]  dataout_l,
//	inout   [8:0]  padio
//);

endmodule

		