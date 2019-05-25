/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-04-01 18:01 (Mon, 01 April 2019) $ */
/* $Rev: 01 $ */
module pipe3 (/*OUTPUTS*/
   q_nop_s3,
   q_keepcurr_s3,
   q_DMemEn_s3,
   q_DMemWrite_s3,
   q_DMemDump_s3,
   q_MemToReg_s3,
   q_Jump_Br_s3,
   q_RegWrite_s3,
   q_writeReg_s3,
   q_pcPlus2_s3,
   q_ALUout_s3,
   q_writeData_s3,
   q_instruction_out_s3,
   
   // Inputs
   clk,
   rst,
   nop_s3,
   keepcurr_s3,
   DMemEn_s3,
   DMemWrite_s3,
   DMemDump_s3,
   MemToReg_s3,
   Jump_Br_s3,
   RegWrite_s3,
   writeReg_s3,
   pcPlus2_s3,
   ALUout_s3,
   writeData_s3,
   instruction_out_s3,
   Stall4,
   Done4
   );

   input clk,rst,Stall4,Done4;
   input nop_s3,keepcurr_s3,DMemEn_s3,DMemWrite_s3,DMemDump_s3,MemToReg_s3,Jump_Br_s3,RegWrite_s3;
   input [2:0] writeReg_s3;
   input [15:0] pcPlus2_s3,ALUout_s3,writeData_s3,instruction_out_s3;
   
   output q_nop_s3,q_keepcurr_s3,q_DMemEn_s3,q_DMemWrite_s3,q_DMemDump_s3,q_MemToReg_s3,q_Jump_Br_s3,q_RegWrite_s3;
   output [2:0] q_writeReg_s3;
   output [15:0] q_pcPlus2_s3,q_ALUout_s3,q_writeData_s3,q_instruction_out_s3;
   
   /***********************
     STAGE THREE PIPELINE
   ***********************/
   wire d_DMemEn_s3, d_DMemWrite_s3,
        d_DMemDump_s3, d_MemToReg_s3, d_Jump_Br_s3,
        d_RegWrite_s3;		
   wire [2:0] d_writeReg_s3;
   wire [15:0] d_pcPlus2_s3, d_ALUout_s3, d_writeData_s3, d_instruction_out_s3;


   assign d_DMemEn_s3 = (Stall4) ? q_DMemEn_s3 : DMemEn_s3;
   assign d_DMemWrite_s3 = (Stall4) ? q_DMemWrite_s3 : DMemWrite_s3;
   assign d_DMemDump_s3 = (Stall4) ? q_DMemDump_s3 : DMemDump_s3;
   assign d_MemToReg_s3 = (Stall4) ? q_MemToReg_s3 : MemToReg_s3;
   assign d_Jump_Br_s3 = (Stall4) ? q_Jump_Br_s3 : Jump_Br_s3;
   assign d_RegWrite_s3 = (Stall4) ? q_RegWrite_s3 : RegWrite_s3;
   assign d_writeReg_s3 = (Stall4) ? q_writeReg_s3 : writeReg_s3;
   assign d_pcPlus2_s3 = (Stall4) ? q_pcPlus2_s3 : pcPlus2_s3;
   assign d_ALUout_s3 = (Stall4) ? q_ALUout_s3 : ALUout_s3;
   assign d_writeData_s3 = (Stall4) ? q_writeData_s3 : writeData_s3;
   assign d_keepcurr_s3 = (Stall4) ? q_keepcurr_s3 : keepcurr_s3;
   assign d_nop_s3 = (Stall4) ? q_nop_s3 : nop_s3;
   assign d_instruction_out_s3 = (Stall4) ? q_instruction_out_s3 : instruction_out_s3;

   r1_b nop_s3_reg(.q(q_nop_s3), .d(d_nop_s3), .clk(clk), .rst(rst));
   r1_b keepcurr_s3_reg(.q(q_keepcurr_s3), .d(d_keepcurr_s3), .clk(clk), .rst(rst));
   r1_b DMemEn_s3_reg(.q(q_DMemEn_s3), .d(d_DMemEn_s3), .clk(clk), .rst(rst));
   r1_b DMemWrite_s3_reg(.q(q_DMemWrite_s3), .d(d_DMemWrite_s3), .clk(clk), .rst(rst));
   r1_b DMemDump_s3_reg(.q(q_DMemDump_s3), .d(d_DMemDump_s3), .clk(clk), .rst(rst));
   r1_b MemToReg_s3_reg(.q(q_MemToReg_s3), .d(d_MemToReg_s3), .clk(clk), .rst(rst));
   r1_b Jump_Br_s3_reg(.q(q_Jump_Br_s3), .d(d_Jump_Br_s3), .clk(clk), .rst(rst));
   r1_b RegWrite_s3_reg(.q(q_RegWrite_s3), .d(d_RegWrite_s3), .clk(clk), .rst(rst));
   r3_b writeReg_s3_reg(.q(q_writeReg_s3), .d(d_writeReg_s3), .clk(clk), .rst(rst));
   r16_b pcPlus2_s3_reg(.q(q_pcPlus2_s3), .d(d_pcPlus2_s3), .clk(clk), .rst(rst));
   r16_b ALUout_s3_reg(.q(q_ALUout_s3), .d(d_ALUout_s3), .clk(clk), .rst(rst));
   r16_b writeData_s3_reg(.q(q_writeData_s3), .d(d_writeData_s3), .clk(clk), .rst(rst));
   r16_b instruction_out_s3_reg(.q(q_instruction_out_s3), .d(d_instruction_out_s3), .clk(clk), .rst(rst));
endmodule
