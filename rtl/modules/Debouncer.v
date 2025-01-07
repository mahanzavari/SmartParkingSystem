module Debouncer (
    input clk,            // System clock
    input reset,          // Reset signal
    input noisy_signal,   // Noisy input signal
    output reg stable_signal // Debounced (stable) output signal
);

    reg ff1, ff2, ff3, ff4; // Three flip-flops to hold the shifted values

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize all flip-flops and stable signal to 0 on reset
            ff1 <= 0;
            ff2 <= 0;
            ff3 <= 0;
				ff4 <= 0;
            stable_signal <= 0;
        end else begin
            // Shift the values through the flip-flops
            ff1 <= noisy_signal;
            ff2 <= ff1;
            ff3 <= ff2;
				ff4 <= ff3;
            
            // Set stable_signal based on the AND of the first and second flip-flops
            // and the NOT of the third flip-flop
            stable_signal <= ff1 & ff2 & ff3 & ~ff4;
        end
    end
endmodule
