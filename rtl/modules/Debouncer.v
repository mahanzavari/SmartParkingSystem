// Debouncer module that filters out noise from a noisy input signal by sampling
// it over multiple clock cycles. The output `stable_signal` becomes high when 
// the last N consecutive samples are all 1s, and low when they are all 0s. 
// It uses a shift register to store the past N samples, and a reset sets the 
// signal to a known state.

module Debouncer (
    input clk,
    input reset,
    input noisy_signal,
    output reg stable_signal
);
    parameter N = 8; // Number of samples in the shift register
    reg [N-1:0] shift_reg; // Shift register to hold the last N samples

    always @(posedge clk or posedge reset) 
    begin
        if (reset) begin
            shift_reg <= {N{1'b0}}; // Clear the shift register
            stable_signal <= 1'b0;  // Default stable state
        end else begin
            shift_reg <= {shift_reg[N-2:0], noisy_signal}; // Shift in the new sample
            // Check if all samples are 1 or 0 to stabilize the signal
            if (shift_reg == {N{1'b1}})
                stable_signal <= 1'b1;
            else if (shift_reg == {N{1'b0}})
                stable_signal <= 1'b0;
        end
    end
endmodule
