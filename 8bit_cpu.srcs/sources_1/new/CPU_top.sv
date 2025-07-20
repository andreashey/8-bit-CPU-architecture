`timescale 1ns / 1ps

module CPU_top(
    input logic clk_100m,
    input logic rst_btn_n,
    output logic [7:0] o_output
);

    localparam [7:0] i_input = 8'b0000_0101;

    logic rst;
    assign rst = ~rst_btn_n;

    logic enable_10Hz;

    clk_scale clk_s(
        .clk_100m(clk_100m),
        .rst(rst),   
        .clk_1Hz(),   
        .clk_10Hz(enable_10Hz)
    ); 

    CPU cpu_mod (
        .clk(clk_100m),
        .rst(rst),
        .clk_enable(enable_10Hz),
        .i_input(i_input),
        .o_output(o_output)
    );

endmodule
