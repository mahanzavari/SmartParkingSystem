module DisplayDriver (
    input clk,                      // System clock
    input reset,                    // Reset signal
    input [3:0] available_slots,    // Number of available slots
    input [3:0] assigned_slot,      // Assigned parking slot
    output reg [6:0] seg_out,       // 7-segment output
    output reg [3:0] anode          // Active anode signal for 7-segment
);

    reg [3:0] digit;                // Current digit to display
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
                default: seven_seg = 7'b1111111;
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
                digit = available_slots; // Display available slots
                anode = 4'b1110;         // Activate first digit
            end
            2'b01: begin
                digit = assigned_slot;   // Display assigned slot
                anode = 4'b1101;         // Activate second digit
            end
            default: begin
                digit = 4'b1111;         // Blank for unused digits
                anode = 4'b1111;
            end
        endcase
        seg_out = seven_seg(digit);
    end
endmodule
