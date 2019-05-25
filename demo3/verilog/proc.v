/* $Author: karu, Matt Bachmeier, Garret Huibregtse, Amanda Becker $ */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified
    /*****************************************
     WIRES
    *****************************************/
   
   /*******
    STAGE 1
   *******/
   wire err_s1;
   wire [15:0] pcPlus2_s1;
   wire [15:0] instruction_s1;
   wire [15:0] currPC_s1;
   wire Stall_s1, Done_s1;

   /*******
    STAGE 2
   *******/
   wire err_s2;
   wire branch_s2;
   wire RegWrite_s2;
   wire DMemWrite_s2;
   wire DMemEn_s2;
   wire ALUSrc2_s2;
   wire PCSrc_s2;
   wire PCImm_s2;
   wire MemToReg_s2;
   wire DMemDump_s2;
   wire Jump_s2;
   wire [2:0] SESel_s2;
   wire [15:0] readData1_s2;
   wire [15:0] readData2_s2;
   wire [15:0] extImm_s2;
   wire [15:0] jBrAdd_s2;
   wire [15:0] pcPlus2_s2;
   wire [2:0] writeReg_s2;
   wire [15:0] instruction_s2;
   wire [2:0] Op_s2;
   wire invA_s2;
   wire invB_s2;
   wire C_in_s2;
   wire siic;
   wire rti;
   wire invalidOp;
   /*******
    STAGE 3
   *******/
   wire err_s3;
   wire [15:0] ALUout_s3;
   wire [15:0] writeData_s3;
   wire DMemEn_s3;
   wire DMemWrite_s3;
   wire DMemDump_s3;
   wire MemToReg_s3;
   wire Jump_Br_s3;
   wire RegWrite_s3;
   wire [2:0] writeReg_s3;
   wire [15:0] pcPlus2_s3;
   wire keepcurr_s3;
   wire [15:0] instruction_out_s3;
   /*******
    STAGE 4
   *******/
   wire err_s4;
   wire [15:0] writeData_s4;
   wire Jump_Br_s4;
   wire RegWrite_s4;
   wire [2:0] writeReg_s4;
   wire [15:0] pcPlus2_s4;
   wire DMemDump_s4;
   wire [15:0] instruction_out_s4;
   wire Done_s4, Stall_s4;
   /*******
    STAGE 5
   *******/
   wire err_s5;
   wire [15:0]writeData_s5;
   wire Jump_Br_s5;
   wire RegWrite_s5;
   wire [2:0] writeReg_s5;
   wire [15:0] pcPlus2_s5;
   wire DMemDump_s5;
   
   // ERRORS
   assign err = err_s1 | err_s2 | err_s3 | err_s4 | err_s5;
   
   
   /***************************
     STALL AND CONTROL HAZARD 
   ***************************/
   wire stall_s1, stall_s2;
   wire ExForwarding1, ExForwarding2, MemExForwarding1, MemExForwarding2;
   //wire [15:0] ID_R1, ID_R2, EX_RS, EX_RD;
   
   /***************************
     NOP signals from stages
   ***************************/	 
   wire nop_s2, nop_s3, q_nop_s3, d_nop_s3;
   // MAYBE REMOVE s3 ONES! ^^
   
   /*********************
     STAGE ONE PIPELINE
   *********************/
   wire [15:0] q_pcPlus2_s1, q_instruction_s1, d_pcPlus2_s1;
   wire q_valid_s1;
   
   /*********************
     STAGE TWO PIPELINE
   *********************/
   wire  q_RegWrite_s2,
		 q_DMemWrite_s2,
		 q_DMemEn_s2,
		 q_ALUSrc2_s2,
		 q_PCSrc_s2,
		 q_PCImm_s2,
		 q_MemToReg_s2,
		 q_DMemDump_s2,
		 q_Jump_s2,
		 q_invA_s2,
		 q_invB_s2,
		 q_C_in_s2,
		 q_branch_s2; 
	
    wire [2:0] q_SESel_s2,
			   q_Op_s2,
			   q_writeReg_s2;
    wire [15:0] q_readData1_s2,
				q_readData2_s2,
				q_extImm_s2,
				q_pcPlus2_out_s2,
				q_jBrAdd_s2,
				q_instruction_out_s2;
				
   /***********************
     STAGE THREE PIPELINE
   ***********************/	 
   wire q_DMemEn_s3, q_DMemWrite_s3,
        q_DMemDump_s3, q_MemToReg_s3, q_Jump_Br_s3,
        q_RegWrite_s3;
					 
   wire q_keepcurr_s3;
		
   wire [2:0] q_writeReg_s3;
   
   wire [15:0] q_pcPlus2_s3, q_ALUout_s3, q_writeData_s3, q_instruction_out_s3;
   
   /**********************
     STAGE FOUR PIPELINE
   **********************/
   wire q_Jump_Br_s4,q_RegWrite_s4,q_DMemDump_s4;
   
   wire [2:0] q_writeReg_s4;
   
   wire [15:0] q_writeData_s4,q_pcPlus2_s4, q_instruction_out_s4;
   
   // IS THE OUTPUT FROM STAGE ONE A BRANCH OR JUMP
   wire brnch, jmp;
   assign brnch = q_instruction_s1[15:13] == 3'b011;
   assign jmp = q_instruction_s1[15:13] == 3'b001;
   
   
   controlhazard CH(/*Outputs*/
                        //TODO Detect RAW Hazards in each stage//
                        .stall_s1(stall_s1),
                        .stall_s2(stall_s2),
						.ExForwarding1(ExForwarding1),
						.ExForwarding2(ExForwarding2),
						.MemExForwarding1(MemExForwarding1),
						.MemExForwarding2(MemExForwarding2),
                        //Inputs
                        .IF_inst(instruction_s1[15:11]),
                        .ID_Rs(q_instruction_s1[10:8]),
                        .ID_Rt(q_instruction_s1[7:5]),
                        .ID_inst(q_instruction_s1[15:11]),
                        .EX_Rd(q_writeReg_s2),
                        .EX_RegWrite(q_RegWrite_s2),
                        .EX_inst(q_instruction_out_s2[15:11]),
                        .MEM_Rd(writeReg_s4),
                        .MEM_RegWrite(RegWrite_s4),
                        .Branch(brnch),
                        .Jump(jmp),
                        .invalidOp(invalidOp),
						.q_instruction_out_s1(q_instruction_s1),
						.q_instruction_out_s2(q_instruction_out_s2),
						.q_instruction_out_s3(instruction_out_s4),
						.q_instruction_out_s4(q_instruction_out_s4)
                        ); 
   
   
   stage1 s1(/*OUTPUTS*/
             // whatever the outputs from this stage can
             // be used for the next, add wires
             .err(err_s1),
             .pcPlus2_out(pcPlus2_s1),
             .currPC(currPC_s1),
             .instruction(instruction_s1),
             .Done(Done_s1),
             .Stall(Stall_s1),
             /*INPUTS*/
             .jmp(jmp),
             .clk(clk),
             .rst(rst),
             .jBrAdd(q_jBrAdd_s2), // PC <- PC + 2 + imm(sign ext.) OR RS + imm(sign ext.)
             .DMemDump(DMemDump_s5),
             .pcPlus2_in(d_pcPlus2_s1),
			 .siic(siic | invalidOp),
			 .rti(rti)
             // These could possibly be the only inputs
             // Besides nextPC
             // the PC could be created in this stage
             // Input to the PC will have to come here
             );
             
	
   pipe1 p1(/*OUTPUTS*/
			.q_pcPlus2_s1(q_pcPlus2_s1),
			.q_instruction_s1(q_instruction_s1),
			.d_pcPlus2_s1(d_pcPlus2_s1),
            .q_valid_s1(q_valid_s1),
			
			/*INPUTS*/
			.clk(clk),
			.rst(rst),
			.stall_s1(stall_s1),
			.stall_s2(stall_s2),
			.instruction_s1(instruction_s1),
			.instruction_s2(instruction_s2),
			.branch_s2(branch_s2),
			.jmp(jmp),
			.brnch(brnch),
			.q_keepcurr_s3(q_keepcurr_s3),
			.nop_s2(nop_s2),
			.currPC_s1(currPC_s1),
			.pcPlus2_s1(pcPlus2_s1),
			.jBrAdd_s2(jBrAdd_s2),
			.d_keepcurr_s3(keepcurr_s3),
            .Stall(Stall_s1),
            .Done(Done_s1),
            .Stall4(Stall_s4),
            .Done4(Done_s4),
			.siic(siic | invalidOp),
			.rti(rti)
            );


   stage2 s2(/*OUTPUTS*/
             // whatever the outputs from this stage can
             // be used for the next, add wires
             .err(err_s2),
             .RegWrite(RegWrite_s2),
             .DMemWrite(DMemWrite_s2),
             .DMemEn(DMemEn_s2),
             .ALUSrc2(ALUSrc2_s2),
             .PCSrc(PCSrc_s2),
             .PCImm(PCImm_s2),
             .MemToReg(MemToReg_s2),
             .DMemDump(DMemDump_s2),
             .Jump(Jump_s2),
             .SESel(SESel_s2),
             .readData1(readData1_s2),
             .readData2(readData2_s2),
             .extImm(extImm_s2),
             .jBrAdd(jBrAdd_s2),
             .pcPlus2_out(pcPlus2_s2),
             .writeReg_out(writeReg_s2),
             .instruction_out(instruction_s2),
             .C_in(C_in_s2),
             .Op(Op_s2),
             .invA(invA_s2),
             .invB(invB_s2),
             .branch(branch_s2),
             .nop(nop_s2),
			 .siic(siic),
			 .rti(rti),
             .invalidOp(invalidOp),
             /*INPUTS*/
             .clk(clk),
             .rst(rst),
             .instruction(q_instruction_s1),
             .pcPlus2(q_pcPlus2_s1),
             .data(writeData_s5),
             .writeReg_in(writeReg_s5),
             .Jump_Br(Jump_Br_s5),
             .pcPlus2_wb(pcPlus2_s5),
             .RegWrite_in(RegWrite_s5),
             .valid(q_valid_s1)
             // Decode stuff. Inputs will probably be the
             // instruction and pc+2. Lots of muxes
             // control, and register mem here
             ); 
   
   
   pipe2 p2(/*Outputs*/
			.q_RegWrite_s2(q_RegWrite_s2),
			.q_DMemWrite_s2(q_DMemWrite_s2),
			.q_DMemEn_s2(q_DMemEn_s2),
			.q_ALUSrc2_s2(q_ALUSrc2_s2),
			.q_PCSrc_s2(q_PCSrc_s2),
			.q_PCImm_s2(q_PCImm_s2),
			.q_MemToReg_s2(q_MemToReg_s2),
			.q_DMemDump_s2(q_DMemDump_s2),
			.q_Jump_s2(q_Jump_s2),
			.q_SESel_s2(q_SESel_s2),
			.q_readData1_s2(q_readData1_s2),
			.q_readData2_s2(q_readData2_s2),
			.q_extImm_s2(q_extImm_s2),
			.q_jBrAdd_s2(q_jBrAdd_s2),
			.q_pcPlus2_out_s2(q_pcPlus2_out_s2),
			.q_writeReg_s2(q_writeReg_s2),
			.q_instruction_out_s2(q_instruction_out_s2),
			.q_C_in_s2(q_C_in_s2),
			.q_Op_s2(q_Op_s2),
			.q_invA_s2(q_invA_s2),
			.q_invB_s2(q_invB_s2),
			.q_branch_s2(q_branch_s2),
			
			/*INPUTS*/
			.clk(clk),
			.rst(rst),
			.stall_s2(stall_s2),
			.RegWrite_s2(RegWrite_s2),
			.DMemWrite_s2(DMemWrite_s2),
			.DMemEn_s2(DMemEn_s2),
			.ALUSrc2_s2(ALUSrc2_s2),
			.PCSrc_s2(PCSrc_s2),
			.PCImm_s2(PCImm_s2),
			.MemToReg_s2(MemToReg_s2),
			.DMemDump_s2(DMemDump_s2),
			.Jump_s2(Jump_s2),
			.SESel_s2(SESel_s2),
			.readData1_s2(readData1_s2),
			.readData2_s2(readData2_s2),
			.extImm_s2(extImm_s2),
			.jBrAdd_s2(jBrAdd_s2),
			.pcPlus2_s2(pcPlus2_s2),
			.writeReg_s2(writeReg_s2),
			.instruction_s2(instruction_s2),
			.C_in_s2(C_in_s2),
			.Op_s2(Op_s2),
			.invA_s2(invA_s2),
			.invB_s2(invB_s2),
			.branch_s2(branch_s2),
			.currPC_s1(currPC_s1),
            .Stall4(Stall_s4),
            .Done4(Done_s4)
			);
			
   

   stage3 s3(/*OUTPUTS*/
             // whatever the outputs from this stage can
             // be used for the next, add wires
             .err(err_s3),
             .ALUout(ALUout_s3),
             .writeData(writeData_s3),
             .DMemEn_out(DMemEn_s3),
             .DMemWrite_out(DMemWrite_s3),
             .DMemDump_out(DMemDump_s3),
             .MemToReg_out(MemToReg_s3),
             .Jump_Br(Jump_Br_s3),
             .RegWrite_out(RegWrite_s3),
             .writeReg_out(writeReg_s3),
             .pcPlus2_out(pcPlus2_s3),
             .keepcurr(keepcurr_s3), 
             .nop(nop_s3),
			 .instruction_out_s3(instruction_out_s3),
             /*INPUTS*/
             .clk(clk),
             .rst(rst),
             .readData1(q_readData1_s2),
             .readData2(q_readData2_s2),
             .SESel(q_SESel_s2),
             .ALUSrc2(q_ALUSrc2_s2),
             .instruction(q_instruction_out_s2),
             .RegWrite(q_RegWrite_s2),
             .writeReg(q_writeReg_s2),
             .DMemWrite(q_DMemWrite_s2),
             .PCImm(q_PCImm_s2),
             .Jump(q_Jump_s2),
             .MemToReg(q_MemToReg_s2),
             .DMemDump(q_DMemDump_s2),
             .pcPlus2(q_pcPlus2_out_s2),
             .extImm(q_extImm_s2),
             .DMemEn(q_DMemEn_s2),
             .invA(q_invA_s2),
             .invB(q_invB_s2),
             .Op(q_Op_s2),
             .C_in(q_C_in_s2),
             .ExForwarding1(ExForwarding1),
			 .ExForwarding2(ExForwarding2),
			 .q_ALUout_s3(q_ALUout_s3),
			 .MemExForwarding1(MemExForwarding1),
			 .MemExForwarding2(MemExForwarding2),
			 .writeData_s5(writeData_s5),
			 .Jump_Br_s5(Jump_Br_s5),
			 .pcPlus2_s5(pcPlus2_s5)
             // ALU. Will have many different instructions from
             // ALU control which is also done here.
             // Also will get some instruction
             // info for extension stuff. Also sends signal to
             // pc mux
             );
             
   
   pipe3 p3(/*OUTPUT*/
			.q_nop_s3(q_nop_s3),
			.q_keepcurr_s3(q_keepcurr_s3),
			.q_DMemEn_s3(q_DMemEn_s3),
			.q_DMemWrite_s3(q_DMemWrite_s3),
			.q_DMemDump_s3(q_DMemDump_s3),
			.q_MemToReg_s3(q_MemToReg_s3),
			.q_Jump_Br_s3(q_Jump_Br_s3),
			.q_RegWrite_s3(q_RegWrite_s3),
			.q_writeReg_s3(q_writeReg_s3),
			.q_pcPlus2_s3(q_pcPlus2_s3),
			.q_ALUout_s3(q_ALUout_s3),
			.q_writeData_s3(q_writeData_s3),
			.q_instruction_out_s3(q_instruction_out_s3),
			
			/*INPUTS*/
			.clk(clk),
			.rst(rst),
			.nop_s3(nop_s3),
			.keepcurr_s3(keepcurr_s3),
			.DMemEn_s3(DMemEn_s3),
			.DMemWrite_s3(DMemWrite_s3),
			.DMemDump_s3(DMemDump_s3),
			.MemToReg_s3(MemToReg_s3),
			.Jump_Br_s3(Jump_Br_s3),
			.RegWrite_s3(RegWrite_s3),
			.writeReg_s3(writeReg_s3),
			.pcPlus2_s3(pcPlus2_s3),
			.ALUout_s3(ALUout_s3),
			.writeData_s3(writeData_s3),
			.instruction_out_s3(instruction_out_s3),
            .Stall4(Stall_s4),
            .Done4(Done_s4)
			);

   stage4 s4(/*OUTPUTS*/
             // whatever the outputs from this stage can
             // be used for the next, add wires
             .err(err_s4),
             .writeData_out(writeData_s4),
             .Jump_Br(Jump_Br_s4),
             .RegWrite_out(RegWrite_s4),
             .writeReg_out(writeReg_s4),
             .pcPlus2_out(pcPlus2_s4),
             .DMemDump_out(DMemDump_s4),
			 .instruction_out(instruction_out_s4),
             .Stall(Stall_s4),
             .Done(Done_s4),
             
          
             /*INPUTS*/
             .clk(clk),
             .rst(rst),
             .address(q_ALUout_s3),
             .writeData(q_writeData_s3),
             .DMemEn(q_DMemEn_s3),
             .DMemWrite(q_DMemWrite_s3),
             .DMemDump_in(DMemDump_s5),
             .DMemDump(q_DMemDump_s3),
             .MemToReg(q_MemToReg_s3),
             .Jump_Br_in(q_Jump_Br_s3),
             .RegWrite(q_RegWrite_s3),
             .writeReg(q_writeReg_s3),
             .pcPlus2(q_pcPlus2_s3),
			 .instruction_in(q_instruction_out_s3)
             // Memory stage, reading memory. Must be able to 
             // send this output to stage 3 for forwarding
             // in the next phase.
             );

   
   pipe4 p4(/*OUTPUT*/
			.q_DMemDump_s4(q_DMemDump_s4),
			.q_Jump_Br_s4(q_Jump_Br_s4),
			.q_RegWrite_s4(q_RegWrite_s4),
			.q_writeReg_s4(q_writeReg_s4),
			.q_writeData_s4(q_writeData_s4),
			.q_pcPlus2_s4(q_pcPlus2_s4),
			.q_instruction_out_s4(q_instruction_out_s4),
			
			/*INPUTS*/
			.clk(clk),
			.rst(rst),
			.DMemDump_s4(DMemDump_s4),
			.Jump_Br_s4(Jump_Br_s4),
			.RegWrite_s4(RegWrite_s4),
			.writeReg_s4(writeReg_s4),
			.writeData_s4(writeData_s4),
			.pcPlus2_s4(pcPlus2_s4),
			.instruction_out_s4(instruction_out_s4),
            .Stall4(Stall_s4),
            .Done4(Done_s4),
			.MemExForwarding1(MemExForwarding1),
			.MemExForwarding2(MemExForwarding2)
			);
			
   
    
   stage5 s5(/*OUTPUTS*/
             // whatever the outputs from this stage can
             // be used for the next, add wires
             // 
             .err(err_s5),
             .writeData(writeData_s5),
             .Jump_Br(Jump_Br_s5),
             .pcPlus2_out(pcPlus2_s5),
             .RegWrite_out(RegWrite_s5),
             .writeReg_out(writeReg_s5),
             .DMemDump_out(DMemDump_s5),
             
             /*INPUTS*/
             .clk(clk),
             .rst(rst),
             .data(q_writeData_s4),
             .Jump_Br_in(q_Jump_Br_s4),
             .RegWrite(q_RegWrite_s4),
             .writeReg(q_writeReg_s4),
             .pcPlus2(q_pcPlus2_s4),
             .DMemDump(q_DMemDump_s4),
             .instruction(q_instruction_out_s4)
             // Write to memory unit
             );
             
endmodule // proc

// DUMMY LINE FOR REV CONTROL :0:
