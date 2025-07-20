module power_on_reset(
    input  logic clk,
    input  logic rst_btn,
    output logic reset
);
    logic [3:0] counter = 4'd0;
    logic done = 0;

    always_ff @(posedge clk) begin
        if (!done) begin
            counter <= counter + 1;
            if (counter == 4'd15)
                done <= 1;
        end
    end

    assign reset = !done | rst_btn;
endmodule
