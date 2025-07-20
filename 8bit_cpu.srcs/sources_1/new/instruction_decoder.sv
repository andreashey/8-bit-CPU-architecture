`timescale 1ns / 1ps

//`include "packages.sv"
import opcode_defs::*;

    module instruction_decoder #(
        INSTR_W = 8,
        OPC_W = 2,
        PAYLOAD_W = 6
        )(
        input logic [INSTR_W-1:0] instr,
        output instr_type_t opcode,
        output logic [PAYLOAD_W-1:0] payload
        );
        
        // slice first then cast
        logic [1:0] opcode_bits;
        assign opcode_bits = instr[7:6];
        assign opcode = instr_type_t'(opcode_bits);  // ✅ this works in most versions of Vivado

        assign payload = instr[PAYLOAD_W-1:0];
        
    
//    always_comb begin
//        case(opcode)
//            2'b00: instruction = IMMIDIATE;
//            2'b01: instruction = COMPUTE;
//            2'b10: instruction = COPY;
//            2'b11: instruction = CONDITION;
//        endcase
//    end  
endmodule
