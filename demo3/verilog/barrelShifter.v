/* $Author: Matt Bachmeier, Garret Huibregtse $ */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module barrelShifter (In, Cnt, Op, Out);

   // declare constant for size of inputs, outputs (N) and # bits to shift (C)
   parameter   N = 16;
   parameter   C = 4;
   parameter   O = 2;

   input [N-1:0]   In;
   input [C-1:0]   Cnt;
   input [O-1:0]   Op;
   output [N-1:0]  Out;

   wire [N-1:0] n1, n2, n3, n4;
   
   lrotate16 			b1 (.src(In), .amt(Cnt), .res(n1)); // Instantiate Left rotate module
   lshift16  			b2 (.src(In), .amt(Cnt), .res(n2));
   rrotate16            b3 (.src(In), .amt(Cnt), .res(n3));
   rshift16				b4 (.src(In), .amt(Cnt), .res(n4));
  
   /* YOUR CODE HERE */
   assign Out = (~Op[0] & ~Op[1]) ? n1 :
				(Op[0] & ~Op[1])  ? n2 : 
				(~Op[0] & Op[1])  ? n3 :
				(Op[0] & Op[1])   ? n4 :
				Out;
endmodule
