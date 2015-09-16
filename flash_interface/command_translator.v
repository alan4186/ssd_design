module command_translator (
	// flash ports
	dq,
	dqs,
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
	data_ctrl2trans, // data that is input from controler
	data_trans2ctrl,// tata that is read from flash
	dqs_ctrl2trans,
	dqs_trans2ctrl,
	rb1_ctrl,
	rb2_ctrl,
	ce
	);
	parameter cmd_width_short = 7,
				 cmd_width_full = cmd_width_short +1;
				 
	// parameters to define modes
	// i/o names are realative to flash chip
	parameter standby = 3'd0,
				 bus_idle = 3'd1,
				 bus_driving = 3'd2,
				 command_input = 3'd3,
				 address_input = 3'd4,
				 data_input = 3'd5,
				 data_output = 3'd6,
				 write_protect = 3'd7;
	
	// inputs from control
	input clock_100, rst, ce, dqs_ctrl2trans;
	// input/outputs from/to control
	inout [0:cmd_width_short] cmd;
	// outputs to control
	output dqs_trans2ctrl
	// inputs from flash
	input rb1, rb2;
	// input outputs from/ to flash
	inout dqs;
	inout [0:7] = dq;
	// outputs to flash
	output wr, ale, cle, ce1,ce2, wp;
	
	// regs
	
	assign clk = clock_100;// pass clock to flash	
	assign rb1_ctrl = rb1;
	assign rb2_ctrl = rb2;

	// assigns for inouts
			// will either be feedback or data from flash
	assign data_trans2ctrl = dq;
	always@(*)
	begin
		case(data_ctrl2trans)
			begin 
			case command_input:
				dq <= data_ctrl2trans;
			case address_input:
				dq <= data_ctrl2trans;
			case data_input:
				dq <= data_ctrl2trans;
			default
			   dq <= h'zz;
			endcase
	end
	
	assign dqs_trans2ctrl = dqs;
        assign dqs = (state == bus_drive || state == data_output) ? 1'bz : dqs_ctrl2trans;

	// posedge block for control signals
	always@(posedge clock_100 or negedge rst)
	begin
		if(rst == 1'b0) begin
		
	end 
	else
	begin
		case (cmd)
		begin 
		case standby:
		begin
			wr <= 1'bx;
			ale <= 1'bx;
			cle <= 1'bx;
			ce1 <= 1'b1;
			ce2 <= 1'b1;
			wp <= 1'b
		end
		case bus_idle:
		begin
			wr <= 1'b1; 
			ale <= 1'b0;
			cle <= 1'b0;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'bx;
		end
		case bus_driving:
		begin
			wr <= 1'b0;
			ale <= 1'b0;
			cle <= 1'b0;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'bx;
		end
		case command_input:
		begin
			wr <= 1'b1;
			ale <= 1'b0;
			cle <= 1'b1;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'b1;
		end
		case address_input:
		begin
			wr <= 1'b1;
			ale <= 1'b1;
			cle <= 1'b0;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'b1;
		end
		case data_input:
		begin
			wr <= 1'b1;
			ale <= 1'b1;
			cle <= 1'b1;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'b1;
		end
		case data_output:
		begin
			wr <= 1'b0;
			ale <= 1'b1;
			cle <= 1'b1;
			ce1 <= ce | 1'b1;
			ce2 <= !ce | 1'b1;
			wp <= 1'bx;
		end
		case write_protect:
		begin
			wr <= 1'bx;
			ale <= 1'bx;
			cle <= 1'bx;
			ce1 <= 1'bx;
			ce2 <= 1'bx;
			wp <= 1'b0;
		end
		endcase
	end
	
	// posedge and negedge block for ddr i/o
	// for now, assume that the same clk drives
	// flash and control logic.
	
	// dq and dqs are defined as 
	// inputs for dont care states
//	always@(posedge clock_100 or negedge rst, clock_100)
//	begin
//		if (rst == 1'b0)
//		begin
//		
//		end
//		else
//		begin
//			case (cmd)
//			begin 
//			case standby:
//			begin
//				dq
//				dqs
//			end
//			case bus_idle:
//			begin
//				dq
//				dqs
//			end
//			case bus_driving:
//			begin
//				dq;
//				dqs		
//			end
//			case command_input:
//			begin
//				dq
//				dqs	
//			end
//			case address_input:
//			begin
//				dq
//				dqs
//			end
//			case data_input:
//			begin
//				dq 
//				dqs
//			end
//			case data_output:
//			begin
//				dq;
//				dqs 	
//			end
//			case write_protect:
//			begin
//				dq
//				dqs
//			end
//			endcase
//		end
//	end
//	
	endmodule
