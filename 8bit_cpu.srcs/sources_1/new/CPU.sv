`timescale 1ns / 1ps

import opcode_defs::*;
import register_defs::*;

module CPU(
    input logic clk_100m,
    input logic rst_btn_n,
    input logic [7:0] i_input,
    output logic [7:0] o_output
    );
    
    //Get clock scales
    logic clk_1Hz;
    logic clk_10Hz;
    logic rst;
    assign rst = ~rst_btn_n;
    
    clk_scale clk_s(
        .clk_100m(clk_100m),
        .rst(rst),      
        .clk_1Hz(clk_1Hz),  
        .clk_10Hz(clk_10Hz)
    );
    
    // choose clk_enable
    logic clk_enable;
    logic clk_prev;
    always_ff @(posedge clk_100m) begin 
        clk_prev <= clk_10Hz;
    end
    assign clk_enable = 1; //(clk_10Hz && !clk_prev); // Detect rising edge
    
    // PC PERAMETERS
    localparam INSTR_W = 8; // Opcode (2) + payload (6), CPU data width
    localparam OPC_W = 2; // Opcode width
    localparam PAYLOAD_W = 6; // Payload width
    
    //Instruction byte to opcode and payload
    logic [INSTR_W-1:0] instr;
    instr_type_t opcode;
    logic [PAYLOAD_W-1:0] payload;
    
    //Counting address to program 
    logic [INSTR_W-1:0] PC_addr;
    logic [INSTR_W-1:0] PC_rst_value;
    
    instruction_decoder #(
        .INSTR_W(INSTR_W),
        .OPC_W(OPC_W),
        .PAYLOAD_W(PAYLOAD_W)
        ) instr_dec (
        .instr(instr),
        .opcode(opcode),
        .payload(payload)
    );
    
    //load from ROM
    localparam ROMW = 8;
    localparam ROMD = 255; //2**8-1
    localparam INIT_F = "circumference.mem";
    
    ROM #(
        .ROMW(ROMW),
        .DEPTH(ROMD),
        .INIT_F(INIT_F)
        ) rom_init (
        .addr(PC_addr),
        .instr(instr)
    );
    
    //Add registers
    localparam REG_NR = 5;                // Amount of CPU registers
    localparam RADDR_W = $clog2(REG_NR);  // register address width
    
    logic [RADDR_W-1:0] rd_addr1 = 0;
    logic [RADDR_W-1:0] rd_addr2 = 0;
    logic [RADDR_W-1:0] wr_addr = 0;
    logic [INSTR_W-1:0] wr_data = 0;
    logic wr_enable;
    
    logic [INSTR_W-1:0] rd_data1;
    logic [INSTR_W-1:0] rd_data2;
    logic [INSTR_W-1:0] condt_value;
    
    register_file #(
        .REG_W(INSTR_W),
        .REG_NR(REG_NR),
        .ADDR_W(RADDR_W)
         ) registers (
        //inputs
        .clk(clk_100m),
        .rst(rst),
        .rd_addr1(rd_addr1),
        .rd_addr2(rd_addr2),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .wr_en(wr_enable),
        
        //outputs
        .rd_data1(rd_data1),
        .rd_data2(rd_data2),
        .PC_rst_value(PC_rst_value),
        .condt_value(condt_value)
    );
    
    //Arithmatic
    logic [INSTR_W-1:0] o_alu;
    
    ALU_engine #(
        .PAYL_W(3),
        .REG_W(INSTR_W)
         ) alu (
        .clk(clk_100m),
        .payload(payload[2:0]),
        .i_a(rd_data1),
        .i_b(rd_data2),
        .o_alu(o_alu)
    );
    
    //condition
    condition_engine #(
        .PAYL_W(PAYLOAD_W),
        .REG_W(INSTR_W)
         ) ce (
        .payload(payload),
        .condt_value(condt_value),
        .condition_met(condition_met)
    );
        
    enum {FETCH, DECODE, HOLD , EXEC} state;
    logic [INSTR_W-1:0] next_PC;
    logic [INSTR_W-1:0] input_reg;
    logic reg_wait;
    logic [1:0] cnt;
    localparam MAX_CNT = 1; // <-- cycles wait in HOLD
    
    always_ff @(posedge clk_100m or posedge rst) begin
        if (rst) begin
            state     <= FETCH;
            PC_addr   <= 0;
            next_PC   <= 0;
            wr_enable <= 0;
            rd_addr1  <= 0;
            rd_addr2  <= 0;
            wr_addr   <= 0;
            wr_data   <= 0;
            cnt       <= 0;
            o_output  <= 0;
            input_reg <= 0;
        end
        else if (clk_enable) begin  // <-- only step FSM when enable is high
            case(state)
                FETCH: begin
                    state <= DECODE;
                    wr_enable <= 0;
                    rd_addr1  <= 0;
                    rd_addr2  <= 0;
                    wr_addr   <= 0;
                    wr_data   <= 0;
                    input_reg <= i_input;
                    PC_addr   <= next_PC;
                end

                DECODE: begin
                    state <= HOLD; // <-- +1 for rd_data1 and rd_data2
                    rd_addr1 <= 0;
                    rd_addr2 <= 0;
                    wr_addr  <= 0;
                    wr_data  <= 0;
                    
                    case(opcode)
                        COMPUTE: begin
                            rd_addr1  <= REG_1;
                            rd_addr2  <= REG_2;
                            wr_addr   <= REG_3;
                        end
                        COPY: begin
                            if(payload[5:3] == SOURCE_INPUT) begin
                                wr_addr   <= payload[2:0];
                            end else if(payload[2:0] == SOURCE_OUTPUT) begin
                                rd_addr1 <= payload[5:3];
                                wr_addr   <= payload[2:0];
                            end else begin
                                rd_addr1  <= payload[5:3];
                                wr_addr   <= payload[2:0];
                            end
                        end
                        default: state <= EXEC;
                    endcase
                end
                HOLD: begin
                    if(cnt == MAX_CNT-1) begin 
                        state <= EXEC;
                        cnt <= 0;
                    end else
                        cnt <= cnt + 1;
                end

                EXEC: begin
                    state <= FETCH;
                    wr_enable <= 0;
                    next_PC <= PC_addr + 1;

                    case(opcode)
                        IMMEDIATE: begin
                            wr_enable <= 1;
                            wr_addr   <= REG_0;
                            wr_data   <= {2'b00, payload[5:0]};
                        end

                        COMPUTE: begin
                            wr_enable <= 1;
                            wr_data   <= o_alu;
                        end

                        COPY: begin
                            if(payload[5:3] == SOURCE_INPUT) begin
                                wr_enable <= 1;
                                wr_data   <= input_reg;
                            end else if(payload[2:0] == SOURCE_OUTPUT) begin
                                o_output <= rd_data1;
                            end else begin
                                wr_enable <= 1;
                                wr_data   <= rd_data1;
                            end
                        end

                        CONDITION: begin
                            if (condition_met)
                                next_PC <= PC_rst_value;
                        end
                    endcase
                end
            endcase
        end
    end
endmodule