
`timescale 1ns / 1ps

module condition_engine #(
    PAYL_W = 6,
    REG_W = 8
    )(
    input logic [PAYL_W-1:0] payload,
    input logic [REG_W-1:0] condt_value,
    output logic condition_met
    );
    
    always_comb begin
        case(payload)
            6'b000_000: condition_met = 6'b0; //never
            6'b000_001: condition_met = condt_value == 0;
            6'b000_010: condition_met = condt_value < 0;
            6'b000_011: condition_met = condt_value > 0;
            
            6'b000_111: condition_met = 6'b1; //always
            6'b000_100: condition_met = condt_value == 0; //??
            6'b000_101: condition_met = condt_value <= 0;
            6'b000_110: condition_met = condt_value >= 0;
            default: condition_met = 0;
        endcase
    end
    
    
endmodule
