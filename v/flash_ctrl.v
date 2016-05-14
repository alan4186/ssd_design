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
  output req_core_data, // read request signal to data fifo
  output output_dval, // signal to indicate flash_q should be latched
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
  output [7:0] flash_data, // write data

);
//===========================================================================
// PARAMETER declarations
//===========================================================================

// chip modes for state machine
parameter STANDBY = 0;
parameter BUSIDLE = 1;
parameter COMMAND_INPUT = 2;
parameter ADDRESS_INPUT = 3;
parameter DATA_INPUT = 4;
parameter DATA_OUTPUT_0 = 5;
parameter DATA_OUTPUT_1 = ;
parameter DATA_OUTPUT_END_0 = ;
parameter DATA_OUTPUT_END_1 = ;
parameter WRITE_PROTECT = ;

// idle patern for DQ dont care states
parameter IDLEDATA = 8'haa; // 8'b10101010

//=============================================================================
// REG/WIRE declarations
//=============================================================================









//=============================================================================
// Assign Statments
//=============================================================================

assign flash_mode // = instruction[????];
assign repeat_counter // = instruction[????];







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
          state <= BUSIDLE;
      BUSIDLE_0:
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
    oWP_N <= // either or?
    // <= iRB_N;
    <= flash_q; IDLEDATA;
    // flash_data <=
    data_oe <= 1'b0; 
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
        oWP_N <= // either or? see datasheet
        <= iRB_N;
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b0; // dont care
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      BUSIDLE: begin 
        oCE_N <= 1'b0;
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1;
        oRE_N <= 1'b1;
        oWP_N <= // dont care
        <= iRB_N; 
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b0; // dont care 
        req_core_data <= 1'b0;
        output_dval <= 1'b0;
      end
      COMMAND_INPUT_0: begin
        oCE_N <= 1'b0;
        oCLE <= 1'b1;
        oALE <= 1'b0;
        oWE_N <= 1'b0; 
        oRE_N <= 1'b1;
        oWP_N <= 1'b1; // H
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_ouput;
        data_oe <= 1'b1
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= core_data_output;
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b1;
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <=
        data_oe <= 1'b1;
        req_core_data <= 1'b0;
        output_dval <= 1'b1;
      end
      WRITE_PROTECT: begin 
        oCE_N <= 1'b1; // dont care
        oCLE <= 1'b0; // dont care
        oALE <= 1'b0; // dont care
        oWE_N <= 1'b1; // dont care
        oRE_N <= 1'b1; // dont care
        oWP_N <= 1'b0;
        <= iRB_N; 
//        <= flash_q;
        flash_data <= 
        data_oe <= 1'b0
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
        <= iRB_N; 
//        <= flash_q;
        flash_data <= IDLEDATA;
        data_oe <= 1'b0;
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


endmodule
