`timescale 1ns / 1ps

//Real Only Memory
module ROM #(
    ROMW = 8,   // bits
    DEPTH = 256, // 2**8
    INIT_F = "",   // initialization file
    ADDRW = $clog2(DEPTH)
    ) (
    input  logic [ADDRW-1:0] addr,
    output logic [ROMW-1:0] instr
    );
    
// IMMEDIATE = 2'b00,
// COMPUTE   = 2'b01,
// COPY      = 2'b10,
// CONDITION = 2'b11

logic [ROMW-1:0] ROM [DEPTH];

initial begin
    for (int i = 0; i < DEPTH; ++i) //initialize all elements to 0
        ROM [i] = 0; // use non blocking = in initial blocks
    if(INIT_F != "") begin
        $display("create init with file: '%s'", INIT_F);
        $readmemb(INIT_F, ROM); 
    end
end

assign instr = ROM [addr];

endmodule
