// greyscale.sv
//
// This module converts RGB to greyscale in combinatorial logic using the following algorithm:
// y = [(R>>2) + (R>>5) + (R>>6)] + [(G>>1) + (G>>4) + (G>>5)] + (B>>3)
//
module greyscale (
    input  logic [15:0] i_rgb,
    output logic [15:0] o_greyscale
    );

    logic [4:0] red,   r_component;
    logic [5:0] green, g_component;
    logic [4:0] blue,  b_component;

    assign red   = i_rgb[15:11];
    assign green = i_rgb[10:5];
    assign blue  = i_rgb[4:0];

    always_comb begin 
        r_component = (red>>2) + (red>>5) + (red>>6);
        g_component = (green>>1) + (green>>4) + (green>>5);
        b_component = (blue>>3);

        o_greyscale = r_component + g_component + b_component;
    end 

endmodule

