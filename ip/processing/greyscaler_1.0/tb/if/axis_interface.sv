// axis_interface.sv
//
// This file contains a SystemVerilog interface for AXI-Stream.
// This interface also contains an extra field specifically for
// the greyscaler IP passthrough enable.
//
interface axis_interface #(
    parameter DATA_WIDTH = 16
    )
    (
    input clk,
    input rst
    );

/*
* S_AXIS
*/

    // AXIS REQUIRED SIGNALS
    logic [DATA_WIDTH-1 :0] S_AXIS_TDATA;
    logic                   S_AXIS_TVALID;
    logic                   S_AXIS_TREADY;

    // AXIS OPTIONAL SIGNALS
    logic                   S_AXIS_VIDEO_TLAST;
    logic                   S_AXIS_VIDEO_TUSER;

/*
* M_AXIS
*/

    // M_AXIS REQUIRED SIGNALS
    logic [DATA_WIDTH-1 :0] M_AXIS_TDATA;
    logic                   M_AXIS_TVALID;
    logic                   M_AXIS_TREADY;

    // M_AXIS OPTIONAL SIGNALS
    logic                   M_AXIS_VIDEO_TLAST;
    logic                   M_AXIS_VIDEO_TUSER;

/*
* IP SPECIFIC
*/
    logic passthrough;
    logic s_axis_aresetn;

endinterface

