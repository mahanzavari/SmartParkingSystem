`timescale 1ns / 1ps

module TopModule(
    input wire clk,
    input wire reset,
    input wire entry_sensor,
    input wire exit_sensor,
    input wire [1:0] exit_location, // Location of the car exiting
    output reg door_status_light,   // Indicates the door status (blinking when open)
    output reg lot_full_light,      // Indicates when the parking lot is full
    output wire [3:0] parking_state,// parking current state
    output wire [7:0] seg_out,      // Seven-segment output
    output wire [4:0] anode         // Anode signals for 7-segment display
);

//     <------<< Internal wires >>------>
    wire debounced_entry_signal;
    wire debounced_exit_signal;
	 wire door_open_signal;
    wire lot_full_signal;

    wire clk_1Hz;
    wire clk_2Hz;
	 wire clk_4Hz;
    wire clk_50Hz;
  	 wire clk_500Hz;

    wire [2:0] parking_capacity;
    wire [1:0] best_slot;
	 
	 initial begin
		door_status_light = 1'b0;
		lot_full_light = 1'b0;
	end
 // <------<< Helper modules >>------>

	ClockDivider clock_divider (
		.clk(clk),
      .reset(reset),
      .clk_1Hz(clk_1Hz),
      .clk_2Hz(clk_2Hz),
		.clk_4Hz(clk_4Hz),
      .clk_50Hz(clk_50Hz),
	   .clk_500Hz(clk_500Hz)
  );
	Debouncer entry_debouncer (
        .clk(clk),
        .reset_n(~reset),
        .button(~entry_sensor),
        .debounce(debounced_entry_signal)
    );

     Debouncer exit_debouncer (
        .clk(clk),
        .reset_n(~reset),
        .button(~exit_sensor),
        .debounce(debounced_exit_signal)
    );

	  // <------<< FSM Module for Parking System >>------>
	 
    ParkingFSM parking_fsm (
        .clk(clk),
        .reset(reset),
		  .enable(1),
        .entry_sensor(debounced_entry_signal),
        .exit_sensor(debounced_exit_signal),
        .exit_location(exit_location),
        .door_open(door_open_signal),
        .full_light(lot_full_signal),
        .current_state(parking_state),
        .capacity(parking_capacity),
        .best_slot(best_slot)
    );
	 
	     // <------<< Door Status Logic >>------>

    reg [4:0] door_open_timer = 5'b00000;
    reg door_active = 1'b0; // 0: Door closed, 1: Door open
	 
	 // Combined always block without reset
    always @(posedge clk_4Hz or posedge door_open_signal) begin
        if (door_open_signal) begin
            door_open_timer <= 5'b00000;
            door_active <= 1'b1;
            door_status_light <= 1'b1;
        end else if (door_active && door_open_timer < 5'b10011) begin
            door_status_light <= ~door_status_light;
				 door_open_timer <= door_open_timer + 5'b00001;
        end else if (door_open_timer >= 5'b10011) begin
            door_active <= 1'b0;
            door_status_light <= 1'b0;
        end
    end
	 
	 reg [2:0] full_blink_counter = 3'b000;
    reg full_blink_active = 1'b0;
	 
	 always @(posedge clk_2Hz or posedge lot_full_signal) begin
        if (lot_full_signal) begin
            full_blink_counter <= 3'b000;
            full_blink_active <= 1'b1;
            lot_full_light <= 1'b1;
        end else if (full_blink_active && full_blink_counter < 3'b101) begin
            lot_full_light <= ~lot_full_light;
				 full_blink_counter <= full_blink_counter + 3'b001;
        end else if (full_blink_counter >= 3'b101) begin
            full_blink_active <= 1'b0;
            lot_full_light <= 1'b0;
        end
    end
	 
	 //     <------<< Seven-Segment Display >>------>
    SevenSegmentDisplay seven_segment_display (
        .clk(clk_500Hz),
        .reset(reset),
        .digit_0((parking_capacity == 3'b000) ? 4'b0101 : {2'b00,best_slot}),
        .digit_1((parking_capacity == 3'b000) ? 4'b0101 : 4'b0000),
        .digit_2({1'b0,parking_capacity}),
        .digit_3(4'b0000),
        .seg_out(seg_out),
        .anode(anode)
    );

endmodule
