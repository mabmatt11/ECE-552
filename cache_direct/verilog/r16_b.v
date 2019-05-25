/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module r16_b(q, d, clk, rst);
    
    input [15:0] d;
    input clk, rst;
    output [15:0] q;
    
    dff dff0 (.q(q[0]),  .d(d[0]),  .clk(clk), .rst(rst)),
        dff1 (.q(q[1]),  .d(d[1]),  .clk(clk), .rst(rst)),
        dff2 (.q(q[2]),  .d(d[2]),  .clk(clk), .rst(rst)),
        dff3 (.q(q[3]),  .d(d[3]),  .clk(clk), .rst(rst)),
        dff4 (.q(q[4]),  .d(d[4]),  .clk(clk), .rst(rst)),
        dff5 (.q(q[5]),  .d(d[5]),  .clk(clk), .rst(rst)),
        dff6 (.q(q[6]),  .d(d[6]),  .clk(clk), .rst(rst)),
        dff7 (.q(q[7]),  .d(d[7]),  .clk(clk), .rst(rst)),
        dff8 (.q(q[8]),  .d(d[8]),  .clk(clk), .rst(rst)),
        dff9 (.q(q[9]),  .d(d[9]),  .clk(clk), .rst(rst)),
        dff10(.q(q[10]), .d(d[10]), .clk(clk), .rst(rst)),
        dff11(.q(q[11]), .d(d[11]), .clk(clk), .rst(rst)),
        dff12(.q(q[12]), .d(d[12]), .clk(clk), .rst(rst)),
        dff13(.q(q[13]), .d(d[13]), .clk(clk), .rst(rst)),
        dff14(.q(q[14]), .d(d[14]), .clk(clk), .rst(rst)),
        dff15(.q(q[15]), .d(d[15]), .clk(clk), .rst(rst));
    

endmodule
