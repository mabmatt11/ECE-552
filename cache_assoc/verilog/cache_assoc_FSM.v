/* $Author: karu, Garret Huibregtse, Matt Bachmeier, Amanda Becker $ */
/* $Rev: 77 $ */

module cache_assoc_FSM(/*Oututs*/
            Done,
            err,
            enable0,
            enable1,
            comp,
            write0,
            write1,
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
            c0_data,
            c1_data,
            /*Inputs*/
            stall,
            busy,
            hit0,
            hit1,
            valid0,
            valid1,
            dirty0,
            dirty1,
            clk,
            rst,
            Addr,
            data_in,
            Rd,
            Wr,
            tag_out0,
            tag_out1
            );
             
    input stall, hit0, hit1, valid0, valid1, dirty0, dirty1, clk, rst, Rd, Wr;
    input [3:0] busy;
    input [4:0] tag_out0, tag_out1;
    input [15:0] data_in, Addr;
    output reg fsm_stall, cachehit, cachetomem, memtocache, rd, wr, write0,
               write1, comp, enable0, enable1, err, Done, c0_data, c1_data;
    output reg [2:0] cache_offset, mem_offset;
    output [15:0] q_addr, q_data_in;

    wire [4:0] state;
    reg [4:0] next_state;
             
    parameter   IDLE = 5'h0,
                COMPRD = 5'h1,
                COMPWR = 5'h2,
                WBC0_0 = 5'h3,
                WBC0_1 = 5'h4,
                WBC0_2 = 5'h5,
                WBC0_3 = 5'h6,
                WBC1_0 = 5'h7,
                WBC1_1 = 5'h8,
                WBC1_2 = 5'h9,
                WBC1_3 = 5'hA,
                RDMB0_C0 = 5'hB,
                RDMB1_C0 = 5'hC,
                RDMB2WRMB0_C0 = 5'hD,
                RDMB3WRMB1_C0 = 5'hE,
                WRMB2_C0 =  5'hF,
                WRMB3_C0  = 5'h10,
                RDMB0_C1 = 5'h11,
                RDMB1_C1 = 5'h12,
                RDMB2WRMB0_C1 = 5'h13,
                RDMB3WRMB1_C1 = 5'h14,
                WRMB2_C1 =  5'h15,
                WRMB3_C1  = 5'h16,
                DONE_C0 = 5'h17,
                DONE_C1 = 5'h18,
                ERROR = 5'h19;

    // Propogating original wr/rd signals through fsm
    wire q_Rd, q_Wr, d_Rd, d_Wr, d_hit, d_valid, q_victimway, d_victimway;
    assign d_Wr = (state == IDLE) ? Wr: q_Wr;
    assign d_Rd = (state == IDLE) ? Rd: q_Rd;
    r1_b Wr_reg(.q(q_Wr), .d(d_Wr), .clk(clk), .rst(rst));
    r1_b Rd_reg(.q(q_Rd), .d(d_Rd), .clk(clk), .rst(rst));
    
    // victim flop
    assign d_victimway = (state == COMPRD | state == COMPWR) ? ~q_victimway : q_victimway;
    r1_b victimway_reg(.q(q_victimway), .d(d_victimway), .clk(clk), .rst(rst));

    // Address breakdown propogation
    wire [15:0] d_addr;
    assign d_addr = (state == IDLE) ? Addr : q_addr;
    r16_b addr_reg(.q(q_addr), .d(d_addr), .clk(clk), .rst(rst));

    // DataIn flop
    wire [15:0] d_data_in;
    assign d_data_in = (state == IDLE) ? data_in : q_data_in;
    r16_b data_in_reg(.q(q_data_in), .d(d_data_in), .clk(clk), .rst(rst));
    
    // state flop
    r5_b state_reg(.q(state), .d(next_state), .clk(clk), .rst(rst));

    //TODO make sure enable0 and enable1 are set correctly
    // Cache Controller SM
    always @(*) begin

        // DEFAULTS
        // mem_sys defaults
        Done = 1'b0;
        err = 1'b0;
        // cache defaults
        enable0 = 1'b0;
        enable1 = 1'b0;
        comp = 1'b0;
        write0 = 1'b0;
        write1 = 1'b0;
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
        c0_data = 1'b0;
        c1_data = 1'b0;
        case (state)
         
            // Idle state
            IDLE: begin // 0
                fsm_stall = 1'b0;
                next_state = (~Rd & ~Wr) ? IDLE :
                             (Rd & ~Wr) ? COMPRD :
                             (~Rd & Wr) ? COMPWR : ERROR;
            end
            COMPRD: begin // 1
                enable0 = 1'b1;
                enable1 = 1'b1;
                comp = 1'b1;
                err = (|q_addr === 1'bx) ? 1'b1 : 1'b0;
                next_state = (valid0 & hit0 | valid1 & hit1) ? IDLE :
                             (~valid0) ? RDMB0_C0 :
                             (~valid1) ? RDMB0_C1 :
                             (~d_victimway) ? ((dirty0 | (tag_out0 != q_addr[15:11])) ? WBC0_0 : RDMB0_C0) :
                             (d_victimway)  ? ((dirty1 | (tag_out1 != q_addr[15:11])) ? WBC1_0 : RDMB0_C1) :
                             (err) ? ERROR : IDLE;
                cachehit = (valid0 & hit0 | valid1 & hit1);
                c0_data = (valid0 & hit0);
                c1_data = (valid1 & hit1);
                Done = (next_state == IDLE) ? 1'b1 : 1'b0;
            end
            COMPWR: begin // 2
                enable0 = 1'b1;
                enable1 = 1'b1;
                write0 = 1'b1;
                write1 = 1'b1;
                comp = 1'b1;
                err = (|q_addr === 1'bx) ? 1'b1 : 1'b0;
                next_state = (valid0 & hit0 | valid1 & hit1) ? IDLE :
                             (~valid0) ? RDMB0_C0 :
                             (~valid1) ? RDMB0_C1 :
                             (~d_victimway) ? ((dirty0 | (tag_out0 != q_addr[15:11])) ? WBC0_0 : RDMB0_C0) :
                             (d_victimway)  ? ((dirty1 | (tag_out1 != q_addr[15:11])) ? WBC1_0 : RDMB0_C1) :
                             (err) ? ERROR : IDLE;
                cachehit = (valid0 & hit0 | valid1 & hit1);
                Done = (next_state == IDLE) ? 1'b1 : 1'b0;
            end
            WBC0_0: begin // 3
                enable0 = 1'b1;
                next_state = /*(busy[0]) ? WB0 : */WBC0_1;
                wr = 1'b1;
                mem_offset[2:1] = 2'b00;
                cache_offset[2:1] = 2'b00;
                cachetomem = 1'b1;
            end
            WBC0_1: begin // 4
                enable0 = 1'b1;
                next_state = /*(busy[1]) ? WB1 : */WBC0_2;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b01;
                cache_offset[2:1] = 2'b01;
            end
            WBC0_2: begin // 5
                enable0 = 1'b1;
                next_state = /*(busy[2]) ? WB2 : */WBC0_3;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b10;
            end
            WBC0_3: begin // 6
                enable0 = 1'b1;
                next_state = /*(busy[3]) ? WB3 : */RDMB0_C0;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b11;
            end
            WBC1_0: begin // 7
                enable1 = 1'b1;
                next_state = /*(busy[0]) ? WB0 : */WBC1_1;
                wr = 1'b1;
                mem_offset[2:1] = 2'b00;
                cache_offset[2:1] = 2'b00;
                cachetomem = 1'b1;
            end
            WBC1_1: begin // 8
                enable1 = 1'b1;
                next_state = /*(busy[1]) ? WB1 : */WBC1_2;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b01;
                cache_offset[2:1] = 2'b01;
            end
            WBC1_2: begin // 9
                enable1 = 1'b1;
                next_state = /*(busy[2]) ? WB2 : */WBC1_3;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b10;
            end
            WBC1_3: begin // A
                enable1 = 1'b1;
                next_state = /*(busy[3]) ? WB3 : */RDMB0_C1;
                wr = 1'b1;
                cachetomem = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b11;
            end
            RDMB0_C0: begin // B
                next_state = /*(busy[0]) ? RDMB0 : */RDMB1_C0;
                rd = 1'b1;
                mem_offset[2:1] = 2'b00;
            end
            RDMB1_C0: begin // C
                next_state = /*(busy[1]) ? RDMB1 : */RDMB2WRMB0_C0;
                rd = 1'b1;
                mem_offset[2:1] = 2'b01;
            end
            RDMB2WRMB0_C0: begin // D
                write0 = 1'b1;
                enable0 = 1'b1;
                next_state = /*(busy[0] | busy[2]) ? RDMB2WRMB0 : */RDMB3WRMB1_C0;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b00;
            end
            RDMB3WRMB1_C0: begin // E
                write0 = 1'b1;
                enable0 = 1'b1;
                next_state = /*(busy[1] | busy[3]) ? RDMB3WRMB1 : */WRMB2_C0;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b01;
            end
            WRMB2_C0: begin // F
                write0 = 1'b1;
                enable0 = 1'b1;
                next_state = /*(busy[2]) ? WRMB2 : */WRMB3_C0;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b10;
            end
            WRMB3_C0: begin // 10
                write0 = 1'b1;
                enable0 = 1'b1;
                next_state = /*(busy[3]) ? WRMB3 : */DONE_C0;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b11;
            end
            RDMB0_C1: begin // 11
                next_state = /*(busy[0]) ? RDMB0 : */RDMB1_C1;
                rd = 1'b1;
                mem_offset[2:1] = 2'b00;
            end
            RDMB1_C1: begin // 12
                next_state = /*(busy[1]) ? RDMB1 : */RDMB2WRMB0_C1;
                rd = 1'b1;
                mem_offset[2:1] = 2'b01;
            end
            RDMB2WRMB0_C1: begin // 13
                write1 = 1'b1;
                enable1 = 1'b1;
                next_state = /*(busy[0] | busy[2]) ? RDMB2WRMB0 : */RDMB3WRMB1_C1;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b10;
                cache_offset[2:1] = 2'b00;
            end
            RDMB3WRMB1_C1: begin // 14
                write1 = 1'b1;
                enable1 = 1'b1;
                next_state = /*(busy[1] | busy[3]) ? RDMB3WRMB1 : */WRMB2_C1;
                rd = 1'b1;
                memtocache = 1'b1;
                mem_offset[2:1] = 2'b11;
                cache_offset[2:1] = 2'b01;
            end
            WRMB2_C1: begin // 15
                write1 = 1'b1;
                enable1 = 1'b1;
                next_state = /*(busy[2]) ? WRMB2 : */WRMB3_C1;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b10;
            end
            WRMB3_C1: begin // 16
                write1 = 1'b1;
                enable1 = 1'b1;
                next_state = /*(busy[3]) ? WRMB3 : */DONE_C1;
                memtocache = 1'b1;
                cache_offset[2:1] = 2'b11;
            end
            DONE_C0: begin // 17
                enable0 = 1'b1;
                write0 = q_Wr;
                c0_data = q_Rd;
                Done = 1'b1;
                next_state = IDLE;
            end
            DONE_C1: begin // 17
                enable1 = 1'b1;
                write1 = q_Wr;
                c1_data  = q_Rd;
                Done = 1'b1;
                next_state = IDLE;
            end
            ERROR: begin // 18
                err = 1'b1;
                next_state = ERROR;
            end
            default: begin
                err = 1'b1;
                next_state = ERROR;
            end
        endcase
    end

endmodule
