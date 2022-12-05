// rgb_to_greyscale.sv
//
// This module converts RGB to greyscale using the following algorithm:
// y = [(R>>2) + (R>>5) + (R>>6)] + [(G>>1) + (G>>4) + (G>>5)] + (B>>3)
//
// Video input and output is handled via AXI-Stream interfaces.
// An output FIFO is featured to improve throughput.
// Backpressure is handled via S_AXIS_VIDEO_TREADY.
// 
module rgb_to_greyscale #(
    parameter BUFFER_ADDR_WIDTH = 4
    )
    (
    input  logic        s_axis_aresetn,     // async active-low reset
    input  logic        i_passthrough,      // active-high passthrough enable

    // AXI-Stream Slave Interface
    input  logic        S_AXIS_ACLK,         // S_AXIS clock
    input  logic [15:0] S_AXIS_VIDEO_TDATA,  // RGB565 video data in
    input  logic        S_AXIS_TVALID,      
    input  logic        S_AXIS_VIDEO_TLAST,  // EoL flag
    input  logic        S_AXIS_VIDEO_TUSER,  // SoF flag 
    output logic        S_AXIS_VIDEO_TREADY,

    // AXI-Stream Master Interface
    output logic [15:0] M_AXIS_VIDEO_TDATA,  // RGB565 or Greyscale video out
    output logic        M_AXIS_TVALID,       
    output logic        M_AXIS_VIDEO_TLAST,  // EoL flag 
    output logic        M_AXIS_VIDEO_TUSER,  // SoF flag
    input  logic        M_AXIS_VIDEO_TREADY
    );

    //
    logic [15:0] video_grey;
    logic [15:0] video;
    
    //
    logic [17:0] fifo_wdata; 
    logic [17:0] fifo_rdata;
    logic        fifo_wr;
    logic        fifo_rd;
    logic        fifo_almost_empty, fifo_almost_full;
    logic        fifo_empty, fifo_full;

// Mux video data into output buffer
    assign video = (i_passthrough) ? S_AXIS_VIDEO_TDATA : video_grey;
    always_comb begin
        fifo_wr    = (S_AXIS_TVALID) && (!fifo_almost_full);
        fifo_rd    = (M_AXIS_VIDEO_TREADY && !fifo_empty);
        fifo_wdata = {video, S_AXIS_VIDEO_TUSER, S_AXIS_VIDEO_TLAST}; 
    end 

// Drive M_AXIS fields
    always_comb begin 
        M_AXIS_VIDEO_TDATA  = fifo_rdata[17:2];
        M_AXIS_VIDEO_TUSER  = fifo_rdata[1];
        M_AXIS_VIDEO_TLAST  = fifo_rdata[0];
        M_AXIS_VIDEO_TVALID = fifo_rd; 
    end 

// Greyscale Converter
    greyscale greyscale_i (
        .i_rgb       (S_AXIS_VIDEO_TDATA),
        .o_greyscale (video_grey)
    );

// Output Buffer
    fifo_sync #(
        .DATA_WIDTH     (18),
        .ADDR_WIDTH     (BUFFER_ADDR_WIDTH)
    ) fifo_sync_i (
        .i_clk          (S_AXIS_ACLK),
        .i_rstn         (s_axis_aresetn),
        
        .i_data         (fifo_wdata),
        .i_wr           (fifo_wr),
    
        .o_data         (fifo_rdata),
        .i_rd           (fifo_rd),
    
        .o_fill         (),
        .o_full         (fifo_full),
        .o_empty        (fifo_empty),
        .o_almost_full  (fifo_almost_full),
        .o_almost_empty (fifo_almost_empty)
    );
    


endmodule
