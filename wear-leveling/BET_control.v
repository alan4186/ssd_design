module BET_control (
		clk_50,
	  rst,
	  errase_en,
	 	errase_addr,
		block_out
		// ram (BET) ports
		ram_addr,
		ram_r,
		ram_w,
		ram_w_en,
    // garbage collection ports
    garbage_en,
    garbage_addr
);
parameter T = 100;
parameter BET_size = 8192;
input clk_50, rst;
input errase_en,ram_r;
input [11:0] errase_addr, ram_addr;

output ram_w, garbage_en;
output [11:0] block_out, garbage_addr;

reg [11:0] f_index;
reg [31:0] e_cnt, f_cnt;

assign ram_addr = f_index;

always@(posedge clk or negedge rst) begin
		if(rst ==1'b0) begin
				ram_addr <= 12'd0;
				ram_w <= 1'b0;
				ram_w_en <= 1'b0;
		end else begin
        if( (e_cnt / f_cnt) > T) begin
            if(f_cnt >= BET_size) begin
                f_cnt <= 32'd0;
                e_cnt <= 32'd0;
                f_index <= 12'd0;
                // reset all flags
            end 

            if(f_index_flag ==1'b0) begin// need to read ram
                garbage_en <= 1'b0;
                garbage_addr <= f_index;
                f_index <= f_index + 12'd1;
            end else begin
                // find clean block
                f_index <= f_index + 12'd1;
                // read ram
                f_index_flag <= ram_r;
            end
        end
    end
end

endmodule
