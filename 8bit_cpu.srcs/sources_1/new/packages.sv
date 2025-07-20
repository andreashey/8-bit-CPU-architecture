

package opcode_defs;
    typedef enum logic [1:0] {
        IMMEDIATE = 2'b00,
        COMPUTE   = 2'b01,
        COPY      = 2'b10,
        CONDITION = 2'b11
    } instr_type_t;
endpackage

package register_defs;

    // General-purpose register addresses
    localparam logic [2:0] REG_0 = 3'b000;
    localparam logic [2:0] REG_1 = 3'b001;
    localparam logic [2:0] REG_2 = 3'b010;
    localparam logic [2:0] REG_3 = 3'b011;
    localparam logic [2:0] REG_4 = 3'b100;
    localparam logic [2:0] REG_5 = 3'b101;

    // Special-purpose (pseudo) register addresses
    localparam logic [2:0] SOURCE_OUTPUT = 3'b110;
    localparam logic [2:0] SOURCE_INPUT  = 3'b111;

endpackage
