/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-04-01 18:01 (Mon, 01 April 2019) $ */
/* $Rev: 01 $ */
module pipe1 (/*OUTPUTS*/
   q_pcPlus2_s1,
   q_instruction_s1,
   d_pcPlus2_s1,
   q_valid_s1,
   
   // Inputs
   clk,
   rst,
   stall_s1,
   stall_s2,
   instruction_s1,
   instruction_s2,
   branch_s2,
   jmp,
   brnch,
   q_keepcurr_s3,
   nop_s2,
   currPC_s1,
   pcPlus2_s1,
   jBrAdd_s2,
   d_keepcurr_s3,
   Stall,
   Done,
   Stall4,
   Done4,
   siic,
   rti
   );
   
   input clk,rst,Stall,Done,Stall4,Done4;
   input stall_s1,stall_s2,jmp,brnch,branch_s2,nop_s2,q_keepcurr_s3,d_keepcurr_s3, siic, rti;
   input [15:0] instruction_s1,instruction_s2,currPC_s1,pcPlus2_s1,jBrAdd_s2;
   output q_valid_s1;
   output [15:0] q_pcPlus2_s1,q_instruction_s1,d_pcPlus2_s1;
   
   /*********************
     STAGE ONE PIPELINE
   *********************/
   wire [15:0] d_instruction_s1;
   wire valid = 1'b1;
   wire [15:0] q_EPC,d_EPC;
   
   assign d_EPC = (siic) ? q_pcPlus2_s1 : q_EPC;
   
   /***********************************************************************************************
    DO NOT TOUCH, 8 HOURS OF SWEAT, BLOOD, AND TEARS WENT INTO THE MAKING OF THIS SINGLE STATEMENT
   ***********************************************************************************************/

    assign d_pcPlus2_s1 = (siic & ~stall_s2) ? 16'h0002 :
						  (rti) ? q_EPC :
						  ((stall_s1 & stall_s2 &  (instruction_s1[15:11] == 5'b11000 | instruction_s1[15:11] == 5'b00000 | instruction_s1[15:11] == 5'b00001 | instruction_s2[15:13] == 3'b011 | instruction_s2[15:11] == 5'b00111 | instruction_s2[15:11] == 5'b00101)) | Stall4 | Stall) ? currPC_s1 :
                          (stall_s1 & stall_s2 & (instruction_s1[15:11] == 5'b00111 | instruction_s1[15:11] == 5'b00101)) ? pcPlus2_s1 :
                          ((((brnch | stall_s1) & branch_s2 & ~stall_s2) | (stall_s1 & jmp)) | q_keepcurr_s3 & (brnch | jmp) & ~nop_s2) ? jBrAdd_s2 :
                          (((stall_s1 | stall_s2) & ~nop_s2) | Stall)         ? currPC_s1 : pcPlus2_s1; 

    assign d_instruction_s1 = (Stall4 | (Stall & branch_s2))                                           ? q_instruction_s1 :
                              ((stall_s1 & ~stall_s2) | (branch_s2 & ~stall_s2)) ? 16'h0800         :
                              ((stall_s2 | d_keepcurr_s3 | (q_valid_s1 & instruction_s2[15:11] == 5'b00000)) & ~nop_s2) ? q_instruction_s1 :
                              (Stall | siic | rti)                                            ? 16'h0800         :    instruction_s1;
    /*********************************************************************************************
    DO NOT TOUCH, 8 HOURS OF SWEAT, BLOOD, AND TEARS WENT INTO THE MAKING OF THIS SINGLE STATEMENT
    **********************************************************************************************/
	r16_b EPC(.q(q_EPC),.d(d_EPC),.clk(clk),.rst(rst));
    r1_b valid_reg(.q(q_valid_s1), .d(valid), .clk(clk), .rst(rst));
    r16_b pcPlus2_s1_reg(.q(q_pcPlus2_s1), .d(d_pcPlus2_s1), .clk(clk), .rst(rst));
    r16_b instruction_s1_reg(.q(q_instruction_s1), .d(d_instruction_s1), .clk(clk), .rst(rst));
	
endmodule
