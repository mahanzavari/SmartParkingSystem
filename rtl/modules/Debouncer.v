`timescale 1ns / 1ps
module button_debounce
  #(
    parameter clk_freq = 40_000_000,
    debouncing_fre = 2
    ) // cool idea that I got from a friend
  (
   input clk,     // clock
   input reset, 
   input noisy_signal,  // input noisy signal
   output reg stable_single_clock_signal // debounced 1-cycle signal
   );
  reg [25:0] count;
  reg noisy_sync, prev_noisy_sync;
  reg [1:0] curr_state;
  localparam COUNT_VALUE = clk_freq / debouncing_fre;

  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      curr_state <= 0;
      stable_single_clock_signal <= 0;
      count <= 0;
      noisy_sync <= 0;
      prev_noisy_sync <= 0;
    end else begin
      noisy_sync <= noisy_signal;
      prev_noisy_sync <= noisy_sync;
      stable_single_clock_signal <= 0;
      case (curr_state)
        0: begin
          if (noisy_sync && !prev_noisy_sync) begin // Detect rising edge
            curr_state <= 1;
            count <= 0;
          end
        end
        1: begin
          if (count < COUNT_VALUE - 1) begin
            count <= count + 1;
          end else begin
            stable_single_clock_signal <= 1; // Generate a single jump
            curr_state <= 0;
          end
        end
      endcase
    end
  end
 endmodule
