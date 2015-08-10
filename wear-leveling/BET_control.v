module BET_FSM (
		clk_50,
	  rst,
		block_out
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
          check_flag = 3'd4
          errase_start = 3'd5,
          errase_done = 3'd6;

input clk_50, rst;
input ram_r;

output ram_w, garbage_en;
output [11:0] block_out, garbage_addr, ram_addr;

reg [11:0] f_index,f_index_next;
reg [31:0] e_cnt, f_cnt;


alwats @(posedge clk or negedge rst) begin
        if (rst == 1'b0)
            NS <= cmp_ratio;
        else
            case (S)
                    cmp_ratio:
                    begin
                      if (ratio < T)
                          NS <= cmp_ratio;
                      else
                          cmp_flag_count;
                    end
                    cmp_flag_count:
                    begin
                        if (f_cnt < BET_size) 
                            NS <= find_clear_flag;
                        else
                            NS <= rst_bet;
                    end
                    rst_bet:
                    begin
                        if (count < BET_size + 1) begin
                            count <= count + 1'b1;
                            ram_w_en <= 1'b1;
                            ram_w <= 1'b0;
                            ram_addr <= count;
                        end else begin
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
                            NS <= errase_block;
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
                    default:
                    begin
                        NS <= cmp_ratio;
                    end
            endcase
end

always @ (posedge clk or negedge rst) begin 
        if (rst == 1'b0) begin
                ratio <= 32'd0;
        end else begin
                ratio <= e_cnt / f_cnt;
        end
end
