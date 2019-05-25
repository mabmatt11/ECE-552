/* $Author: karu, Matt Bachmeier, Garret Huibregtse, Amanda Becker $ */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 46 $ */
module rf_bypass (
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
   
   wire [15:0]   intReadData1, intReadData2;

   /* YOUR CODE HERE */  
   // Instantiation of non-bypassed register file
   rf rf0(
          // Outputs
          .readData1                    (intReadData1[15:0]),
          .readData2                    (intReadData2[15:0]),
          .err                          (err),
          // Inputs
          .clk                          (clk),
          .rst                          (rst),
          .readReg1Sel                  (readReg1Sel[2:0]),
          .readReg2Sel                  (readReg2Sel[2:0]),
          .writeRegSel                  (writeRegSel[2:0]),
          .writeData                    (writeData[15:0]),
          .writeEn                      (writeEn));
		  
	// When same port being read that is being written, read whats written
	// Otherwise, take the normal value from the non-bypasses register file
	assign readData1 = ((readReg1Sel == writeRegSel) & writeEn) ? writeData : 
																  intReadData1;
													  
	assign readData2 = ((readReg2Sel == writeRegSel) & writeEn) ? writeData :
																  intReadData2;

endmodule
