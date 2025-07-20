
`timescale 1ns / 1ps

module register_file #(
    REG_W = 8,
    REG_NR = 6,
    ADDR_W = 3
    )(
    input logic clk, rst,
    input logic [ADDR_W-1:0] rd_addr1, 
    input logic [ADDR_W-1:0] rd_addr2,
    input logic [ADDR_W-1:0] wr_addr, 
    input logic [REG_W-1:0] wr_data,
    input logic wr_en,
    
    output logic [REG_W-1:0] rd_data1, 
    output logic [REG_W-1:0] rd_data2,
    output logic [REG_W-1:0] PC_rst_value,
    output logic [REG_W-1:0] condt_value
    );
    
    logic [REG_W-1:0] reg_array [REG_NR];
    
    always_ff @(posedge clk) begin
        if(rst) begin
            for(int i = 0; i < REG_NR; i++)
                reg_array[i] <= 0;
        end else if(wr_en)
            reg_array[wr_addr] <= wr_data;
//        rd_data1 <= reg_array[rd_addr1];
//        rd_data2 <= reg_array[rd_addr2];   
    end
    
    assign rd_data1 = reg_array[rd_addr1];
    assign rd_data2 = reg_array[rd_addr2];
    assign PC_rst_value    = reg_array[0];
    assign condt_value     = reg_array[3];
    
endmodule
