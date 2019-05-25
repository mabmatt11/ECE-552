/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-04-01 18:01 (Mon, 01 April 2019) $ */
/* $Rev: 01 $ */
module pipe2 (/*OUTPUTS*/
   q_RegWrite_s2,
   q_DMemWrite_s2,
   q_DMemEn_s2,
   q_ALUSrc2_s2,
   q_PCSrc_s2,
   q_PCImm_s2,
   q_MemToReg_s2,
   q_DMemDump_s2,
   q_Jump_s2,
   q_SESel_s2,
   q_readData1_s2,
   q_readData2_s2,
   q_extImm_s2,
   q_jBrAdd_s2,
   q_pcPlus2_out_s2,
   q_writeReg_s2,
   q_instruction_out_s2,
   q_C_in_s2,
   q_Op_s2,
   q_invA_s2,
   q_invB_s2,
   q_branch_s2,
	   
   // Inputs
   clk,
   rst,
   stall_s2,
   RegWrite_s2,
   DMemWrite_s2,
   DMemEn_s2,
   ALUSrc2_s2,
   PCSrc_s2,
   PCImm_s2,
   MemToReg_s2,
   DMemDump_s2,
   Jump_s2,
   SESel_s2,
   readData1_s2,
   readData2_s2,
   extImm_s2,
   jBrAdd_s2,
   pcPlus2_s2,
   writeReg_s2,
   instruction_s2,
   C_in_s2,
   Op_s2,
   invA_s2,
   invB_s2,
   branch_s2,
   currPC_s1,
   Stall4,
   Done4
   );
   
   input clk, rst, stall_s2, Stall4, Done4;
   input RegWrite_s2,DMemWrite_s2,DMemEn_s2,ALUSrc2_s2,PCSrc_s2,PCImm_s2,MemToReg_s2,
		 DMemDump_s2,Jump_s2,C_in_s2,invA_s2,invB_s2,branch_s2;
   input [2:0] SESel_s2,writeReg_s2,Op_s2;
   input [15:0] readData1_s2,readData2_s2,extImm_s2,jBrAdd_s2,instruction_s2,pcPlus2_s2,currPC_s1;
   
   output q_RegWrite_s2,q_DMemWrite_s2,q_DMemEn_s2,q_ALUSrc2_s2,q_PCSrc_s2,q_PCImm_s2,
		  q_MemToReg_s2,q_DMemDump_s2,q_Jump_s2,q_C_in_s2,q_invA_s2,q_invB_s2,q_branch_s2;
   output [2:0] q_SESel_s2,q_writeReg_s2,q_Op_s2;
   output [15:0] q_readData1_s2,q_readData2_s2,q_extImm_s2,q_jBrAdd_s2,q_pcPlus2_out_s2,q_instruction_out_s2;
   
   /*********************
     STAGE TWO PIPELINE
   *********************/
   wire  d_RegWrite_s2,
		 d_DMemWrite_s2,
		 d_DMemEn_s2,
		 d_ALUSrc2_s2,
		 d_PCSrc_s2,
		 d_PCImm_s2,
		 d_MemToReg_s2,
		 d_DMemDump_s2,
		 d_Jump_s2,
		 d_invA_s2,
		 d_invB_s2,
		 d_C_in_s2,
		 d_branch_s2; 
	
    wire [2:0] d_SESel_s2,
			   d_Op_s2,
			   d_writeReg_s2;
    wire [15:0] d_readData1_s2,
				d_readData2_s2,
				d_extImm_s2,
				d_pcPlus2_out_s2,
				d_jBrAdd_s2,
				d_instruction_out_s2;
   
   
   assign d_RegWrite_s2 = (Stall4)   ? q_RegWrite_s2 :
                          (stall_s2) ? 1'b0 :  
                                       RegWrite_s2;

   assign d_DMemWrite_s2 = (Stall4)   ? q_DMemWrite_s2 :
                           (stall_s2) ? 1'b0 :  
                                       DMemWrite_s2;
   
   assign d_DMemEn_s2 = (Stall4)   ? q_DMemEn_s2 :
                        (stall_s2) ? 1'b0 :
                                     DMemEn_s2;
   
   assign d_ALUSrc2_s2 = (Stall4)   ? q_ALUSrc2_s2 :
                         (stall_s2) ? 1'b0         :
                                      ALUSrc2_s2;
   
   assign d_PCSrc_s2 =  (Stall4)   ? q_PCSrc_s2 :
                        (stall_s2) ? 1'b0 : PCSrc_s2;

   assign d_PCImm_s2 =  (Stall4)   ? q_PCImm_s2 :
                        (stall_s2) ? 1'b0 : PCImm_s2;

   assign d_MemToReg_s2 =  (Stall4)   ? q_MemToReg_s2 :
                           (stall_s2) ? 1'b0 : MemToReg_s2;

   assign d_DMemDump_s2 = (Stall4)   ?  q_DMemDump_s2 :
                          (stall_s2) ? 1'b0 : DMemDump_s2;

   assign d_Jump_s2 = (Stall4)   ? q_Jump_s2 :
                      (stall_s2) ? 1'b0 : Jump_s2;

   assign d_SESel_s2 =  (Stall4)   ? q_SESel_s2 :
                        (stall_s2) ? 3'b000 : SESel_s2;

   assign d_readData1_s2 =  (Stall4)   ? q_readData1_s2 :
                            (stall_s2) ? 16'h0000 : readData1_s2;

   assign d_readData2_s2 =  (Stall4)   ? q_readData2_s2 :
                            (stall_s2) ? 16'h0000 : readData2_s2;

   assign d_extImm_s2 = (Stall4)   ? q_extImm_s2 :
                        (stall_s2) ? 16'h0000 : extImm_s2;

   assign d_jBrAdd_s2 = (Stall4)   ? q_jBrAdd_s2 :
                        (stall_s2) ? 16'h0000 : jBrAdd_s2;

   assign d_pcPlus2_out_s2 = (Stall4)   ? q_pcPlus2_out_s2 :
                             (stall_s2) ? currPC_s1 : pcPlus2_s2;

   assign d_writeReg_s2 = (Stall4)   ? q_writeReg_s2 :
                          (stall_s2) ? 3'b000 : writeReg_s2;

   assign d_instruction_out_s2 = (Stall4)   ? q_instruction_out_s2 :
                                 (stall_s2) ? 16'h0800 : instruction_s2;

   assign d_C_in_s2 =   (Stall4)   ? q_C_in_s2 :
                        (stall_s2) ? 1'b0 : C_in_s2;

   assign d_Op_s2 = (Stall4)   ? q_Op_s2 :
                    (stall_s2) ? 3'b000 : Op_s2;

   assign d_invA_s2 = (Stall4)   ? q_invA_s2 :
                      (stall_s2) ? 1'b0 : invA_s2;

   assign d_invB_s2 = (Stall4)   ? q_invB_s2 :
                      (stall_s2) ? 1'b0 : invB_s2;

   assign d_branch_s2 = (Stall4)   ? q_branch_s2 :
                        (stall_s2) ? 1'b0 : branch_s2;
    
   r1_b RegWrite_s2_reg(.q(q_RegWrite_s2), .d(d_RegWrite_s2), .clk(clk), .rst(rst));
   r1_b DMemWrite_s2_reg(.q(q_DMemWrite_s2), .d(d_DMemWrite_s2), .clk(clk), .rst(rst));
   r1_b DMemEn_s2_reg(.q(q_DMemEn_s2), .d(d_DMemEn_s2), .clk(clk), .rst(rst));
   r1_b ALUSrc2_s2_reg(.q(q_ALUSrc2_s2), .d(d_ALUSrc2_s2), .clk(clk), .rst(rst));
   r1_b PCSrc_s2_reg(.q(q_PCSrc_s2), .d(d_PCSrc_s2), .clk(clk), .rst(rst));
   r1_b PCImm_s2_reg(.q(q_PCImm_s2), .d(d_PCImm_s2), .clk(clk), .rst(rst));
   r1_b MemToReg_s2_reg(.q(q_MemToReg_s2), .d(d_MemToReg_s2), .clk(clk), .rst(rst));
   r1_b DMemDump_s2_reg(.q(q_DMemDump_s2), .d(d_DMemDump_s2), .clk(clk), .rst(rst));
   r1_b Jump_s2_reg(.q(q_Jump_s2), .d(d_Jump_s2), .clk(clk), .rst(rst));
   r3_b SESel_s2_reg(.q(q_SESel_s2), .d(d_SESel_s2), .clk(clk), .rst(rst));
   r16_b readData1_s2_reg(.q(q_readData1_s2), .d(d_readData1_s2), .clk(clk), .rst(rst));
   r16_b readData2_s2_reg(.q(q_readData2_s2), .d(d_readData2_s2), .clk(clk), .rst(rst));
   r16_b extImm_s2_reg(.q(q_extImm_s2), .d(d_extImm_s2), .clk(clk), .rst(rst));
   r16_b jBrAdd_s2_reg(.q(q_jBrAdd_s2), .d(d_jBrAdd_s2), .clk(clk), .rst(rst));
   r16_b pcPlus2_s2_reg(.q(q_pcPlus2_out_s2), .d(d_pcPlus2_out_s2), .clk(clk), .rst(rst));
   r3_b writeReg_s2_reg(.q(q_writeReg_s2), .d(d_writeReg_s2), .clk(clk), .rst(rst));
   r16_b instruction_s2_reg(.q(q_instruction_out_s2), .d(d_instruction_out_s2), .clk(clk), .rst(rst));
   r1_b C_in_s2_reg(.q(q_C_in_s2), .d(d_C_in_s2), .clk(clk), .rst(rst));
   r3_b Op_s2_reg(.q(q_Op_s2), .d(d_Op_s2), .clk(clk), .rst(rst));
   r1_b invA_s2_reg(.q(q_invA_s2), .d(d_invA_s2), .clk(clk), .rst(rst));
   r1_b invB_s2_reg(.q(q_invB_s2), .d(d_invB_s2), .clk(clk), .rst(rst));
   r1_b branch_s2_reg(.q(q_branch_s2), .d(d_branch_s2), .clk(clk), .rst(rst));
   
endmodule
