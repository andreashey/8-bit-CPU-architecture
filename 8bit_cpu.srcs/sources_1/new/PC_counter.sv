
import opcode_defs::*;

module PC_counter(
    input  logic clk,
    input  logic rst,
    input  instr_type_t opcode,
    input  logic rst_to_value,
    input  logic [7:0] rst_value,
    output logic [7:0] PC_addr 
    );
    
    always_ff @(posedge clk) begin
        if(rst) 
            PC_addr = 0;
        else if (rst_to_value && (opcode == CONDITION)) 
            PC_addr <= rst_value;
        else 
            PC_addr <= PC_addr + 1;
    end
    
endmodule
