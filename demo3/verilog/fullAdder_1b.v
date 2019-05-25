/*
    CS/ECE 552 Spring '19
    Homework #3, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S);//, P_out, G_out);
    input  A, B; // inputs
    input  C_in;
    output S; // sum

    assign S = A ^ B ^ C_in;


endmodule
