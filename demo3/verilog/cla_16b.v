/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    
    a 16-bit RCA module
*/
module cla_16b(A, B, C_in, S, C_out);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    input [N-1: 0] A, B;
    input          C_in;
    output [N-1:0] S;
    output         C_out;

    wire p0,p1,p2;
	wire g0,g1,g2;
	wire c1,c2,c3;
	//wire b0,b1,b2;
	
	wire P_out,G_out;
	
    // YOUR CODE HERE
   /* cla_4b a1 (.A(A[3:0]),.B(B[3:0]),.C_in(C_in),.S(S[3:0]),.C_out(i0));
    cla_4b a2 (.A(A[7:4]),.B(B[7:4]),.C_in(i0),.S(S[7:4]),.C_out(i1));
    cla_4b a3 (.A(A[11:8]),.B(B[11:8]),.C_in(i1),.S(S[11:8]),.C_out(i2));
    cla_4b a4 (.A(A[15:12]),.B(B[15:12]),.C_in(i2),.S(S[15:12]),.C_out(C_out));
	*/
	cla_4b a1 (.A(A[3:0]),.B(B[3:0]),.C_in(C_in),.S(S[3:0]),.P_out(p0),.G_out(g0));
    cla_4b a2 (.A(A[7:4]),.B(B[7:4]),.C_in(c1),.S(S[7:4]),.P_out(p1),.G_out(g1));
    cla_4b a3 (.A(A[11:8]),.B(B[11:8]),.C_in(c2),.S(S[11:8]),.P_out(p2),.G_out(g2));
    cla_4b a4 (.A(A[15:12]),.B(B[15:12]),.C_in(c3),.S(S[15:12]),.P_out(P_out),.G_out(G_out));

	assign c1 = g0 | (p0 & C_in);
	assign c2 = g1 | (p1 & c1);
	assign c3 = g2 | (p2 & c2);
	assign C_out = G_out | (P_out & c3);
	
	/*
	and2		 an1(.A(p0),.B(C_in),.out(b0)); //c1=g0 + p0*cin
	or2			 o1 (.A(g0),.B(b0),.out(c1));
	
	and2		 an2(.A(p1),.B(c1),.out(b1)); //c2=g1 + p1*c1
	or2			 o2 (.A(g1),.B(b1),.out(c2));
	
	and2		 an3(.A(p2),.B(c2),.out(b2)); //c3=g2 + p2*c2
	or2			 o3 (.A(g2),.B(b2),.out(c3));
	
	and2		 an4(.A(P_out),.B(c3),.out(b3)); //c4=g3 + p3*c3
	or2			 o4 (.A(G_out),.B(b3),.out(C_out));
	*/

endmodule
