/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module rshift16(src, amt, res);

input [15:0] src;
input [3:0] amt;

output [15:0] res;

wire [15:0] sh0, sh1, sh2;


assign sh0 = amt[0] ? {1'h0, src[15:1]} : src;
assign sh1 = amt[1] ? {2'h0, sh0[15:2]} : sh0;
assign sh2 = amt[2] ? {4'h0, sh1[15:4]} : sh1;
assign res = amt[3] ? {8'h0, sh2[15:8]} : sh2;



endmodule 
