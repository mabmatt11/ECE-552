/* $Author: karu, Garret Huibregtse, Matt Bachmeier, Amanda Becker $ */
/* $Rev: 77 $ */

module cache_dir_FSM(/*Oututs*/
            Done,
            err,
            enable,
            comp,
            write,
            wr,
            rd,
            q_addr,
            q_data_in,
            cache_offset,
            mem_offset,
            memtocache,
            cachetomem,
            fsm_stall,
            cachehit,
            /*Inputs*/
            stall,
            busy,
            hit,
            valid,
            dirty,
            clk,
            rst,
            Addr,
            data_in,
            Rd,
            Wr,
            tag_out
            );
             
    input stall, hit, valid, dirty, clk, rst, Rd, Wr;
    input [3:0] busy;
    input [4:0] tag_out;
    input [15:0] data_in, Addr;
    output reg fsm_stall, cachehit, cachetomem, memtocache, rd, wr, write, comp, enable, err, Done;
    output reg [2:0] cache_offset, mem_offset;
    output [15:0] q_addr, q_data_in;
    //output q_hit, q_valid;

    wire [3:0] state;
    reg [3:0] next_state;
             
    parameter   IDLE = 4'h0,
                COMPRD = 4'h1,
                COMPWR = 4'h2,
                WB0 = 4'h3,
                WB1 = 4'h4,
                WB2 = 4'h5,
                WB3 = 4'h6,
                RDMB0 = 4'h7,
                RDMB1 = 4'h8,
                RDMB2WRMB0 = 4'h9,
                RDMB3WRMB1 = 4'hA,
                WRMB2 =  4'hB,
                WRMB3  = 4'hC,
                DONE = 4'hD,
                ERROR = 4'hE;

    // Propogating original wr/rd signals through fsm
    wire q_Rd, q_Wr, d_Rd, d_Wr, d_hit, d_valid;
    assign d_Wr = (state == IDLE) ? Wr: q_Wr;
    assign d_Rd = (state == IDLE) ? Rd: q_Rd;
    r1_b Wr_reg(.q(q_Wr), .d(d_Wr), .clk(clk), .rst(rst));
    r1_b Rd_reg(.q(q_Rd), .d(d_Rd), .clk(clk), .rst(rst));

    // Address breakdown propogation
    wire [15:0] d_addr;
    assign d_addr = (state == IDLE) ? Addr : q_addr;
    r16_b addr_reg(.q(q_addr), .d(d_addr), .clk(clk), .rst(rst));

    // DataIn flop
    wire [15:0] d_data_in;
    assign d_data_in = (state == IDLE) ? data_in : q_data_in;
    r16_b data_in_reg(.q(q_data_in), .d(d_data_in), .clk(clk), .rst(rst));


    r4_b state_reg(.q(state), .d(next_state), .clk(clk), .rst(rst));

    // Cache Controller SM
    always @(*) begin

        // DEFAULTS
        // mem_sys defaults
        Done = 1'b0;
        err = 1'b0;
        // cache defaults
        enable = 1'b1;
        comp = 1'b0;
        write = 1'b0;
        // mem bank defaults
        wr = 1'b0;
        rd = 1'b0;
        cache_offset = q_addr[2:0];
        mem_offset = q_addr[2:0];
        memtocache = 1'b0;
        cachetomem = 1'b0;
        next_state = IDLE;
        fsm_stall = 1'b1;
        cachehit = 1'b0;
        case (state)
         
            // Idle state
            IDLE: begin // 0
                enable = 1'b0;
                fsm_stall = 1'b0;
                next_state = (~Rd & ~Wr) ? IDLE :
                             (Rd & ~Wr) ? COMPRD :
                             (~Rd & Wr) ? COMPWR : ERROR;
            end
            COMPRD: begin // 1
                comp = 1'b1;
                err = (|q_addr === 1'bx) ? 1'b1 : 1'b0;
                next_state = (valid & hit) ? IDLE :
                             ((~hit | ~valid) & (dirty | (tag_out != q_addr[15:11] & valid))) ? WB0 :
                             ((~hit | ~valid) & ~dirty) ? RDMB0 : 
                             (err) ? ERROR : IDLE;
                cachehit = valid & hit;
                Done = (next_state == IDLE) ? 1'b1 : 1'b0;
            end
            COMPWR: begin // 2
                //comp = 1'b1;
                write = 1'b1;
                comp = 1'b1;
                err = (|q_addr === 1'bx) ? 1'b1 : 1'b0;
                next_state = (valid & hit) ? IDLE :
                             ((~hit | ~valid) & (dirty | (tag_out != q_addr[15:11] & valid))) ? WB0 :
                             ((~hit | ~valid) & ~dirty) ? RDMB0 :
                             (err) ? ERROR : IDLE;
                cachehit = valid & hit;
                Done = (next_state == IDLE) ? 1'b1 : 1'b0;
            end
            WB0: begin // 3
                next_state = /*(busy[0]) ? WB0 : */WB1;
                wr = 1'b1;
                mem_offset[2:1] = 2'b00;
                cache_offset[2:1] = 2'b00;
                cachetomem = 1'b1;
            end
            WB1: begin // 4
                next_state = /*(busy[1]) ? WB1 : */WB2;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b01;
                cache_offset[2:1] = 2'b01;
            end
            WB2: begin // 5
                next_state = /*(busy[2]) ? WB2 : */WB3;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b10;
            end
            WB3: begin // 6
                next_state = /*(busy[3]) ? WB3 : */RDMB0;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b11;
            end
            RDMB0: begin // 7
                next_state = /*(busy[0]) ? RDMB0 : */RDMB1;
                rd = 1'b1;
                mem_offset[2:1] = 2'b00;
            end
            RDMB1: begin // 8
                next_state = /*(busy[1]) ? RDMB1 : */RDMB2WRMB0;
                rd = 1'b1;
                mem_offset[2:1] = 2'b01;
            end
            RDMB2WRMB0: begin // 9
                write = 1'b1;
                next_state = /*(busy[0] | busy[2]) ? RDMB2WRMB0 : */RDMB3WRMB1;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b00;
            end
            RDMB3WRMB1: begin // A
                write = 1'b1;
                next_state = /*(busy[1] | busy[3]) ? RDMB3WRMB1 : */WRMB2;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b01;
            end
            WRMB2: begin // B
                write = 1'b1;
                next_state = /*(busy[2]) ? WRMB2 : */WRMB3;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b10;
            end
            WRMB3: begin // C
                write = 1'b1;
                next_state = /*(busy[3]) ? WRMB3 : */DONE;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b11;
            end
            DONE: begin // D
                write = q_Wr;
                Done = 1'b1;
                next_state = IDLE;
            end
            ERROR: begin // E
                err = 1'b1;
                enable = 1'b0;
                next_state = ERROR;
            end
            default: begin
                err = 1'b1;
                next_state = ERROR;
            end
        endcase
    end

endmodule
