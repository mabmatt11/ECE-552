/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module r3_b(q, d, clk, rst);
    
    input [2:0] d;
    input clk, rst;
    output [2:0] q;
    
    dff dff0 (.q(q[0]),  .d(d[0]),  .clk(clk), .rst(rst)),
        dff1 (.q(q[1]),  .d(d[1]),  .clk(clk), .rst(rst)),
        dff2 (.q(q[2]),  .d(d[2]),  .clk(clk), .rst(rst));
    

endmodule
