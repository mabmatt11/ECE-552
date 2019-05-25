/* $Author: Garret Huibregtse # */
/* $LastChangedDate: 2019-03-01 18:01 (Fri, 15 March 2019) $ */
/* $Rev: 01 $ */
module controlhazard(/*Outputs*/
    stall_s1,
    stall_s2,
	ExForwarding1,
	ExForwarding2,
	MemExForwarding1,
	MemExForwarding2,
    //Inputs
    IF_inst,
    ID_Rs,
    ID_Rt,
    ID_inst,
    EX_Rd,
    EX_RegWrite,
    EX_inst,
    MEM_Rd,
    MEM_RegWrite,
    Branch,
    Jump,
    invalidOp,
	q_instruction_out_s1,
	q_instruction_out_s2,
	q_instruction_out_s3,
	q_instruction_out_s4
    );
    
    input [2:0] ID_Rs, ID_Rt, EX_Rd, MEM_Rd;
    input EX_RegWrite, MEM_RegWrite, Branch, Jump, invalidOp;
    input [4:0] IF_inst, ID_inst, EX_inst;
	input [15:0] q_instruction_out_s1,q_instruction_out_s2,q_instruction_out_s3,q_instruction_out_s4;
   
    output stall_s1, stall_s2,ExForwarding1,ExForwarding2,MemExForwarding1,MemExForwarding2;
    wire n1, n2, n3, n4, n5, n6, n7;
	wire ExForwarding1Possible,ExForwarding2Possible,MemExForwarding1Possible,MemExForwarding2Possible;
    // XXX Rd, Rs, immediate
    assign n1 = (ID_inst[4:2] == 3'b010) | (ID_inst[4:2] == 3'b101) |
                (ID_inst[4:0] == 5'b10001) | (ID_inst[4:0] == 5'b10011) |
                (ID_inst[4:0] == 5'b11001);
               
    // XXX Rd, Rs, Rt
    assign n2 = (ID_inst[4:0] == 5'b10000) | (ID_inst[4:0] == 5'b10011);
    assign n3 = (ID_inst[4:2] == 3'b110) | (ID_inst[4:2] == 3'b111) | n2;
    
    assign n4 = ~(ID_inst[4:0] == 5'b00100) & ~(ID_inst[4:0] == 5'b00110) & n6 & n7;// & n6 & n7;
    assign n5 = n4 & n3 & n6 & n7;// & n6 & n7;
    assign n6 = ~(ID_inst == 5'b11000);// & ~(EX_inst == 5'b11000);
    assign n7 = ~(ID_inst == 5'b00000); // & ~(ID_inst == 5'b00001);
    assign stall_s1 = /*Branch |*/ Jump;
    assign stall_s2 = ((((ID_Rs == EX_Rd & EX_RegWrite & n4) | (ID_Rt == EX_Rd & EX_RegWrite & n5)) &  ~(ExForwarding1Possible | ExForwarding2Possible)) |
                      (((ID_Rs == MEM_Rd & MEM_RegWrite & n4) | (ID_Rt == MEM_Rd & MEM_RegWrite & n5)) & ~(MemExForwarding1Possible | MemExForwarding2Possible)))
                      & (ID_inst != 5'b00010 & ID_inst != 5'b00011 & ~invalidOp);
					 
			

	/************************************
	         EX-EX FORWARDING
	************************************/
				
	// for input1 instruction 
   /*                  pipe three/stage 4 instruction has register destination from a register          */
   assign ExForwarding1Possible = ((q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15] == 1'b1 | q_instruction_out_s2[15:12] == 4'b0011) & ~(q_instruction_out_s2[15:11] == 5'b10000 | q_instruction_out_s2[15:11] == 5'b10001)) &
   /*     Destination register equals register read for input 1     */
			   (((q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15:13] == 3'b101 | q_instruction_out_s2[15:12] == 4'b1000) & (q_instruction_out_s2[7:5] == q_instruction_out_s1[10:8])) |
   /*     Destination regeister equals register read for input 1 again    */
			   ((q_instruction_out_s2[15:14] == 2'b11 & ~(q_instruction_out_s2[15:11] == 5'b11000)) & (q_instruction_out_s2[4:2] == q_instruction_out_s1[10:8])) |
   /*     Destination register equalts register read for input 1 again for lbi and slbi     */
			   ((q_instruction_out_s2[15:11] == 5'b11000 | q_instruction_out_s2[15:11] == 5'b10010 | q_instruction_out_s2[15:11] == 5'b10011) & (q_instruction_out_s2[10:8] == q_instruction_out_s1[10:8])) |
   /*     Destination register equals register read for input 1 again for jal and jalr        */
			   ((q_instruction_out_s2[15:12] == 4'b0011) & (q_instruction_out_s1[10:8] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s1 is reading a register         */
			   (q_instruction_out_s1[15:13] == 3'b010 | q_instruction_out_s1[15:13] == 3'b101 | q_instruction_out_s1[15:12] == 4'b1000 | q_instruction_out_s1[15:11] == 5'b10011 | (q_instruction_out_s1[15:14] == 2'b11 & ~(q_instruction_out_s1[15:11] == 5'b11000)) | q_instruction_out_s1[15:11] == 5'b10010);
   
    
	// for input2 q_instruction_out_s1
   /*                 pipe three/stage 4 q_instruction_out_s1 has register destination from a register      */
   assign ExForwarding2Possible = ((q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15] == 1'b1 | q_instruction_out_s2[15:12] == 4'b0011) & ~(q_instruction_out_s2[15:11] == 5'b10000 | q_instruction_out_s2[15:11] == 5'b10001)) &
   /*      Destination register equals register read for input 2                   */
			   (((q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15:13] == 3'b101 | q_instruction_out_s2[15:12] == 4'b1000) & (q_instruction_out_s2[7:5] == q_instruction_out_s1[7:5])) |
   /*     Destination regeister equals register read for input 2 again    */
			   ((q_instruction_out_s2[15:14] == 2'b11 & ~(q_instruction_out_s2[15:11] == 5'b11000)) & (q_instruction_out_s2[4:2] == q_instruction_out_s1[7:5])) |
   /*     Destination register equalts register read for input 2 again for lbi and slbi     */
			   ((q_instruction_out_s2[15:11] == 5'b11000 | q_instruction_out_s2[15:11] == 5'b10010 | q_instruction_out_s2[15:11] == 5'b10011) & (q_instruction_out_s2[10:8] == q_instruction_out_s1[7:5])) |
   /*     Destination register equals register read for input 2 again for jal and jalr        */
			   ((q_instruction_out_s2[15:12] == 4'b0011) & (q_instruction_out_s1[7:5] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s1 is reading a register         */
			   (q_instruction_out_s1[15:11] == 5'b11011 | q_instruction_out_s1[15:11] == 5'b11010 | q_instruction_out_s1[15:13] == 3'b111  | q_instruction_out_s1[15:11] == 5'b10011 | q_instruction_out_s1[15:11] == 5'b10000);
   

   	// for input1 instruction 
   /*                  pipe three/stage 4 instruction has register destination  from a register         */
   assign ExForwarding1 = ((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15] == 1'b1 | q_instruction_out_s3[15:12] == 4'b0011) & ~(q_instruction_out_s3[15:11] == 5'b10000 | q_instruction_out_s3[15:11] == 5'b10001)) &
   /*     Destination register equals register read for input 1     */
			   (((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15:13] == 3'b101 | q_instruction_out_s3[15:12] == 4'b1000) & (q_instruction_out_s3[7:5] == q_instruction_out_s2[10:8])) |
   /*     Destination regeister equals register read for input 1 again    */
			   ((q_instruction_out_s3[15:14] == 2'b11 & ~(q_instruction_out_s3[15:11] == 5'b11000)) & (q_instruction_out_s3[4:2] == q_instruction_out_s2[10:8])) |
   /*     Destination register equalts register read for input 1 again for lbi and slbi     */
			   ((q_instruction_out_s3[15:11] == 5'b11000 | q_instruction_out_s3[15:11] == 5'b10010 | q_instruction_out_s3[15:11] == 5'b10011) & (q_instruction_out_s3[10:8] == q_instruction_out_s2[10:8])) |
   /*     Destination register equals register read for input 1 again for jal and jalr        */
			   ((q_instruction_out_s3[15:12] == 4'b0011) & (q_instruction_out_s2[10:8] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s2 is reading a register         */
			   (q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15:13] == 3'b101 | q_instruction_out_s2[15:12] == 4'b1000 | q_instruction_out_s2[15:11] == 5'b10011 | (q_instruction_out_s2[15:14] == 2'b11 & ~(q_instruction_out_s2[15:11] == 5'b11000)) | q_instruction_out_s2[15:11] == 5'b10010);
   
    
	// for input2 q_instruction_out_s2
   /*                 pipe three/stage 4 q_instruction_out_s2 has register destination from a register      */
   assign ExForwarding2 = ((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15] == 1'b1 | q_instruction_out_s3[15:12] == 4'b0011) & ~(q_instruction_out_s3[15:11] == 5'b10000 | q_instruction_out_s2[15:11] == 5'b10001)) &
   /*      Destination register equals register read for input 2                   */
			   (((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15:13] == 3'b101 | q_instruction_out_s3[15:12] == 4'b1000) & (q_instruction_out_s3[7:5] == q_instruction_out_s2[7:5])) |
   /*     Destination regeister equals register read for input 2 again    */
			   ((q_instruction_out_s3[15:14] == 2'b11 & ~(q_instruction_out_s3[15:11] == 5'b11000)) & (q_instruction_out_s3[4:2] == q_instruction_out_s2[7:5])) |
   /*     Destination register equalts register read for input 2 again for lbi and slbi     */
			   ((q_instruction_out_s3[15:11] == 5'b11000 | q_instruction_out_s3[15:11] == 5'b10010 | q_instruction_out_s3[15:11] == 5'b10011) & (q_instruction_out_s3[10:8] == q_instruction_out_s2[7:5])) |
   /*     Destination register equals register read for input 2 again for jal and jalr        */
			   ((q_instruction_out_s3[15:12] == 4'b0011) & (q_instruction_out_s2[7:5] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s2 is reading a register         */
			   (q_instruction_out_s2[15:11] == 5'b11011 | q_instruction_out_s2[15:11] == 5'b11010 | q_instruction_out_s2[15:13] == 3'b111 | q_instruction_out_s2[15:11] == 5'b10011 | q_instruction_out_s2[15:11] == 5'b10000);   
  
  
   /*******************************************
               MEM-EX FORWARDING
   *******************************************/
   
   // for input1 instruction 
   /*                  pipe three/stage 4 instruction has register destination          */
   assign MemExForwarding1Possible = ((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15] == 1'b1 | q_instruction_out_s3[15:12] == 4'b0011) & ~(q_instruction_out_s3[15:11] == 5'b10000)) &
   /*     Destination register equals register read for input 1     */
			   (((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15:13] == 3'b101 | q_instruction_out_s3[15:12] == 4'b1000) & (q_instruction_out_s3[7:5] == q_instruction_out_s1[10:8])) |
   /*     Destination regeister equals register read for input 1 again    */
			   ((q_instruction_out_s3[15:14] == 2'b11 & ~(q_instruction_out_s3[15:11] == 5'b11000)) & (q_instruction_out_s3[4:2] == q_instruction_out_s1[10:8])) |
   /*     Destination register equalts register read for input 1 again for lbi and slbi     */
			   ((q_instruction_out_s3[15:11] == 5'b11000 | q_instruction_out_s3[15:11] == 5'b10010 | q_instruction_out_s3[15:11] == 5'b10011) & (q_instruction_out_s3[10:8] == q_instruction_out_s1[10:8])) |
   /*     Destination register equals register read for input 1 again for jal and jalr        */
			   ((q_instruction_out_s3[15:12] == 4'b0011) & (q_instruction_out_s1[10:8] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s1 is reading a register         */
			   (q_instruction_out_s1[15:13] == 3'b010 | q_instruction_out_s1[15:13] == 3'b101 | q_instruction_out_s1[15:12] == 4'b1000 | q_instruction_out_s1[15:11] == 5'b10011 | (q_instruction_out_s1[15:14] == 2'b11 & ~(q_instruction_out_s1[15:11] == 5'b11000)) | q_instruction_out_s1[15:11] == 5'b10010);
   
    
	// for input2 q_instruction_out_s1
   /*                 pipe three/stage 4 q_instruction_out_s1 has register destination      */
   assign MemExForwarding2Possible = ((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15] == 1'b1 | q_instruction_out_s3[15:12] == 4'b0011) & ~(q_instruction_out_s3[15:11] == 5'b10000)) &
   /*      Destination register equals register read for input 2                   */
			   (((q_instruction_out_s3[15:13] == 3'b010 | q_instruction_out_s3[15:13] == 3'b101 | q_instruction_out_s3[15:12] == 4'b1000) & (q_instruction_out_s3[7:5] == q_instruction_out_s1[7:5])) |
   /*     Destination regeister equals register read for input 2 again    */
			   ((q_instruction_out_s3[15:14] == 2'b11 & ~(q_instruction_out_s3[15:11] == 5'b11000)) & (q_instruction_out_s3[4:2] == q_instruction_out_s1[7:5])) |
   /*     Destination register equalts register read for input 2 again for lbi and slbi     */
			   ((q_instruction_out_s3[15:11] == 5'b11000 | q_instruction_out_s3[15:11] == 5'b10010 | q_instruction_out_s3[15:11] == 5'b10011) & (q_instruction_out_s3[10:8] == q_instruction_out_s1[7:5])) |
   /*     Destination register equals register read for input 2 again for jal and jalr        */
			   ((q_instruction_out_s3[15:12] == 4'b0011) & (q_instruction_out_s1[7:5] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s1 is reading a register         */
			   (q_instruction_out_s1[15:11] == 5'b11011 | q_instruction_out_s1[15:11] == 5'b11010 | q_instruction_out_s1[15:13] == 3'b111  | q_instruction_out_s1[15:11] == 5'b10011 | q_instruction_out_s1[15:11] == 5'b10000);
   

   	// for input1 instruction 
   /*                  pipe three/stage 4 instruction has register destination  from a register         */
   assign MemExForwarding1 = ((q_instruction_out_s4[15:13] == 3'b010 | q_instruction_out_s4[15] == 1'b1 | q_instruction_out_s4[15:12] == 4'b0011) & ~(q_instruction_out_s4[15:11] == 5'b10000)) &
   /*     Destination register equals register read for input 1     */
			   (((q_instruction_out_s4[15:13] == 3'b010 | q_instruction_out_s4[15:13] == 3'b101 | q_instruction_out_s4[15:12] == 4'b1000) & (q_instruction_out_s4[7:5] == q_instruction_out_s2[10:8])) |
   /*     Destination regeister equals register read for input 1 again    */
			   ((q_instruction_out_s4[15:14] == 2'b11 & ~(q_instruction_out_s4[15:11] == 5'b11000)) & (q_instruction_out_s4[4:2] == q_instruction_out_s2[10:8])) |
   /*     Destination register equalts register read for input 1 again for lbi and slbi     */
			   ((q_instruction_out_s4[15:11] == 5'b11000 | q_instruction_out_s4[15:11] == 5'b10010 | q_instruction_out_s4[15:11] == 5'b10011) & (q_instruction_out_s4[10:8] == q_instruction_out_s2[10:8])) |
   /*     Destination register equals register read for input 1 again for jal and jalr        */
			   ((q_instruction_out_s4[15:12] == 4'b0011) & (q_instruction_out_s2[10:8] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s2 is reading a register         */
			   (q_instruction_out_s2[15:13] == 3'b010 | q_instruction_out_s2[15:13] == 3'b101 | q_instruction_out_s2[15:12] == 4'b1000 | q_instruction_out_s2[15:11] == 5'b10011 | (q_instruction_out_s2[15:14] == 2'b11 & ~(q_instruction_out_s2[15:11] == 5'b11000)) | q_instruction_out_s2[15:11] == 5'b10010);
   
    
	// for input2 q_instruction_out_s2
   /*                 pipe three/stage 4 q_instruction_out_s2 has register destination from a register      */
   assign MemExForwarding2 = ((q_instruction_out_s4[15:13] == 3'b010 | q_instruction_out_s4[15] == 1'b1 | q_instruction_out_s4[15:12] == 4'b0011) & ~(q_instruction_out_s4[15:11] == 5'b10000)) &
   /*      Destination register equals register read for input 2                   */
			   (((q_instruction_out_s4[15:13] == 3'b010 | q_instruction_out_s4[15:13] == 3'b101 | q_instruction_out_s4[15:12] == 4'b1000) & (q_instruction_out_s4[7:5] == q_instruction_out_s2[7:5])) |
   /*     Destination regeister equals register read for input 2 again    */
			   ((q_instruction_out_s4[15:14] == 2'b11 & ~(q_instruction_out_s4[15:11] == 5'b11000)) & (q_instruction_out_s4[4:2] == q_instruction_out_s2[7:5])) |
   /*     Destination register equalts register read for input 2 again for lbi and slbi     */
			   ((q_instruction_out_s4[15:11] == 5'b11000 | q_instruction_out_s4[15:11] == 5'b10010 | q_instruction_out_s4[15:11] == 5'b10011) & (q_instruction_out_s4[10:8] == q_instruction_out_s2[7:5])) |
   /*     Destination register equals register read for input 2 again for jal and jalr        */
			   ((q_instruction_out_s4[15:12] == 4'b0011) & (q_instruction_out_s2[7:5] == 3'b111))) &
   /*     pipe two/stage 3 q_instruction_out_s2 is reading a register         */
			   (q_instruction_out_s2[15:11] == 5'b11011 | q_instruction_out_s2[15:11] == 5'b11010 | q_instruction_out_s2[15:13] == 3'b111 | q_instruction_out_s2[15:11] == 5'b10011 | q_instruction_out_s2[15:11] == 5'b10000);    
  
endmodule
