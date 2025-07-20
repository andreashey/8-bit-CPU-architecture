`timescale 1ns / 1ps

module clk_scale (
    input  logic clk_100m,
    input  logic rst,
    output logic clk_1Hz,
    output logic clk_10Hz
);

    // Counter for 1Hz (toggle every 0.5 sec → 50 million cycles)
    localparam int MAX_1HZ_COUNT  = 100_000_000 / 2;
    logic [26:0] counter_1Hz = 0;
    logic clk_1Hz_reg = 0;
//    logic clk_1Hz_unbuff;

    // Counter for 10Hz (toggle every 0.05 sec → 5 million cycles)
    localparam int MAX_10HZ_COUNT = 10_000_000 / 2;
    logic [23:0] counter_10Hz = 0;
    logic clk_10Hz_reg = 0;
//    logic clk_10Hz_unbuff;

    always_ff @(posedge clk_100m or posedge rst) begin
        if (rst) begin
            counter_1Hz    <= 0;
            clk_1Hz_reg    <= 0;
            counter_10Hz   <= 0;
            clk_10Hz_reg   <= 0;
        end else begin
            // 1 Hz logic
            if (counter_1Hz == MAX_1HZ_COUNT - 1) begin
                counter_1Hz <= 0;
                clk_1Hz_reg <= ~clk_1Hz_reg;
            end else begin
                counter_1Hz <= counter_1Hz + 1;
            end

            // 10 Hz logic
            if (counter_10Hz == MAX_10HZ_COUNT - 1) begin
                counter_10Hz <= 0;
                clk_10Hz_reg <= ~clk_10Hz_reg;
            end else begin
                counter_10Hz <= counter_10Hz + 1;
            end
        end
    end

    assign clk_1Hz  = clk_1Hz_reg;
    assign clk_10Hz = clk_10Hz_reg;
    
    
    //does't work with registered togles pins. 
    // Needs to be used with clock pins from MMCM or PLL
//    BUFG bufg_clk_1Hz  (.I(clk_1Hz_unbuff),  .O(clk_1Hz));
//    BUFG bufg_clk_10Hz (.I(clk_10Hz_unbuff), .O(clk_10Hz));
    
    

endmodule
