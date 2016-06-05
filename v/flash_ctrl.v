module flash_ctrl(
  // clock and reset
  input clk, // probably 80 Mhz PLL
  input rst,
  
  // state machine variable
  input [31:0] state,

  // inout direction variable
  output data_oe,

  // core side 
  input [7:0] core_data_out, // data coming from core module
  output [7:0] core_data_in, // data going to core module
  input [31:0] instruction,  
  input data_rdy,  // the (probably inverted) read_empty signal from the data fifo
  output ack_mode_read, // the read request signal for show ahead fifo with flash mode commands
  output req_core_data, // read request signal to data fifo
  output output_dval, // signal to indicate flash_q should be latched
  output flash_rdy,
 
  // flash control signals
  output oCE_N,
  output oCLE,
  output oALE,
  output oWE_N, 
  output oRE_N,
  output oWP_N,
  input iRB_N,

  // flash data/flash_q buses, inouts are in top level module
  input [7:0] flash_q,  // read data
  output [7:0] flash_data // write data

);
//===========================================================================
// macro declarations
//===========================================================================
`define countWidth 12

//===========================================================================
// PARAMETER declarations
//===========================================================================

// chip modes for state machine
parameter STANDBY_0 = 0;
parameter STANDBY_1 = 8;
parameter BUS_IDLE_0 = 1;
parameter BUS_IDLE_1 = 9;
parameter COMMAND_INPUT_0 = 2;
parameter COMMAND_INPUT_1 = 10;
parameter ADDRESS_INPUT_0 = 3;
parameter ADDRESS_INPUT_1 = 11;
parameter DATA_INPUT_0 = 4;
parameter DATA_INPUT_1 = 12;
parameter DATA_OUTPUT_0 = 5;
parameter DATA_OUTPUT_1 = 13;
parameter DATA_OUTPUT_END_0 = 6;
parameter DATA_OUTPUT_END_1 = 14;
parameter WRITE_PROTECT_0 = 7;
parameter WRITE_PROTECT_1 = 15;

// idle patern for DQ dont care states
parameter IDLEDATA = 8'haa; // 8'b10101010

//=============================================================================
// REG/WIRE declarations
//=============================================================================









//=============================================================================
// Assign Statments
//=============================================================================

assign flash_mode = instruction[7:0]; // 8 bits
assign repeat_counter = instruction[19:8]; // 12 bits

// control ack_mode_read based on the repeat counter and the flash's R/B_n
// signal
assign ack_mode_read = ( iRB_n && (c == `countWidth'd0) ) ? mode_done : 1'd0;

assign flash_rdy = iRB_n;



//=============================================================================
// Determine next state/ flahs_mode 
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    state <= STANDBY_0;
  end else begin
    case(state)
      STANDBY_0:
        if(iq_empty)
          state <= STANDBY_0
        else
          state <= BUS_IDLE;
      BUS_IDLE_0:
          if(iq_empty)
            state <= STANDBY_0;
          else
            state <= flash_mode;
      COMMAND_INPUT_0:
        if(data_rdy)
          state <= COMMAND_INPUT_1;
        else
          state <= COMMAND_INPUT_0;
      COMMAND_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      ADDRESS_INPUT_0:
        if(data_rdy)
          state <= ADDRESS_INPUT_1;
        else
          state <= ADDRESS_INPUT_0;
      ADDRESS_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      DATA_INPUT_0:
        if(data_rdy)
          state <= DATA_INPUT_1;
        else
          state <= DATA_OUTPUT_0;
      DATA_INPUT_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      DATA_OUTPUT_0:
        if(data_rdy)
          state <= DATA_OUTPUT_1;
        else
          state <= DTAT_OUTPUT_0;
      DATA_OUTPUT_1:
        if(last_data_output)
          state <= DATA_OUTPUT_END_0;
        else
          state <= DATA_OUTPUT_0;
      DATA_OUTPUT_END_0: 
        if(data_rdy)
          state <= DATA_OUTPUT_END_1;
        else
          state <= DTAT_OUTPUT_END_0;
      DATA_OUTPUT_END_1:
        if(iq_empty)
          state <= STANDBY_0;
        else
          state <= flash_mode;
      WRITE_PROTECT_0:
      default:
        state <= WRITE_PROTECT; // write protect should be the safest state
    endcase
  end// rst
