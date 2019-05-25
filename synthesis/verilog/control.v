/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker $ */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 46 $ */
module control (/*AUTOARG*/
                // Outputs
                err, 
                RegDst,
                SESel,
                RegWrite,
                DMemWrite,
                DMemEn,
                ALUSrc2,
                PCSrc,
                MemToReg,
                DMemDump,
                PCImm,
                Jump,
                invA,
                invB,
                C_in,
                Op,
				siic,
				rti,
				invalidOp,
                // Inputs
                OpCode,
                Funct
                );

   // inputs
   input [4:0]  OpCode;
   input [1:0]  Funct;
   
   // outputs
   output       RegWrite, DMemWrite, DMemEn, ALUSrc2, PCSrc, 
                PCImm, MemToReg, DMemDump, Jump, C_in, invA, invB,
                err, siic, rti, invalidOp;
   output [1:0] RegDst;
   output [2:0] SESel, Op;
   
   wire err_opcheck;

   /* YOUR CODE HERE */
   
   assign SESel = (OpCode == 5'b10010)                       ? 3'b001 :
                  (OpCode[4:1] == 4'b0100)                   ? 3'b01x :
                  (OpCode[4:1] == 4'b1000)                   ? 3'b01x :
                  (OpCode == 5'b10011)                       ? 3'b01x :
                  (OpCode[4:2] == 3'b011)                    ? 3'b10x :
                  (OpCode[4:2] == 3'b110)                    ? 3'b10x :
                  ((OpCode[4:2] == 3'b001) &  OpCode[0])     ? 3'b10x :
                  ((OpCode[4:2] == 3'b001) & ~OpCode[0])     ? 3'b11x :
                                                               3'b000;
                              
   assign RegDst =  (OpCode[4:2] == 3'b111)      ? 2'b00 :
                    (OpCode[4:2] == 3'b010)      ? 2'b01 :
                    (OpCode[4:2] == 3'b101)      ? 2'b01 :
                    (OpCode[4:1] == 4'b1000)     ? 2'b01 :
                    (OpCode[4:1] == 4'b1001)     ? 2'b10 :
                    (OpCode == 5'b11000)         ? 2'b10 :
                    (OpCode[4:2] == 3'b001)      ? 2'b11 :
                                                   2'b00;
                                                    
   assign RegWrite =  (OpCode[4:1] == 4'b0010) ? 1'b0 :
                      (OpCode[4:2] == 3'b011)  ? 1'b0 :
                      (OpCode == 5'b10000)     ? 1'b0 :
                      (OpCode[4:2] == 3'b000)  ? 1'b0 :
                                                 1'b1;
   
   assign DMemWrite = (OpCode[4:2] == 3'b100) & ~(OpCode[0] ^ OpCode[1]);
   assign DMemEn = (OpCode[4:2] == 3'b100) & ~(OpCode[1:0] == 2'b10);
   assign ALUSrc2 = (OpCode[4:1] == 4'b1101) ? 1'b1 :
                    (OpCode[4:2] == 3'b111)  ? 1'b1 :
                                               1'b0;
   
   assign PCSrc = (OpCode[4:2] == 3'b011)  ? 1'b1 :
                  (OpCode[4:2] == 3'b001)  ? 1'b1 : 1'b0;
   assign MemToReg = (OpCode == 5'b10001)  ? 1'b1 : 1'b0;
   assign DMemDump = (OpCode == 5'b00000)  ? 1'b1 : 1'b0;
   assign PCImm = ((OpCode[4:2] == 3'b001) &  ~OpCode[0]) ? 1'b1 : 1'b0;
   assign Jump = ((OpCode[4:2] == 3'b001)  &   OpCode[0]) ? 1'b1 : 1'b0;
   
   
   assign invA = (OpCode == 5'b01000)                 ? 1'b1 :
                 (OpCode == 5'b11011 & Funct == 2'b01) ? 1'b1 :
                                                        1'b0;
   assign invB = (OpCode == 5'b01010) ? 1'b1 :
                 (OpCode == 5'b11011 & Funct == 2'b11) ? 1'b1 :
                 (OpCode[4:2] == 3'b111 & OpCode[1:0] != 2'b11) ? 1'b1 :
                 1'b0;
   
   assign C_in = (OpCode == 5'b01000) ? 1'b1 :
                 (OpCode == 5'b11011 & Funct == 2'b01) ? 1'b1 :
                 (OpCode[4:2] == 3'b111 & OpCode[1:0] != 2'b11) ? 1'b1 :
                 1'b0;
   
   assign Op = (OpCode == 5'b10100 | (OpCode == 5'b11010 & Funct == 2'b00)) ? 3'b000 :
               (OpCode == 5'b10101 | (OpCode == 5'b11010 & Funct == 2'b01)) ? 3'b001 :
               (OpCode == 5'b10110 | (OpCode == 5'b11010 & Funct == 2'b10)) ? 3'b010 :
               (OpCode == 5'b10111 | (OpCode == 5'b11010 & Funct == 2'b11)) ? 3'b011 :
               (OpCode[4:2] == 3'b111)                                     ? 3'b100 :
               (OpCode[4:1] == 4'b0100)	                                   ? 3'b100 :
               (OpCode[4:2] == 3'b100 & OpCode[1:0] != 2'b10)              ? 3'b100 :
               (OpCode == 5'b11011 & Funct[1] == 1'b0)                      ? 3'b100 :
			   (OpCode[4:2] == 3'b001)									   ? 3'b100 :
               (OpCode == 5'b01010 | (OpCode == 5'b11011 & Funct == 2'b11)) ? 3'b101 :
               (OpCode == 5'b10010)	                                       ? 3'b110 :
               3'b111;
   
   assign err = err_opcheck;
									 
   assign siic = (OpCode == 5'b00010);
   
   assign rti = (OpCode == 5'b00011);
   
   invalidOpCode invalidOpChecker(.invalidOp(invalidOp),
								  .err(err_opcheck),
								  .Op(OpCode));
   
endmodule
