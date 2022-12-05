// fifo_sync.v
//
// Simple shared-clocks FIFO.
// Features registered status outputs. 
// 1 clock cycle read and write latency.
// 
/*
----- INSTANTATION TEMPLATE ----- 

fifo_sync #(
    .DATA_WIDTH     (),
    .ADDR_WIDTH     ()
) fifo_sync_i (
    .i_clk          (),
    .i_rstn         (),
    
    .i_data         (),
    .i_wr           (),

    .o_data         (),
    .i_rd           (),

    .o_fill         (),
    .o_full         (),
    .o_empty        (),
    .o_almost_full  (),
    .o_almost_empty ()
);

*/
module fifo_sync #(
    parameter DATA_WIDTH         = 32,
    parameter ADDR_WIDTH         = 10
    )
    (
    input  wire                  i_clk,
    input  wire                  i_rstn,

    // Write Interface
    input  wire [DATA_WIDTH-1:0] i_data,
    input  wire                  i_wr,

    // Read Interface
    output wire [DATA_WIDTH-1:0] o_data,
    input  wire                  i_rd,

    // Status 
    output reg  [ADDR_WIDTH:0]   o_fill,
    output reg                   o_full,
    output reg                   o_empty,
    output reg                   o_almost_empty,
    output reg                   o_almost_full
    );

    localparam FIFO_DEPTH = 2**ADDR_WIDTH;

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];

    // Wr/Rd pointers
    reg [ADDR_WIDTH-1:0] rptr;
    reg [ADDR_WIDTH-1:0] wptr;

    // lookahead pointers for registered flag gen
    wire [ADDR_WIDTH-1:0] rptr_next;  // one cycle lookahead; for empty flag gen
    wire [ADDR_WIDTH-1:0] rptr_next2; // two cycle lookahead; for almost-empty flag gen

    wire [ADDR_WIDTH-1:0] wptr_next2; // two cycle lookahead; for full flag gen
    wire [ADDR_WIDTH-1:0] wptr_next3; // 3 cycle lookahead; for almost-full flag gen

    // Create BRAM 
    always@(posedge i_clk) begin 
        if(i_wr) mem[wptr] <= i_data;
    end 
    assign o_data = mem[rptr];

    // Lookahead Pointers
    assign rptr_next  = rptr + 'd1;
    assign rptr_next2 = rptr + 'd2;
    assign wptr_next2 = wptr + 'd2;
    assign wptr_next3 = wptr + 'd3;

    initial begin 
        wptr    = 0;
        rptr    = 0;
        o_fill  = 0;
        o_full  = 0;
        o_empty = 1;
        o_almost_empty = 1;
        o_almost_full  = 0;
    end 
    
    always@(posedge i_clk, negedge i_rstn) begin 
        if(!i_rstn) begin 
            wptr    <= 0;
            rptr    <= 0;
            o_fill  <= 0;
            o_full  <= 0;
            o_empty <= 1;
            o_almost_empty <= 1;
            o_almost_full  <= 0;
        end 
        else begin 
            if(i_wr) begin 
                wptr <= wptr + 1;
            end 

            if(i_rd && (rptr != wptr)) begin 
                rptr <= rptr + 1;
            end 

            if(i_wr && !i_rd) o_fill <= (o_fill == FIFO_DEPTH) ? o_fill : o_fill + 1;
            if(!i_wr && i_rd) o_fill <= (o_fill == 0) ? 0 : o_fill - 1;

            casez({i_wr, i_rd, o_full, o_empty})
                // Read but no write; FIFO not empty
                4'b01?0: begin 
                    o_full  <= 0;
                    o_empty <= (rptr_next == wptr);
                    o_almost_empty <= (rptr_next2 == wptr);
                end 

                // Write but no read; FIFO not full
                4'b100?: begin 
                    o_full  <= (wptr_next2 == rptr);
                    o_empty <= 0;
                    o_almost_full <= (wptr_next3 == wptr);
                end 

                // Simultaneous Read and Write; FIFO not empty
                4'b11?0: begin 
                    o_full  <= o_full;  
                    o_empty <= 0;
                end 

                // Simultaneous Read and Write; FIFO is empty
                4'b11?1: begin 
                    o_full  <= 0;
                    o_empty <= 0;
                end 

                default: begin end 
            endcase 
        end 
    end 
endmodule

