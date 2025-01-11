module ClockDivider(
    input clk,
    input reset,
    output reg clk_1Hz,
    output reg clk_2Hz,
    output reg clk_4Hz,
    output reg clk_50Hz,
    output reg clk_500Hz,
    output reg clk_1Min
);

    reg [25:0] counter_1Hz;
    reg [25:0] counter_2Hz;
    reg [25:0] counter_4Hz;
    reg [25:0] counter_50Hz;
    reg [25:0] counter_500Hz;
    reg [31:0] counter_1Min;

    initial begin
        clk_1Hz = 0;
        clk_2Hz = 0;
        clk_4Hz = 0;
        clk_50Hz = 0;
        clk_500Hz = 0;
        clk_1Min = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_1Hz <= 0;
            counter_2Hz <= 0;
            counter_4Hz <= 0;
            counter_50Hz <= 0;
            counter_500Hz <= 0;
            counter_1Min <= 0;
            clk_1Hz <= 0;
            clk_2Hz <= 0;
            clk_4Hz <= 0;
            clk_50Hz <= 0;
            clk_500Hz <= 0;
            clk_1Min <= 0;
        end else begin
            if (counter_1Hz >= 20_000_000) begin
                clk_1Hz <= ~clk_1Hz;
                counter_1Hz <= 0;
            end else begin
                counter_1Hz <= counter_1Hz + 1;
            end

            // Generate 2Hz clock
            if (counter_2Hz >= 10_000_000) begin
                clk_2Hz <= ~clk_2Hz;
                counter_2Hz <= 0;
            end else begin
                counter_2Hz <= counter_2Hz + 1;
            end

            // Generate 4Hz clock
            if (counter_4Hz >= 5_000_000) begin
                clk_4Hz <= ~clk_4Hz;
                counter_4Hz <= 0;
            end else begin
                counter_4Hz <= counter_4Hz + 1;
            end

            // Generate 50Hz clock
            if (counter_50Hz >= 800_000) begin
                clk_50Hz <= ~clk_50Hz;
                counter_50Hz <= 0;
            end else begin
                counter_50Hz <= counter_50Hz + 1;
            end

            // Generate 500Hz clock
            if (counter_500Hz >= 80_000) begin
                clk_500Hz <= ~clk_500Hz;
                counter_500Hz <= 0;
            end else begin
                counter_500Hz <= counter_500Hz + 1;
            end

            // Generate 1-minute clock
            if (counter_1Min >= 2_400_000_000) begin
                clk_1Min <= ~clk_1Min;
                counter_1Min <= 0;
            end else begin
                counter_1Min <= counter_1Min + 1;
            end
        end
    end
endmodule
