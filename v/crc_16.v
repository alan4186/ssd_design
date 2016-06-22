module crc_16(
  // clock and reset
  input clk, // probably 100 Mhz PLL
  input rst,
 
  input data_in_buf, 
  input  bit_in,
  output [15:0] crc_value,
  output reg rdreq,
  output reg enable,
  output reg crc_done
);
//===========================================================================
// macro declarations
//===========================================================================

//===========================================================================
// PARAMETER declarations
//===========================================================================
parameter POLYNOMIAL = 16'h8005;
parameter INITIAL_CRC_VALUE = 16'h4f4e;

parameter IDLEDATA = 8'haa; // 8'b10101010

//===========================================================================
// REG/WIRE declarations for internal signals
//===========================================================================
reg [2:0] shift_count;
reg [3:0] so_delay;
reg [15:0] lfsr;

wire shift_enable;
//===========================================================================
// Assign Statments
//===========================================================================
assign crc_value = lfsr;
//assign end_byte = (shift_count == 3'd6) ? 1'b1 : 1'b0;
assign shift_enable = !rdreq;
//===========================================================================
// Compute CRC with LFSR
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    lfsr <= INITIAL_CRC_VALUE;

  end else begin
    case({enable, shift_enable})
      2'b11: begin
        lfsr[0] <= bit_in ^ lfsr[15];
        lfsr[1] <= lfsr[0];
        lfsr[2] <= lfsr[1] ^ bit_in ^ lfsr[15];
        lfsr[3] <= lfsr[2];
        lfsr[4] <= lfsr[3];
        lfsr[5] <= lfsr[4];
        lfsr[6] <= lfsr[5];
        lfsr[7] <= lfsr[6];
        lfsr[8] <= lfsr[7];
        lfsr[9] <= lfsr[8];
        lfsr[10] <= lfsr[9];
        lfsr[11] <= lfsr[10];
        lfsr[12] <= lfsr[11];
        lfsr[13] <= lfsr[12];
        lfsr[14] <= lfsr[13];
        lfsr[15] <= lfsr[14] ^ bit_in ^ lfsr[15];
      end
      2'b10:
        lfsr <= lfsr;
      default: // device not enabled
        lfsr <= INITIAL_CRC_VALUE;
    endcase
  end // reset
end // always


//===========================================================================
// Control signals
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin 
    rdreq <= 1'b0;
    shift_count <= 3'd0;
  end else if(enable) begin
    // incriment counter
    shift_count <= shift_count + 3'd1;
    // set rdreq signal
    if(shift_count == 3'd0)begin
      rdreq <= 1'b1;
    end else begin
      rdreq <= 1'b0;
    end
  end // reset
end // always
//===========================================================================
// Set enable signal
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    enable <= 1'b0;
    so_delay <= 4'd0;
    crc_done <= 1'b0;
  end else begin
    // set enable signal
    if(enable == 1'b1)
      if(so_delay < 4'd8) 
        enable <= 1'b1;
      else
        enable <= 1'b0; 
    else
      enable <= data_in_buf;

    // counter to let the last byte get shifted
    if(data_in_buf)
      so_delay <= 4'd0;
    else 
      so_delay <= so_delay + 4'd1;

    // set crc_done signal
    if(so_delay == 4'd9)
      crc_done <= 1'b1;
    else
      crc_done <= 1'b0;

  end // reset
end // always

endmodule
