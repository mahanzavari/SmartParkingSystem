module SevenSegmentDisplay (
    input clk,                      // System clock
    input reset,                    // Reset signal
    input [3:0] digit_0,            // Rightmost digit
    input [3:0] digit_1,            // Second digit from the right
    input [3:0] digit_2,            // Third digit from the right
    input [3:0] digit_3,            // Leftmost digit
    input enable_colon,             // Enable the colon in the middle
    output reg [7:0] seg_out,       // 7-segment output (8 bits)
    output reg [4:0] anode          // Active anode signal for 7-segment (5 bits)
);

    reg [3:0] current_digit;        // Current digit being displayed
    reg [2:0] mux_index;            // Multiplexer index (0-4 for digits and colon)

    // 7-segment encoding (hexadecimal)
    function [7:0] seven_seg;
    input [3:0] num;
    begin
        case (num)
            4'h0: seven_seg = 8'b00111111; // 0
            4'h1: seven_seg = 8'b00000110; // 1
            4'h2: seven_seg = 8'b01011011; // 2
            4'h3: seven_seg = 8'b01001111; // 3
            4'h4: seven_seg = 8'b01100110; // 4
            default: seven_seg = 8'b01000000; // Dash for invalid input
        endcase
    end
endfunction

    // Multiplexing logic (5 states: 4 digits + colon)
    always @(posedge clk or posedge reset) begin
        if (reset)
            mux_index <= 0;
        else if (mux_index < 3'b100)
            mux_index <= mux_index + 1;
        else
            mux_index <= 3'b000;
    end

    // Display logic
    always @(*) begin
        case (mux_index)
            3'b000: begin
                current_digit = digit_0; 
                anode = 5'b00001;       // Activate rightmost digit
                seg_out = seven_seg(current_digit);
            end
            3'b001: begin
                current_digit = digit_1; 
                anode = 5'b00010;       // Activate second digit from the right
                seg_out = seven_seg(current_digit);
            end
            3'b010: begin
                current_digit = digit_2; 
                anode = 5'b00100;       // Activate third digit from the right
                seg_out = seven_seg(current_digit);
            end
            3'b011: begin
                current_digit = digit_3; 
                anode = 5'b01000;       // Activate leftmost digit
                seg_out = seven_seg(current_digit);
            end
            3'b100: begin
                anode = 5'b10000;       // Activate colon
                seg_out = enable_colon ? 8'b00000010 : 8'b00000000; // Enable or blank colon
            end
            default: begin
                anode = 5'b11111; 
                seg_out = 8'b00000000;  // Blank output
            end
        endcase
    end
endmodule
