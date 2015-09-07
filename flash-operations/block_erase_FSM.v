module block_erase_FsM (
        // flash chip io
        rb,
        rb2,
        wr,
        ce,
        ce2,
        ale,
        wp,
        dq,
        dqs,
        // controler io
        addr,
        ts,//which target?
        en,
        state,
        clk,
        rst
);
parameter start = 4'd0,
        w_cmd_1 = 4'd1,
        w_addr_1 - 4'd2,
        w_addr_2 = 4'd3,
        w_addr_3 = 4'd4,
        w_cmd_2 = 4'd5,
        check_status = 4'd6,
        done = 4'd7;

input rb,rb2,en,ts;
input [11:0] addr; //the block addr, may be reformated later
output wr, ce,ce2,ale,wp,dqs,state;
output [7:0] dq;

reg s,ns;


always @ (posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
        ce <= 1'b0;
    end else case(s) begin
            case start:
            begin
              if (en == 1'b1)
                  ns <= w_cmd_1;
              else
                  ns <= start;
            end
            case w_cmd_1:
            begin
                dq <= 8'h60;
                ns <= w_addr_1;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 1'b1; 
                ale <= 1'b0;
                // skip clk
                wr <= 1'b0
                dqs <= 1'b0 // dont care
                wp <= 1'b1;
            end
            case w_addr_1:
            begin
                dq <= 8'h00;//page addr is ignored
                ns <= w_addr_2;
                 if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 1'b0;
                ale <= 1'b1;
                // skip clk
                wr <= 1'b1;
                dqs <= 1'b0; // dont care
                wp <= 1'b1
            end
            case w_addr_2:
            begin
                dq <= addr[7:0];//LSB of block addr
                ns <= w_addr_3;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 1'b0; 
                ale <= 1'b1;
                // skip clk
                wr <= 1'b1;
                dqs <= 1'b0; // dont care
                wp <= 1'b1;
            end
            case w_addr_3:
            begin
                dq <= [4'h0, addr[11:8]];
                ns <= w_cmd_2;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 1'b0;
                ale <= 1'b1;
                // skip clk
                wr <= 1'b1;
                dqs <= 1'b0; // dont care
                wp <= 1'b1;
            end
            case w_cmd_2:
            begin
                dq <= 8'hd0;
                ns <= check_status;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 1'b1;
                ale <= 1'b0;
                // skip clk
                wr <= 1'b1;
                dqs <= 1'b0; // dont care
                wp <= 1'b1;
            end
            case check_status:// this will need some work
            begin
                dq <= 8'h70;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 
                ale <= 
                // skip clk
                wr <= 
                dqs <=
                wp <= 
            end
            case done:
            begin
                dq <=  
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 
                ale <= 
                // skip clk
                wr <= 
                dqs <=
                wp <=                    
            end
            default:
            begin
                ns <= start;
                if (ts == 1'b0) begin
                    ce <= 1'b1;
                    ce2 <= 1'b0;
                end else begin
                    ce <= 1'b0;
                    ce2 <= 1'b1;
                end
                cle <= 
                ale <= 
                // skip clk
                wr <= 
                dqs <=
                wp <= 
            end
    endcase
end



always @ (posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
           s <= start;
           ns <= start;
    end else begin
          s <= ns;
    end
end