end // always



//=============================================================================
// Set outputs based on state/ flash mode
//===========================================================================

always@(posedge clk or negedge rst) begin 
  if(rst == 1'b0) begin
    // put flash in STANDBY
    oCE_N <= 1'b1;
    oCLE <= 1'b0;
    oALE <= 1'b0;
    oWE_N <= 1'b1;
    oRE_N <= 1'b1;
    oWP_N <= 1'b1; // CMOS HIGH (Vccq), see datasheet
     <= iRB_N;
    // <= flash_q;
    flash_data <= IDLEDATA
    data_oe <= 1'b0; 
    mode_done <= 1'b0;
    req_core_data <= 1'b0;
    output_dval <= 1'b0;
  end else begin
    case(state)
      STANDBY_0: begin
        oCE_N <= 1'b1;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= 1'b1; // CMOS HIGH (Vccq) see datasheet
//        <= iRB_N;
//        <= flash_q;
        flash_data <= IDLEDATA;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      STANDBY_1: begin
        oCE_N <= 1'b1;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= 1'b1; // CMOS HIGH (Vccq), see datasheet
//        <= iRB_N;
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; // dont care
        mode_done <= 1'b0; 
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      BUS_IDLE_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; // dont care 
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      BUS_IDLE_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0; // dont care 
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      COMMAND_INPUT_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b1;
        oALE <= 1'b0;
        oWE_N <= 1'b0; 
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // HIGH
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      COMMAND_INPUT_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b1;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b1; // make a read request because the last byte was just read
        output_dval <= 1'b0;
      end
     ADDRESS_INPUT_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b1;
        oWE_N <= 1'b0;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end  
      ADDRESS_INPUT_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b1;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1;
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_ouput;
        data_oe <= 1'b1
        mode_done <= 1'b0;
        req_core_data <= 1'b1;
        output_dval <= 1'b0;
      end   
      DATA_INPUT_0: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b0;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      DATA_INPUT_1: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b1; // make a read request because the last byte was just read
        output_dval <= 1'b0;
      end
      DATA_OUTPUT_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      DATA_OUTPUT_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b0;
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b1;
      end
      DATA_OUTPUT_END_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      DATA_OUTPUT_END_1: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b0;
        oALE <= 1'b0;
        oWE_N <= 1'b1;
        oRE_N <= 1'b1; // leave this high so more data is not output
        oWP_N <= 1'b1; // dont care
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b1;
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b1;
      end
      WRITE_PROTECT_0: begin 
        oCE_N <= 1'b1; // dont care
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= 1'b0;
//        <= iRB_N; 
//        <= flash_q;
        flash_data <=  IDLEDATA;
        data_oe <= 1'b0
        mode_done <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      WRITE_PROTECT_1: begin 
        oCE_N <= 1'b1; // dont care
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= 1'b0;
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0
        mode_done <= 1'b0;
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      default: begin  // STANDBY
        oCE_N <= 1'b1;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= // either or?
//        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0;
        mode_done <= 1'b0; // if an unknown state is entered the FSM will stay in that state
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
    endcase
  end // rst
end // always block


//===========================================================================
// Latch Output Data
//===========================================================================

// this may need to be done in the cpu/ core module
// otherwise it will take an extra clock cycle.
always@(posedge clk or negedge rst) begin
  if(rst == 1'b0)
    core_data_in <= IDLEDATA;
  else if(output_dval)
    core_data_in <= flash_q;
  else
    core_data_in <= IDLEDATA;
end // always


//===========================================================================
// Repeat Mode command logic
//===========================================================================

always@(posedge clk or negedge rst) begin
  if(rst == 1'b0) begin
    c <= `countWidth'd0;
    new_mode <= 1'b0;
  end else begin
    // buffer ack mode read signal with new mode
    // new mode indicates the mode command is different from last clk cycle
    if(ack_mode_read)
      new_mode <= 1'b1;
    else
      new_mode <= 1'b0;

    // update the counter
    if(new_mode)
      c <= repeat_counter;
    else if(mode_done & (c > `countWidth'd0) )
      c <= c - 1'd1;
    else
      c <= c;

  end // rst
end // always (repeat logic)

endmodule
