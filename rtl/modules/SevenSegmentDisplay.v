module SevenSegmentDisplay (
    input clk,                      // System clock
    input reset,                    // Reset signal
    input [3:0] digit_0,            // Leftmost digit
    input [3:0] digit_1,            // Second digit from the left
    input [3:0] digit_2,            // Third digit from the left
    input [3:0] digit_3,            // Rightmost digit
    output reg [6:0] seg_out,       // 7-segment output
    output reg [3:0] anode          // Active anode signal for 7-segment
);

    reg [3:0] current_digit;        // Current digit being displayed
    reg [1:0] mux_index;            // Multiplexer index for 4 digits
    reg [19:0] clk_div;             // Clock divider for multiplexing

    // 7-segment encoding (hexadecimal)
    function [6:0] seven_seg;
        input [3:0] num;
        begin
            case (num)
                4'h0: seven_seg = 7'b1000000;
                4'h1: seven_seg = 7'b1111001;
                4'h2: seven_seg = 7'b0100100;
                4'h3: seven_seg = 7'b0110000;
                4'h4: seven_seg = 7'b0011001;
                4'h5: seven_seg = 7'b0010010;
                4'h6: seven_seg = 7'b0000010;
                4'h7: seven_seg = 7'b1111000;
                4'h8: seven_seg = 7'b0000000;
                4'h9: seven_seg = 7'b0010000;
                default: seven_seg = 7'b1111111; // Blank for invalid input
            endcase
        end
    endfunction

    // Clock divider for 7-segment multiplexing
    always @(posedge clk or posedge reset) begin
        if (reset)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    // Multiplexing logic
    always @(posedge clk_div[19] or posedge reset) begin
        if (reset)
            mux_index <= 0;
        else
            mux_index <= mux_index + 1;
    end

    // Display logic
    always @(*) begin
        case (mux_index)
            2'b00: begin
                current_digit = digit_0; // Leftmost digit
                anode = 4'b1110;         // Activate first digit
            end
            2'b01: begin
                current_digit = digit_1; // Second digit
                anode = 4'b1101;         // Activate second digit
            end
            2'b10: begin
                current_digit = digit_2; // Third digit
                anode = 4'b1011;         // Activate third digit
            end
            2'b11: begin
                current_digit = digit_3; // Rightmost digit
                anode = 4'b0111;         // Activate fourth digit
            end
            default: begin
                current_digit = 4'b1111; // Blank for invalid state
                anode = 4'b1111;         // Deactivate all anodes
            end
        endcase
        seg_out = seven_seg(current_digit);
    end
endmodule
