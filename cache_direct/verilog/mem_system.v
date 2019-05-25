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

   wire [15:0] FSM_Addr, FSM_Data_In, mem_data_out;
   wire FSM_Hit, comp, wr, rd, write, enable, FSM_stall, mem_stall,
        mem_err, cache_err, FSM_err, valid, dirty, hit;
   wire valid_in = 1'b1;
   wire [4:0] tag_out;
   wire [2:0] mem_offset, cache_offset;
   wire [3:0] busy;
   wire memtocache, cachetomem, fsm_hit, fsm_valid;
   wire [15:0] cache_data_in, mem_data_in, mem_addr;
   assign cache_data_in = (memtocache) ? mem_data_out : FSM_Data_In;
   assign mem_data_in = (cachetomem) ? DataOut : FSM_Data_In;
   assign mem_addr = (cachetomem) ? {tag_out, FSM_Addr[10:3], cache_offset} : {FSM_Addr[15:3], mem_offset};
   assign Stall = mem_stall | FSM_stall;
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out),
                          .data_out             (DataOut),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (cache_err),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (FSM_Addr[15:11]),
                          .index                (FSM_Addr[10:3]),
                          .offset               (cache_offset),
                          .data_in              (cache_data_in),
                          .comp                 (comp),
                          .write                (write),
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
   assign err = mem_err | cache_err | FSM_err;

   cache_dir_FSM FSM(
            /*Oututs*/
            .Done(Done),
            .err(FSM_err),
            .enable(enable),
            .comp(comp),
            .write(write),
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
            /*Inputs*/
            .stall(mem_stall),
            .busy(busy),
            .hit(hit),
            .valid(valid),
            .dirty(dirty),
            .clk(clk),
            .rst(rst),
            .Addr(Addr),
            .data_in(DataIn),
            .Rd(Rd),
            .Wr(Wr),
            .tag_out(tag_out)
            );


endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
