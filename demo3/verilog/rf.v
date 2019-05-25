/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module rf (
            // Outputs
            readData1, readData2, err,
            // Inputs
            clk, rst, readReg1Sel, readReg2Sel, writeRegSel, writeData, writeEn
            );
   
    input        clk, rst;
    input [2:0]  readReg1Sel;
    input [2:0]  readReg2Sel;
    input [2:0]  writeRegSel;
    input [15:0] writeData;
    input        writeEn;

    output [15:0] readData1;
    output [15:0] readData2;
    output        err;
   
    
    /* YOUR CODE HERE */
    wire [15:0] q0, q1, q2, q3, q4, q5, q6, q7;
    wire [15:0] d0, d1, d2, d3, d4, d5, d6, d7;
    
    // == logic
    wire d00, d11, d22, d33, d44, d55, d66, d77; 
    
    r16_b r0(.q(q0), .d(d0), .clk(clk), .rst(rst)),
          r1(.q(q1), .d(d1), .clk(clk), .rst(rst)),
          r2(.q(q2), .d(d2), .clk(clk), .rst(rst)),
          r3(.q(q3), .d(d3), .clk(clk), .rst(rst)),
          r4(.q(q4), .d(d4), .clk(clk), .rst(rst)),
          r5(.q(q5), .d(d5), .clk(clk), .rst(rst)),
          r6(.q(q6), .d(d6), .clk(clk), .rst(rst)),
          r7(.q(q7), .d(d7), .clk(clk), .rst(rst));
   
    // == logic
    assign d00 = (writeRegSel == 3'h0) ? 1'b1 : 1'b0;
    assign d11 = (writeRegSel == 3'h1) ? 1'b1 : 1'b0;
    assign d22 = (writeRegSel == 3'h2) ? 1'b1 : 1'b0;
    assign d33 = (writeRegSel == 3'h3) ? 1'b1 : 1'b0;
    assign d44 = (writeRegSel == 3'h4) ? 1'b1 : 1'b0;
    assign d55 = (writeRegSel == 3'h5) ? 1'b1 : 1'b0;
    assign d66 = (writeRegSel == 3'h6) ? 1'b1 : 1'b0;
    assign d77 = (writeRegSel == 3'h7) ? 1'b1 : 1'b0;
    assign d0 = (d00 & writeEn) ? writeData : q0;
    assign d1 = (d11 & writeEn) ? writeData : q1;
    assign d2 = (d22 & writeEn) ? writeData : q2;
    assign d3 = (d33 & writeEn) ? writeData : q3;
    assign d4 = (d44 & writeEn) ? writeData : q4;
    assign d5 = (d55 & writeEn) ? writeData : q5;
    assign d6 = (d66 & writeEn) ? writeData : q6;
    assign d7 = (d77 & writeEn) ? writeData : q7;
         
    
    // == logic
    assign readData1 = (readReg1Sel == 3'h0) ? q0 :
                       (readReg1Sel == 3'h1) ? q1 :
                       (readReg1Sel == 3'h2) ? q2 :
                       (readReg1Sel == 3'h3) ? q3 :
                       (readReg1Sel == 3'h4) ? q4 :
                       (readReg1Sel == 3'h5) ? q5 :
                       (readReg1Sel == 3'h6) ? q6 :
                                               q7;
    assign readData2 = (readReg2Sel == 3'h0) ? q0 :
                       (readReg2Sel == 3'h1) ? q1 :
                       (readReg2Sel == 3'h2) ? q2 :
                       (readReg2Sel == 3'h3) ? q3 :
                       (readReg2Sel == 3'h4) ? q4 :
                       (readReg2Sel == 3'h5) ? q5 :
                       (readReg2Sel == 3'h6) ? q6 :
                                               q7;

    assign err = (|writeData === 1'bx)    ? 1'b1 : //readReg1Sel, readReg2Sel, writeRegSel
                 (writeEn === 1'bx)       ? 1'b1 :
                 (readReg1Sel === 1'bx)   ? 1'b1 :
                 (readReg2Sel === 1'bx)   ? 1'b1 :
                 (writeRegSel === 1'bx)   ? 1'b1 :
                                            1'b0;
    
    
endmodule
