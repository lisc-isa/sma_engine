`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MPRC, EECS, Peking University
// Engineer: Dong Tong
// 
// Create Date:    12:50:27 04/15/2019 
// Design Name: 	 LISC_processor
// Module Name:    SMA_engine 
// Project Name: 	 LISC
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SMA_engine #(
  parameter WORD_WIDTH = 64,
  parameter BSIZE_WIDTH = 6,
  parameter LENGTH_WIDTH = 4,
  parameter PTR_WIDTH = 48
  )(
  input wire [2:0] access_type,
  input wire [WORD_WIDTH-1:0] tagged_pointer,
  input wire [WORD_WIDTH-1:0] increment,
  output reg [WORD_WIDTH-1:0] sma_address,
  output reg overflow,
  output reg underflow
  );

  wire [BSIZE_WIDTH-1:0] b_size;
  wire [LENGTH_WIDTH-1:0] l_size;
  wire [PTR_WIDTH-1:0] ptr;
  
  wire [WORD_WIDTH-1:0] lower_bound_temp;
  wire [WORD_WIDTH-1:0] upper_bound_temp;
  wire [WORD_WIDTH-1:0] lower_bound_mask;
  wire [WORD_WIDTH-1:0] access_type_mask;
  
  wire [WORD_WIDTH-1:0] ptr_lower_bound;
  wire [WORD_WIDTH-1:0] ptr_upper_bound;
  wire [WORD_WIDTH-1:0] ptr_increment;
  wire [WORD_WIDTH-1:0] last_address;
   
  assign b_size = tagged_pointer[WORD_WIDTH - 1: WORD_WIDTH - BSIZE_WIDTH];
  assign l_size = tagged_pointer[WORD_WIDTH - BSIZE_WIDTH - 1 : WORD_WIDTH - BSIZE_WIDTH - LENGTH_WIDTH];
  assign ptr = { {(WORD_WIDTH - PTR_WIDTH){1'b0}}, tagged_pointer[WORD_WIDTH - 1 : 0]};
  
  assign lower_bound_mask = {{(WORD_WIDTH){1'b1}} << (b_size + 4)};
  assign ptr_lower_bound = ptr & lower_bound_mask;
  assign upper_bound_temp = l_size << b_size;
  assign ptr_upper_bound = ptr_lower_bound | upper_bound_temp;
  assign access_type_mask = {(WORD_WIDTH){1'b1}} << access_type;
  assign ptr_increment = ptr + increment;
  assign last_address = (ptr_upper_bound -1) & access_type_mask;
  
  always @*
  begin
    underflow = 0;
    overflow  = 0;
    sma_address = ptr_increment;
		
    if (ptr_increment < ptr_lower_bound) begin
      underflow = 1;
      sma_address = ptr_lower_bound;
    end
		
    if (ptr_increment > last_address) begin
      overflow = 1;
      sma_address = last_address;
    end
  end

endmodule
