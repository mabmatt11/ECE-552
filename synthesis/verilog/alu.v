/* $Author: Matt Bachmeier, Garret Huibregtse, Amanda Becker $ */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 46 $ */
module alu (A, B, invA, invB, Op, C_in, Out, Zero, Neg, Ofl, Cout);
   
   input [15:0]  A, B;
   input invA, invB, C_in;
   input [2:0] Op;
   output [15:0]  Out;
   output Ofl, Zero, Neg, Cout;
   
   wire [15:0] n1,n2,n3,n4,n5,AA,BB; // Wires to store possible ALU outputs
   
   assign AA = (invA) ? ~A : A; // Invert A if invA active
   assign BB = (invB) ? ~B : B; // Invert B if invB active
   
   barrelShifter b1 (.In(AA),.Cnt(BB[3:0]),.Op(Op[1:0]),.Out(n1)); // Instantiate barrel shifter
 
   cla_16b b2 (.A(AA),.B(BB),.C_in(C_in),.S(n2),.C_out(Cout)); // Instantiate Adder
   
   and16 b3 (.A(AA),.B(BB),.Out(n3)); // Instantiate 16 bit AND
   or16  b4 (.A(AA),.B(BB),.Out(n4)); // Instantiate 16 bit OR
   xor16 b5 (.A(AA),.B(BB),.Out(n5)); // Instantiate 16 bit XOR
   
   // Select which output for Out
   assign Out = (~Op[2])                   ? n1 :
                (~Op[0] & ~Op[1])          ? n2 :
                (Op[0] & ~Op[1])           ? n3 :
                (~Op[0] & Op[1])           ? n4 :
                (Op[0] & Op[1])            ? n5 :
                Out;
   
   // overflow logic
   assign Ofl = (AA[15] & BB[15] & ~n2[15])  ? 1'b1 :
                (~AA[15] & ~BB[15] & n2[15]) ? 1'b1 :
                1'b0;
   
   assign Zero = ~|Out; // Set Zero signal based on output
   assign Neg = Out[15];
   
endmodule
