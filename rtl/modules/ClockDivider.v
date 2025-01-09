module ClockDivider(
    input clk,
    input reset,
    output reg clk_1Hz,
    output reg clk_2Hz,
	 output reg clk_4Hz,
    output reg clk_50Hz,
    output reg clk_500Hz
);

    reg [25:0] counter_1Hz;
	 reg [25:0] counter_2Hz;
	 reg [25:0] counter_4Hz;
    reg [25:0] counter_50Hz;
    reg [25:0] counter_500Hz;

    initial begin
        clk_1Hz = 0;
        clk_2Hz = 0;
		  clk_4Hz = 0;
        clk_50Hz = 0;
        clk_500Hz = 0;
    end
	  always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_1Hz <= 0;
            counter_2Hz <= 0;
				counter_4Hz <= 0;
            counter_50Hz <= 0;
            counter_500Hz <= 0;
        end else begin
            if (counter_1Hz >= 20_000_000) begin
                clk_1Hz <= ~clk_1Hz;
                counter_1Hz <= 0;
            end else begin
				   counter_1Hz <= counter_1Hz + 1;
            end
            if (counter_2Hz >= 10_000_000) begin
                clk_2Hz <= ~clk_2Hz;
                counter_2Hz <= 0;
            end else begin
                counter_2Hz <= counter_2Hz + 1;
            end
				if (counter_4Hz >= 5_000_000) begin
					clk_4Hz <= ~clk_4Hz;
					counter_4Hz <= 0;
				end else begin
					counter_4Hz <= counter_4Hz + 1;
					end
            if (counter_50Hz >= 400_000) begin
                clk_50Hz <= ~clk_50Hz;
                counter_50Hz <= 0;
					   end else begin
                counter_50Hz <= counter_50Hz + 1;
            end
            if (counter_500Hz >= 40_000) begin
                clk_500Hz <= ~clk_500Hz;
                counter_500Hz <= 0;
            end else begin
                counter_500Hz <= counter_500Hz + 1;
            end
        end
    end
endmodule