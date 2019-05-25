/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module stage1 (/*OUTPUTS*/
   // What goes to stage 2?
   err,
   pcPlus2_out,
   currPC,
   instruction,
   Done,
   Stall,
   // Inputs
   jmp,
   clk, rst,
   jBrAdd,
   pcPlus2_in,
   DMemDump,
   siic,
   rti
   );

   input jmp, clk, rst, DMemDump, siic, rti;
   input [15:0] jBrAdd, pcPlus2_in;

   output err;
   output [15:0] pcPlus2_out, currPC, instruction;
   output Done, Stall;

   // WIRES GO HERE //
   wire [15:0] readAddress;
   wire [15:0] data_in = 16'h0000;
   wire enable = (~jmp & ~siic & ~rti);
   wire wr = 1'b0;
   wire pcCout, err_align;
   wire [15:0] newPC, nextPC;

    // PC DETERMINED BY PC CALCULATED FOR BRANCH/JUMP OR PC + 2
    assign nextPC = pcPlus2_in;
   
    // IF HALT, DO NOT UPDATE PC
    assign newPC = (DMemDump) ? readAddress : nextPC;
   
   //Update PC (16 bit register)
   r16_b currPC_reg(.q(readAddress), .d(newPC), .clk(clk), .rst(rst));

   //Read address from Instruction Memory to get instruction
   wire CacheHit, Rd;
   mem_system #(0) instrucMem(.DataOut(instruction), 
        .Done(Done),
        .Stall(Stall),
        .CacheHit(CacheHit),
   		.DataIn(data_in), 
   		.Addr(readAddress), 
   		.Wr(wr),
        .Rd(enable),
   		.createdump(DMemDump),
   		.clk(clk), .rst(rst),
        .err(err_align));

   //Next PC (PC + 2) from an adder0
   assign currPC = readAddress;
   cla_16b pcAdd2(.A(readAddress), .B(16'h0002), .C_in(1'b0), .S(pcPlus2_out), .C_out(pcCout));
   
   assign err = err_align;
   
endmodule
