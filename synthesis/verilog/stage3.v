/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module stage3 (/*OUTPUTS*/
   // What goes to stage 1 or 2 or 4 or 5?
   err,
   ALUout,
   RegWrite_out,
   DMemWrite_out,
   DMemEn_out,
   MemToReg_out,
   DMemDump_out,
   Jump_Br, 
   writeData,
   writeReg_out,
   pcPlus2_out,
   keepcurr,
   nop,
   instruction_out_s3,
   // Inputs
   clk, rst,
   readData1,
   readData2,
   SESel,
   instruction,
   writeReg,
   RegWrite, 
   DMemWrite,
   DMemEn,
   ALUSrc2,
   PCImm,
   MemToReg,
   DMemDump,
   Jump,
   pcPlus2,
   extImm,
   invA,
   invB,
   Op,
   C_in,
   ExForwarding1,
   ExForwarding2,
   q_ALUout_s3,
   MemExForwarding1,
   MemExForwarding2,
   writeData_s5,
   pcPlus2_s5,
   Jump_Br_s5
   //Many control logic outputs
   );

   input clk;
   input rst;
   input [15:0] readData1,readData2, extImm, pcPlus2, instruction,q_ALUout_s3,writeData_s5,pcPlus2_s5;
   input [2:0] SESel, writeReg, Op;
   input RegWrite, DMemWrite, DMemEn, ALUSrc2, PCImm, MemToReg,
         DMemDump, Jump, invA, invB, C_in,ExForwarding1,ExForwarding2,MemExForwarding1,MemExForwarding2,Jump_Br_s5;

   output [15:0] ALUout, writeData, pcPlus2_out,instruction_out_s3;
   output [2:0] writeReg_out;
   output RegWrite_out, DMemWrite_out, DMemEn_out,
          MemToReg_out, DMemDump_out, Jump_Br,
          err, keepcurr, nop; 
		  
   wire [15:0] SLBIinput,MemExForwardData;
    
   // FORWARD SIGNALS TO NEXT STAGE
   assign pcPlus2_out = pcPlus2;
   assign writeReg_out = writeReg;
   assign writeData = (ExForwarding2 & (instruction[15:11] == 5'b10011 | instruction[15:11] == 5'b10000)) ? q_ALUout_s3 : 
					  (MemExForwarding2 & (instruction[15:11] == 5'b10011 | instruction[15:11] == 5'b10000)) ? MemExForwardData : readData2;
   assign RegWrite_out = RegWrite;
   assign DMemWrite_out = DMemWrite;
   assign DMemEn_out = DMemEn;
   assign MemToReg_out = MemToReg;
   assign DMemDump_out = DMemDump;
   assign Jump_Br = Jump | PCImm;
   assign instruction_out_s3 = instruction;
   assign keepcurr = (instruction[15:12] == 4'b0011);
   assign nop = instruction[15:11] == 5'b00001;
   // WIRES GO HERE //
   wire [15:0] SLBIshifted, input1, input2, imALUout, m1;
   wire Zero, Neg, Cout, Ofl, lessThan;
   
   
   
   assign MemExForwardData = (Jump_Br_s5) ? pcPlus2_s5 : writeData_s5;

   
   assign SLBIinput = (ExForwarding1) ? q_ALUout_s3 : 
					  (MemExForwarding1) ? MemExForwardData : readData1; 
   // SLBI shifted value
   lshift16 SLBIshift(.src(SLBIinput),.amt(4'b1000),.res(SLBIshifted)); //SLBI lshift by 8
   
   
   assign input1 = (ExForwarding1 & (SESel != 3'b001) & ~PCImm) ? /*write data from pipe3*/q_ALUout_s3 :
				   (MemExForwarding1 & (SESel != 3'b001) & ~PCImm) ? MemExForwardData :
				   (PCImm)			 ?     pcPlus2 :
				   (SESel == 3'b001) ? SLBIshifted : 
										  readData1;         //SLBI chosen on when SESel is 1
										  
   assign input2 = (ExForwarding2 & (ALUSrc2 == 1'b1)) ? /*write data from pipe3*/q_ALUout_s3 :
				   (MemExForwarding2 & (ALUSrc2 == 1'b1)) ? MemExForwardData :
				   (ALUSrc2 == 1'b1) ? readData2 : extImm;				//When ALUSrc2 is 1, use read data
     
   alu ALU(.A(input1), 
           .B(input2), 
           .invA(invA), 
           .invB(invB), 
           .C_in(C_in), 
           .Op(Op), 
           .Out(imALUout), 
           .Zero(Zero), 
           .Neg(Neg), 
           .Ofl(Ofl), 
           .Cout(Cout));
   
   // BTR value
   mirror BTR(.in(input1),.out(m1)); //BTR instruction outside of ALU
   
   // LOGIC FOR CHECKING LESS THAN
   assign lessThan = (~Neg & Ofl) | (Neg & ~Ofl);
   
   assign ALUout =  (instruction[15:11] == 5'b11001) ? m1                             :
                    (instruction[15:11] == 5'b11000) ? extImm                         :
                    (instruction[15:11] == 5'b11100) ? {{15{1'b0}}, Zero}             :
                    (instruction[15:11] == 5'b11101) ? {{15{1'b0}}, lessThan}         :
                    (instruction[15:11] == 5'b11110) ? {{15{1'b0}}, lessThan | Zero}  :
                    (instruction[15:11] == 5'b11111) ? {{15{1'b0}},Cout}              :
                                                       imALUout;

   assign err = 0;
endmodule
