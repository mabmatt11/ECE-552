/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module stage4 (/*OUTPUTS*/
   // What goes to stage 1 or 2 or 3 or 5?
   err,
   writeData_out,
   Jump_Br,
   RegWrite_out,
   writeReg_out,
   pcPlus2_out,
   DMemDump_out,
   instruction_out,
   Done,
   Stall,
   
   // Inputs
   clk, rst,
   address,
   writeData,
   DMemEn,
   DMemWrite,
   DMemDump_in,
   DMemDump,
   MemToReg,
   Jump_Br_in,
   RegWrite,
   writeReg,
   pcPlus2,
   instruction_in
   //some control logic signals
   );

   input clk, rst, DMemEn, DMemWrite, DMemDump, DMemDump_in, 
         MemToReg, Jump_Br_in, RegWrite;
   input [15:0] address, writeData, pcPlus2, instruction_in;
   input [2:0] writeReg;

   output err, Jump_Br, RegWrite_out, DMemDump_out, Done, Stall;
   output [15:0] writeData_out, pcPlus2_out, instruction_out;
   output [2:0] writeReg_out; 

   wire [15:0] readData;
   wire err_align;
   // FORWARD SIGNALS TO NEXT STAGE
   assign pcPlus2_out = pcPlus2;
   assign RegWrite_out = RegWrite;
   assign writeReg_out = writeReg;
   assign Jump_Br = Jump_Br_in;
   assign DMemDump_out = DMemDump;
   assign instruction_out = instruction_in;
   
   wire CacheHit, Rd;
   // MEMORY
   mem_system #(1) DM(.DataOut(readData),
               .Done(Done),
               .Stall(Stall),
               .CacheHit(CacheHit),
               .DataIn(writeData),
               .Addr(address),
               .Wr(DMemWrite & DMemEn),
               .Rd(DMemEn & ~DMemWrite),
               .createdump(DMemDump_in),
               .clk(clk),.rst(rst),
               .err(err_align));
			   
   assign writeData_out = (MemToReg) ? readData : address;
   
   assign err = (|readData === 1'bx) ? 1'b1 :
                (err_align)          ? 1'b1 :
                                       1'b0;

endmodule
