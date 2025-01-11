`timescale 1ns / 1ps

module Multiplexer (
    input wire clk,                  // 40MHz Spartan FPGA clock
    input wire reset,
    input wire [15:0] display_time,  // Output from ParkingTimer
    input wire [3:0] fsm_state,      // Output from ParkingFSM
    output reg [15:0] mux_output     // Output to SevenSegmentDisplay
);

    // Multiplexing logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mux_output <= 16'd0;  // Reset the output
        end else begin
            if (display_time == 16'd0) begin
                mux_output <= {12'd0, fsm_state};  // Output FSM state if display_time is zero
            end else begin
                mux_output <= display_time;  // Output display_time otherwise
            end
        end
    end

endmodule