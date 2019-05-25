/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module stage2 (/*OUTPUTS*/
   // What goes to stage 3 and 4 and 5?
   err,
   RegWrite,
   DMemWrite,
   DMemEn,
   ALUSrc2,
   PCSrc,
   PCImm,
   MemToReg,
   DMemDump,
   Jump,
   SESel,
   readData1,
   readData2,
   extImm,
   pcPlus2_out,
   jBrAdd,
   writeReg_out,
   instruction_out,
   C_in,
   Op,
   invA,
   invB,
   branch,
   nop,
   siic,
   rti,
   invalidOp,
   // Inputs
   clk, rst,
   instruction,
   pcPlus2,
   pcPlus2_wb,
   data,
   writeReg_in,
   Jump_Br,
   RegWrite_in,
   valid
   );

   input clk, rst, RegWrite_in, Jump_Br, valid;
   input [15:0] instruction, pcPlus2, pcPlus2_wb, data;
   input [2:0] writeReg_in;

   output err, RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc,
          PCImm, MemToReg, DMemDump, Jump, invA, invB, C_in,
          branch, nop, siic, rti, invalidOp;	
   output [2:0]  SESel, Op, writeReg_out;	
   output [15:0] readData1, readData2, extImm, pcPlus2_out, jBrAdd, instruction_out;
   // WIRES GO HERE //
		
    wire err1, err2, jBCout;
    wire [2:0]  writeReg_out; //should this be commented out?
    wire [1:0] RegDst;
    wire [15:0] dataWrite, jAdd;
    wire Zero, Neg, br, DMemDump_int;
    
    // forwarding info to next stage
    assign instruction_out = instruction;
    assign pcPlus2_out = pcPlus2;
    assign nop = (instruction[15:11] == 5'b00001);
   //control Logic
   control CL(.OpCode(instruction[15:11]),
              .Funct(instruction[1:0]), // END Inputs
              .err(err1),              // START OUTPUTS
              .RegDst(RegDst),
              .SESel(SESel),
              .RegWrite(RegWrite),
              .DMemWrite(DMemWrite),
              .DMemEn(DMemEn),
              .ALUSrc2(ALUSrc2),
              .PCSrc(PCSrc),
              .PCImm(PCImm),
              .MemToReg(MemToReg),
              .DMemDump(DMemDump_int),
              .Jump(Jump),
              .invA(invA),
              .invB(invB),
              .C_in(C_in),
              .Op(Op),
			  .siic(siic),
			  .rti(rti),
              .invalidOp(invalidOp));			   // END OUTPUTS
   assign DMemDump = DMemDump_int & valid;
	
    // REGISTER WRITTEN TO BY WB (STAGE 5)
	assign writeReg_out = (RegDst == 2'b00) ? instruction[4:2]  :  // Set write register based on control
                          (RegDst == 2'b01) ? instruction[7:5]  :
                          (RegDst == 2'b10) ? instruction[10:8] :
                                              3'b111;
										  
	assign dataWrite = (Jump_Br) ? pcPlus2_wb : data; // set write data based on control
	
    //REGISTERS
    rf_bypass RM(.clk(clk),
                .rst(rst),
                .readReg1Sel(instruction[10:8]),
                .readReg2Sel(instruction[7:5]),
                .writeRegSel(writeReg_in),
                .writeData(dataWrite),
                .writeEn(RegWrite_in),				// END Inputs
                .readData1(readData1),			// START Outputs
                .readData2(readData2),
                .err(err2)); 					// END OUTPUTS
	
	
    //sign extend and zero extend things
	assign extImm = (SESel == 3'b000)  ? {{11{1'b0}},instruction[4:0]}           :
                    (SESel == 3'b001)  ? {{8{1'b0}},instruction[7:0]}            :
                    (SESel[2:1] == 2'b01) ? {{11{instruction[4]}},instruction[4:0]} :
                    (SESel[2:1] == 2'b10) ? {{8{instruction[7]}},instruction[7:0]}  :
                                         {{5{instruction[10]}},instruction[10:0]};
                                        
   assign Zero = ~|readData1;
   assign Neg = readData1[15];
                                        
   assign br =  (instruction[12:11] == 5'b00) ? ~Zero :
                (instruction[12:11] == 5'b01) ? Zero  :
                (instruction[12:11] == 5'b10) ? Neg   :
                (instruction[12:11] == 5'b11) ? ~Neg  :
                                                1'b0;
   assign branch = br & (instruction[15:13] == 3'b011);
   assign jAdd = (Jump) ? readData1 : pcPlus2;
   
    // CALCULATE THE POTENTIAL BRANCH/JUMP PC
    cla_16b branchJumpAdd(.A(jAdd),.B(extImm),.C_in(1'b0),.S(jBrAdd),.C_out(jBCout));
   
    // Set err based on modules in stage2
    assign err = err1 | err2;

endmodule
