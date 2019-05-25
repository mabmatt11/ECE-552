/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module and16(A, B, Out);
    parameter   N = 16;
    
    input  [N-1:0]  A, B;
    output [N-1:0]  Out;

assign Out = A & B;

endmodule

