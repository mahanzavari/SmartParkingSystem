module SevenSegmentDisplay (
    input clk,                      // System clock
    input reset,                    // Reset signal
    input [3:0] digit_0,            // Leftmost digit
    input [3:0] digit_1,            // Second digit from the left
    input [3:0] digit_2,            // Third digit from the left
    input [3:0] digit_3,            // Rightmost digit
    output reg [7:0] seg_out,       // 7-segment output (8 bits)
    output reg [4:0] anode          // Active anode signal for 7-segment (5 bits)
);

    reg [3:0] current_digit;        // Current digit being displayed
    reg [1:0] mux_index;            // Multiplexer index for 4 digits

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
            default: seven_seg = 8'b01000000; // Blank for invalid input
        endcase
    end
endfunction

    // Multiplexing logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            mux_index <= 0;
        else if (mux_index < 2'b11) begin
            mux_index <= mux_index + 1;
		  end else begin
			   mux_index <= 2'b00;
		  end
    end

    // Display logic
    always @(*) begin
        case (mux_index)
            2'b00: begin
                current_digit = digit_0; // Leftmost digit
                anode = 5'b00001;        // Activate first digit
            end
            2'b01: begin
                current_digit = digit_1; // Second digit
                anode = 5'b00010;        // Activate second digit
            end
            2'b10: begin
                current_digit = digit_2; // Third digit
                anode = 5'b00100;        // Activate third digit
            end
            2'b11: begin
                current_digit = digit_3; // Rightmost digit
                anode = 5'b01000;        // Activate fourth digit
            end
            default: begin
                current_digit = 4'b1111;
                anode = 5'b11111; // Deactivate all anodes
            end
        endcase
        seg_out = seven_seg(current_digit); // Set segment output
    end
endmodule
