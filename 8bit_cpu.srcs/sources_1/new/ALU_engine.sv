
`timescale 1ns / 1ps

module ALU_engine #(
    PAYL_W = 3,
    REG_W = 8
    )(
    input  logic clk,
    input  logic [PAYL_W-1:0] payload, //and, or, add, sub.. isntructions
    input  logic [REG_W-1:0] i_a,
    input  logic [REG_W-1:0] i_b,
    output logic [REG_W-1:0] o_alu
    );
    
    logic [REG_W-1:0] compute;
    always_comb begin
        case(payload)
            3'b000: compute = i_a | i_b;
            3'b001: compute = i_a & i_b;
            3'b010: compute = ~(i_a | i_b);
            3'b011: compute = ~(i_a & i_b);
            3'b100: compute = i_a + i_b;
            3'b101: compute = i_a - i_b;
            3'b110: compute = i_a * i_b;  
//            3'b111: compute = i_a / i_b;  // Floor devition (is a bitch)
            default: compute = 8'b1111_1111;
            //To have combinational logic all cases need to be acounted for
            //or else there will be a latch and possible fuckery.
        endcase
    end
    
    // fun fact: vivado doesn't understand FSM so this was from:
    // reg_array[2] -> rd_data2 -> alu combinational logic -> o_alu -> wr_data
    // in one cycle. Not anymore though XD
    always_ff @(posedge clk) 
        o_alu <= compute;
    
endmodule
