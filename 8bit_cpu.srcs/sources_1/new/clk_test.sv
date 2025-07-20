

module clk_test(
    input logic clk_100m,
    input logic rst,
    output logic clk_1Hz,
    output logic clk_10Hz
    );
    
    // MMCM Output = Input × MULT_MASTER / (DIV_MASTER × CLKOUT_DIVIDE)
    // Fvco = 100 MHz × 31.5 / 5 = 630 MHz
    
    localparam MULT_MASTER = 10; // master clock multiplier (2.000-64.000)      
    localparam DIV_MASTER = 5;    // master clock divider (1-106)      
    localparam DIV_10x = 1;
    localparam DIV_1x = 10;
    localparam IN_PERIOD = 10; // 10 ns = 100 MHz
    
    logic feedback;
    logic clk_1Hz_unbuf;
    logic clk_10Hz_unbuf;
    logic locked;
    
        MMCME2_BASE #(
        .CLKFBOUT_MULT_F(MULT_MASTER),
        .CLKIN1_PERIOD(IN_PERIOD),
        .CLKOUT0_DIVIDE_F(DIV_10x),
        .CLKOUT1_DIVIDE(DIV_1x),
        .DIVCLK_DIVIDE(DIV_MASTER)
    ) MMCME2_BASE_inst (
        .CLKIN1(clk_100m),
        .RST(rst),
        .CLKOUT0(clk_1Hz_unbuf),
        .CLKOUT1(clk_10Hz_unbuf),
        .LOCKED(locked),
        .CLKFBOUT(feedback),
        .CLKFBIN(feedback),
        
        .CLKOUT0B(),
        .CLKOUT1B(),
        .CLKOUT2(),
        .CLKOUT2B(),
        .CLKOUT3(),
        .CLKOUT3B(),
        .CLKOUT4(),
        .CLKOUT5(),
        .CLKOUT6(),
        .CLKFBOUTB(),
        .PWRDWN()
    );
    
endmodule
