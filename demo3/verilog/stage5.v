/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module stage5 (/*OUTPUTS*/
   // What goes to stage 1 or 2?
   err,
   writeData,
   Jump_Br,
   RegWrite_out,
   writeReg_out,
   pcPlus2_out,
   DMemDump_out,
   // Inputs
   clk,
   rst,
   data,
   Jump_Br_in,
   RegWrite,
   writeReg,
   pcPlus2,
   DMemDump,
   instruction
   
   //control signals?
   );

   input clk, rst, Jump_Br_in, RegWrite, DMemDump;
   input [15:0] pcPlus2, data, instruction;
   input [2:0] writeReg;

   output err, RegWrite_out, Jump_Br, DMemDump_out;
   output [15:0] writeData, pcPlus2_out;
   output [2:0] writeReg_out;

   // FORWARD SIGNALS TO NEXT STAGE
   assign Jump_Br = Jump_Br_in;
   assign pcPlus2_out = pcPlus2;
   assign RegWrite_out = RegWrite;
   assign writeReg_out = writeReg;
   assign DMemDump_out = DMemDump;
   
   // READ FROM MEM OR USE ALU RESULT
   assign writeData = data;
   assign err = (|writeData === 1'bx) ? 1'b1 : 1'b0;

endmodule
