module crc_byte_2_bit2(
  // clock and reset
  input clk, // probably 100 Mhz PLL
  input rst,
 
  input enable, 
  input load,
  input  [7:0] data,
  output shiftout
);
//===========================================================================
// REG/WIRE declarations for internal signals
//===========================================================================
reg [7:0] sr;
reg load_buf;
//===========================================================================
// Assign Statments
//===========================================================================
assign shiftout = sr[7];
//===========================================================================
// parallel in serial out shift register
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    sr <= 8'd0;
  end else begin
    if(enable) begin
      if(load_buf) begin
        sr <= data;
      end else begin
        sr[0] <= 1'd0;
        sr[1] <= sr[0];
        sr[2] <= sr[1];
        sr[3] <= sr[2];
        sr[4] <= sr[3];
        sr[5] <= sr[4];
        sr[6] <= sr[5];
        sr[7] <= sr[6];
      end 
    end // enable
  end // reset
end // always

//===========================================================================
// Buffer load signal for 1 clock cycle
//===========================================================================

always@(posedge clk or negedge rst) begin 
  if(rst == 1'b0)
    load_buf <= 1'b0;
  else
    load_buf <= load;
end // always

endmodule
