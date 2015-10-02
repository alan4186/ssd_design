module level_one (
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
	input wire [7:0] cmd,
	output rb1_ctrl,
	output rb2_ctrl,
	input ce,
	// ddr_dq ports
	input   [8:0]  datain_h,
	input   [8:0]  datain_l,
	output   [8:0]  dataout_h,
	output   [8:0]  dataout_l,
	inout   [8:0]  padio
);

parameter cmd_width_short = 7,
			 cmd_width_full = cmd_width_short +1;

wire oe;
//wire [cmd_width_short:0] cmd;

command_translator translator(	
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
	 cmd,
	 rb1_ctrl,
	 rb2_ctrl,
	 1'd0,
	 oe
);

ddr_dq_dq_b6o ddr_dq_a
	( 
	datain_h,
	datain_l,
	dataout_h,
	dataout_l,
	clock_100,//inclock,
	oe,
	clock_100,//outclock,
	padio);
	
endmodule
	