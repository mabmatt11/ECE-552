/* $Author: karu, Garret Huibregtse, Matt Bachmeier, Amanda Becker $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );

   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;

   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   wire FSM_Hit, comp, wr, rd, write0, write1, enable0, enable1, FSM_stall, mem_stall, c0_data, c1_data,
        mem_err, cache_err0, cache_err1, FSM_err, valid0, valid1, dirty0, dirty1, hit0, hit1,
        memtocache, cachetomem, fsm_hit, fsm_valid;
   wire valid_in = 1'b1;
   wire [4:0] tag_out0, tag_out1;
   wire [2:0] mem_offset, cache_offset;
   wire [3:0] busy;
   wire [15:0] cache_data_in, mem_data_in, mem_addr, DataOut0, DataOut1, FSM_Addr, FSM_Data_In, mem_data_out;


   assign DataOut = (c0_data) ? DataOut0 : (c1_data) ? DataOut1 : 16'h0000;
   assign cache_data_in = (memtocache) ? mem_data_out : FSM_Data_In;
   assign mem_data_in = (cachetomem) ? ((enable0) ? DataOut0 : DataOut1) : FSM_Data_In;
   assign mem_addr = (cachetomem) ? {((enable0) ? tag_out0 : tag_out1), FSM_Addr[10:3], cache_offset} : {FSM_Addr[15:3], mem_offset};
   assign Stall = mem_stall | FSM_stall;
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   

   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out0),
                          .data_out             (DataOut0),
                          .hit                  (hit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (cache_err0),
                          // Inputs
                          .enable               (enable0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (FSM_Addr[15:11]),
                          .index                (FSM_Addr[10:3]),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (write0),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out1),
                          .data_out             (DataOut1),
                          .hit                  (hit1),
                          .dirty                (dirty1),
                          .valid                (valid1),
                          .err                  (cache_err1),
                          // Inputs
                          .enable               (enable1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (FSM_Addr[15:11]),
                          .index                (FSM_Addr[10:3]),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (write1),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (mem_data_out),
                     .stall             (mem_stall),
                     .busy              (busy),
                     .err               (mem_err),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (mem_data_in),
                     .wr                (wr),
                     .rd                (rd));


   // your code here
 //  assign CacheHit = valid & hit;//fsm_hit & fsm_valid;
   assign err = mem_err | cache_err0 | cache_err1 | FSM_err;

   cache_assoc_FSM FSM(
            /*Oututs*/
            .Done(Done),
            .err(FSM_err),
            .enable0(enable0),
            .enable1(enable1),
            .comp(comp),
            .write0(write0),
            .write1(write1),
            .wr(wr),
            .rd(rd),
   			.q_addr(FSM_Addr),
            .q_data_in(FSM_Data_In),
            .cache_offset(cache_offset),
            .mem_offset(mem_offset),
            .memtocache(memtocache),
            .cachetomem(cachetomem),
            .fsm_stall(FSM_stall),
            .cachehit(CacheHit),
            .c0_data(c0_data),
            .c1_data(c1_data),
            /*Inputs*/
            .stall(mem_stall),
            .busy(busy),
            .hit0(hit0),
            .hit1(hit1),
            .valid0(valid0),
            .valid1(valid1),
            .dirty0(dirty0),
            .dirty1(dirty1),
            .clk(clk),
            .rst(rst),
            .Addr(Addr),
            .data_in(DataIn),
            .Rd(Rd),
            .Wr(Wr),
            .tag_out0(tag_out0),
            .tag_out1(tag_out1)
            );


endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
