module ClockDivider (
    input clk_in,
    output reg clk_out
);
    parameter INPUT_CLOCK_FREQ = 40_000_000 // Default input clock frequency: 40 MHz
    parameter DIVISOR = INPUT_CLOCK_FREQ / 2; // Default divisor for 1 Hz output

    reg [25:0] counter = 0;

    initial begin
        clk_out = 0;
    end

    always @(posedge clk_in) begin
        if (counter == DIVISOR - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule