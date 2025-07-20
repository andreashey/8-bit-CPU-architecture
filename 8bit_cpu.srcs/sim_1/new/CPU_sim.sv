`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2025 18:33:02
// Design Name: 
// Module Name: CPU_sim
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU_sim();

    localparam CLK_PERIOD = 10;
    logic clk;
    logic rst_s;
    logic [7:0] o_output;
    
    CPU CPU_UUT (
    .clk_100m(clk),
    .rst_btn_n(rst_s),
    .o_output(o_output)
    );
    
    always #(CLK_PERIOD/2) clk = ~clk;
    
    initial begin
        clk = 0;
        rst_s = 0;  // Active low
        $monitor(
        "addr= %d  rst = %d\nr0 = %0d  r1 = %0d  r2 = %0d  r3 = %0d \n", 
        CPU_UUT.PC_addr, CPU_UUT.rst,
        CPU_UUT.registers.regs[0],
        CPU_UUT.registers.regs[1],
        CPU_UUT.registers.regs[2],
        CPU_UUT.registers.regs[3]);


        #50;
        rst_s = 1;      // reset released (button pressed)
        #100;
        $finish;      // end simulation after some time
    end

    
    
endmodule
