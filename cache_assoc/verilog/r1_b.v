/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module r1_b(q, d, clk, rst);
    
    input d;
    input clk, rst;
    output q;
    
    dff dff0 (.q(q),  .d(d),  .clk(clk), .rst(rst));
    

endmodule
