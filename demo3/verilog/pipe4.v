/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-04-01 18:01 (Mon, 01 April 2019) $ */
/* $Rev: 01 $ */
module pipe4 (/*OUTPUTS*/
   q_DMemDump_s4,
   q_Jump_Br_s4,
   q_RegWrite_s4,
   q_writeReg_s4,
   q_writeData_s4,
   q_pcPlus2_s4,
   q_instruction_out_s4,
   // Inputs
   clk,
   rst,
   DMemDump_s4,
   Jump_Br_s4,
   RegWrite_s4,
   writeReg_s4,
   writeData_s4,
   pcPlus2_s4,
   instruction_out_s4,
   Stall4,
   Done4,
   MemExForwarding1,
   MemExForwarding2
   );

   input clk, rst, Stall4, Done4;
   input DMemDump_s4, Jump_Br_s4, RegWrite_s4, MemExForwarding1, MemExForwarding2;
   input [2:0] writeReg_s4;
   input [15:0] writeData_s4,pcPlus2_s4,instruction_out_s4;
   
   output q_DMemDump_s4,q_Jump_Br_s4,q_RegWrite_s4;
   output [2:0] q_writeReg_s4;
   output [15:0] q_writeData_s4,q_pcPlus2_s4,q_instruction_out_s4;
   
   /**********************
     STAGE FOUR PIPELINE
   **********************/
   wire d_Jump_Br_s4, d_RegWrite_s4, d_DMemDump_s4;
   wire [2:0] d_writeReg_s4;   
   wire [15:0] d_writeData_s4, d_pcPlus2_s4,d_instruction_out_s4;
   wire mem_forward_stall;
   
   assign mem_forward_stall = ((MemExForwarding1 | MemExForwarding2) & Stall4) ? 1'b1 : 1'b0;

   assign d_DMemDump_s4 = (mem_forward_stall) ? q_DMemDump_s4 :  
						  (Stall4) ? 1'b0 : DMemDump_s4;
   assign d_Jump_Br_s4 = (mem_forward_stall) ? q_Jump_Br_s4 : 
						 (Stall4) ? 1'b0 : Jump_Br_s4;
   assign d_RegWrite_s4 = (mem_forward_stall) ? 1'b0 : 
						  (Stall4) ? 1'b0 : RegWrite_s4;
   assign d_writeReg_s4 = (mem_forward_stall) ? q_writeReg_s4 :
						  (Stall4) ? 3'b000 : writeReg_s4;
   assign d_writeData_s4 = (mem_forward_stall) ? q_writeData_s4 :
						   (Stall4) ? 16'h0000 : writeData_s4;
   assign d_pcPlus2_s4 = (mem_forward_stall) ? q_pcPlus2_s4 :
						 (Stall4) ? 16'h0000 : pcPlus2_s4;
   assign d_instruction_out_s4 = (mem_forward_stall) ? q_instruction_out_s4 :
								 (Stall4) ? 16'h0800 : instruction_out_s4;

   r1_b DMemDump_s4_reg(.q(q_DMemDump_s4), .d(d_DMemDump_s4), .clk(clk), .rst(rst));
   r1_b Jump_Br_s4_reg(.q(q_Jump_Br_s4), .d(d_Jump_Br_s4), .clk(clk), .rst(rst));
   r1_b RegWrite_s4_reg(.q(q_RegWrite_s4), .d(d_RegWrite_s4), .clk(clk), .rst(rst));
   r3_b writeReg_s4_reg(.q(q_writeReg_s4), .d(d_writeReg_s4), .clk(clk), .rst(rst));
   r16_b writeData_s4_reg(.q(q_writeData_s4), .d(d_writeData_s4), .clk(clk), .rst(rst));
   r16_b pcPlus2_s4_reg(.q(q_pcPlus2_s4), .d(d_pcPlus2_s4), .clk(clk), .rst(rst));
   r16_b instruction_out_s4_reg(.q(q_instruction_out_s4), .d(d_instruction_out_s4), .clk(clk), .rst(rst));
   
endmodule
