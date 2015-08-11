module BET_FSM (
		clk_50,
	   rst,

		// ram (BET) ports
		ram_addr,
		ram_r,
		ram_w,
		ram_w_en,
      // garbage collection ports
      garbage_en,
      garbage_state,
      garbage_addr
);
parameter T = 100;
parameter BET_size = 8192;
parameter cmp_ratio = 3'd0,
          cmp_flag_count = 3'd1,
          rst_bet = 3'd2,
          read_bet = 3'd3,
          check_flag = 3'd4,
          errase_start = 3'd5,
          errase_done = 3'd6;

input clk_50, rst;
input ram_r, garbage_state;

output ram_w, ram_w_en, garbage_en;
output [11:0] garbage_addr, ram_addr;

reg ram_w, ram_w_en, flag, garbage_en;
reg [2:0] NS,S;
reg [11:0] f_index,f_index_next, ram_addr, garbage_addr, count;
reg [31:0] e_cnt, f_cnt,ratio;


always @(posedge clk_50 or negedge rst) begin
        if (rst == 1'b0) begin
				S <= cmp_ratio;
            NS <= cmp_ratio;
				
         end else begin
				S <= NS;
            case (S)
                    cmp_ratio:
                    begin
                      if (ratio < T)
                          NS <= cmp_ratio;
                      else
                          NS <= cmp_flag_count;
                    end
                    cmp_flag_count:
                    begin
                        if (f_cnt < BET_size) 
                            NS <= read_bet;
                        else
                            NS <= rst_bet;
                    end
                    rst_bet:
                    begin
                        if (count <= BET_size) begin
                            count <= count + 1'b1;
                            ram_w_en <= 1'b1;
                            ram_w <= 1'b0;
                            ram_addr <= count;
                        end else begin
									f_cnt <= 32'd0;
									count <= 12'd0;
                           NS <= cmp_ratio;
							 end
						  end
                    read_bet:
                    begin
                        flag <= ram_r;
                        ram_addr <= f_index_next;
                    end
                    check_flag:
                    begin
                        if( flag == 1'b1) begin
                            NS <= read_bet;
                            f_index <= f_index_next;
                            f_index_next <= f_index_next + 1'b1;
                        end else begin
                            NS <= errase_start;
                        end
                    end
                    errase_start:
                    begin
                        garbage_addr <= f_index;
                        if (garbage_state == 1'b0) begin
                            garbage_en <= 1'b1;
                            NS <= errase_done;
                        end else begin
                            garbage_en <= 1'b0;
                            NS <= errase_start;
                        end
                    end
						  errase_done:
						  begin
								if (garbage_state == 1'b1) begin
									NS <= errase_done;
								end else begin
								   NS <= cmp_ratio;
								end
						  end
                    default:
                    begin
                        NS <= cmp_ratio;
                    end
            endcase
				end
end

always @ (posedge clk_50 or negedge rst) begin 
        if (rst == 1'b0) begin
                ratio <= 32'd0;
        end else begin
                ratio <= e_cnt / f_cnt;
        end
end
endmodule