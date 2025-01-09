`timescale 1ns / 1ps

module Debouncer(
	input clk,
	input reset_n,
	input button,
	output reg debounce
	);


	localparam COUNT_VALUE = 40_000_000 / 5;
	reg [1:0] state;
	reg [25:0] count;
	reg button_sync, button_sync_prev;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			state <= 0;
			debounce <= 0;
			count <= 0;
			button_sync <= 0;
			button_sync_prev <= 0;
		end else begin
			button_sync <= button;
			button_sync_prev <= button_sync;
			debounce <= 0;
	case (state)
		0: begin
			if (button_sync && !button_sync_prev) begin // Detect rising edge
				state <= 1;
				count <= 0;
			end
		end
		1: begin
			if (count < COUNT_VALUE - 1) begin
				count <= count + 1;
			end else begin
				debounce <= 1; // Generate a single pulse
				state <= 0;
			end
		end
		endcase
	end
	end
endmodule
