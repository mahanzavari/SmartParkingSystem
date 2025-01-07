module Debouncer (
    input wire clk,           // System clock
    input wire reset,         // Reset signal (active high)
    input wire button,        // Raw button input
    output wire debounced_pulse // One-clock pulse output
);

    // Flip-flops to track button state
    reg button_ff1, button_ff2, button_ff3;

    // Sequential logic for flip-flops
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_ff1 <= 0;
            button_ff2 <= 0;
            button_ff3 <= 0;
        end else begin
            button_ff1 <= button;           // Synchronize raw input to clk
            button_ff2 <= button_ff1;       // Delay by one clock cycle
            button_ff3 <= button_ff2;       // Delay by another clock cycle
        end
    end

    // Generate one-clock pulse when button is pressed
    assign debounced_pulse = button_ff1 & button_ff2 & ~button_ff3;

endmodule
