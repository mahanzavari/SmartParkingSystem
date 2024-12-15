module ClockDivider (
    input clk,             // Input clock
    input reset,           // Reset signal
    output reg clk_1Hz,    // 1 Hz clock
    output reg clk_2Hz     // 2 Hz clock
);

    reg [25:0] counter_1Hz;
    reg [25:0] counter_2Hz;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_1Hz <= 0;
            counter_2Hz <= 0;
            clk_1Hz <= 0;
            clk_2Hz <= 0;
        end else begin
            // 1 Hz clock generation
            if (counter_1Hz >= 20_000_000) begin
                clk_1Hz <= ~clk_1Hz;
                counter_1Hz <= 0;
            end else begin
                counter_1Hz <= counter_1Hz + 1;
            end

            // 2 Hz clock generation
            if (counter_2Hz >= 10_000_000) begin
                clk_2Hz <= ~clk_2Hz;
                counter_2Hz <= 0;
            end else begin
                counter_2Hz <= counter_2Hz + 1;
            end
        end
    end
endmodule
