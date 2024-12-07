module Debouncer (
    input clk,             // System clock
    input reset,           // Reset signal
    input noisy_signal,    // NOISY input signal
    output reg stable_signal // DEBOUNCED output signal
);
    parameter N = 8; // Number of samples in the shift registe  
    reg [N-1:0] shift_reg; // Shift register that holds the last n consecutive states   
    always @(posedge clk or posedge reset) begin
        if (reset) begin // simply resets the module
             shift_reg <= 0;
             stable_signal <= 0;
        end else begin
             shift_reg <= {shift_reg[N-2:0], noisy_signal}; // apending the NOISY input to the register
             if (shift_reg == {N{1'b1}}) // Is it all consecutive 1s?
                  stable_signal <= 1;
             else if (shift_reg == {N{1'b0}}) // or is it 0s
                  stable_signal <= 0;
        end
    end
endmodule