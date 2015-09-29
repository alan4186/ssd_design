module command_translator (// flash ports
	output clk,
	output reg wr,
	output reg ale,
	output reg cle,
	output reg ce1,
	output reg ce2,
	output reg wp,
	input rb1,
	input rb2,
	// controler ports
	input clock_100,
	input rst,
	input [0:cmd_width_short] cmd,
	output rb1_ctrl,
	output rb2_ctrl,
	input ce,
	// ports to ddr megafunction
	output reg oe
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
	
	

	
	assign clk = clock_100;// pass clock to flash	
	assign rb1_ctrl = rb1;
	assign rb2_ctrl = rb2;

	// posedge block for control signals
	always@(posedge clock_100 or negedge rst)
	begin
		if(rst == 1'b0) 
		begin
		   oe <= 1'b0;
			wr <= 1'bx;
			ale <= 1'bx;
			cle <= 1'bx;
			ce1 <= 1'b1;
			ce2 <= 1'b1;
			wp <= 1'b1;// needs to be cmos high
		end 
	else
	begin
		case (cmd) 
		standby:
		begin
			oe <= 1'b0;
			wr <= 1'bx;
			ale <= 1'bx;
			cle <= 1'bx;
			ce1 <= 1'b1;
			ce2 <= 1'b1;
			wp <= 1'b1;// needs to be cmos high
		end
		bus_idle:
		begin
			oe <= 1'b0;
			wr <= 1'b1; 
			ale <= 1'b0;
			cle <= 1'b0;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'bx;
		end
		bus_driving:
		begin
			oe <= 1'b0;
			wr <= 1'b0;
			ale <= 1'b0;
			cle <= 1'b0;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'bx;
		end
		command_input:
		begin
			oe <= 1'b1;
			wr <= 1'b1;
			ale <= 1'b0;
			cle <= 1'b1;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'b1;
		end
		address_input:
		begin
			oe <= 1'b1;
			wr <= 1'b1;
			ale <= 1'b1;
			cle <= 1'b0;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'b1;
		end
		data_input:
		begin
			oe <= 1'b1;
			wr <= 1'b1;
			ale <= 1'b1;
			cle <= 1'b1;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'b1;
		end
		data_output:
		begin
			oe <= 1'b0;
			wr <= 1'b0;
			ale <= 1'b1;
			cle <= 1'b1;
			ce1 <= ce & 1'b1;
			ce2 <= !ce & 1'b1;
			wp <= 1'bx;
		end
		write_protect:
		begin
			oe <= 1'b0;
			wr <= 1'bx;
			ale <= 1'bx;
			cle <= 1'bx;
			ce1 <= 1'bx;
			ce2 <= 1'bx;
			wp <= 1'b0;
		end
		endcase
	end
	end
	

	endmodule
