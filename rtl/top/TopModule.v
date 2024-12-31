`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:19:20 12/31/2024 
// Design Name: 
// Module Name:    TopModule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TopModule(
    input wire clk,
    input wire reset,
    input wire entry_sensor,
    input wire exit_sensor,
    //input wire echo,
    input wire [3:0] exit_location, // Location of the car exiting
    //output wire [6:0] seg_display_left_1, // Leftmost 7-segment display
    //output wire trig,
    //output wire [6:0] seg_display_left_2, // Second leftmost 7-segment display
    //output wire [6:0] seg_display_right_1, // Rightmost 7-segment display
    //output wire [6:0] seg_display_right_2, // Second rightmost 7-segment display
    output reg door_open_light,
    output wire full_light,
	 output wire[3:0] current_state
);

    // Internal wires and registers
    wire [3:0] best_slot;
    wire door_open_signal;
    wire full_signal;
    wire [3:0] car_exit_signal;
    //wire [3:0] timer_display_left;
    //wire [3:0] timer_display_right;
    wire [1:0] capacity_display;

    wire [3:0] bcd_capacity_display;
    wire [3:0] bcd_exit_location;

    wire [6:0] seg_capacity_left_1;
    wire [6:0] seg_capacity_left_2;

    // Debouncers for input signals
    wire entry_sensor_db;
    wire exit_sensor_db;

    Debouncer debouncer_entry (
        .clk(clk),
        .reset(reset),
        .noisy_signal(entry_sensor),
        .stable_signal(entry_sensor_db)
    );

    Debouncer debouncer_exit (
        .clk(clk),
        .reset(reset),
        .noisy_signal(exit_sensor),
        .stable_signal(exit_sensor_db)
    );

    Debouncer debouncer_location (
        .clk(clk),
        .reset(reset),
        .noisy_signal(exit_location), // Reduce location signal to a single bit for debouncing
        .stable_signal(car_exit_signal)
    );

    // FSM Module
    ParkingFSM parking_fsm (
        .clk(clk),
        .reset(reset),
        .entry_sensor(entry_sensor_db),
        .exit_sensor(exit_sensor_db),
        .exit_location(exit_location),
        .door_open(door_open_signal),
        .full_light(full_signal),
        .current_state(current_state),
        .capacity(capacity_display),
        .best_slot(best_slot)
    );
	 
	 
	 
	 	 ///////////////////////////
	 wire clk_1Hz;
	 wire clk_2Hz;
	 ClockDivider freq (
		.clk(clk),
		.reset(reset),
		.clk_1Hz(clk_1Hz),
		.clk_2Hz(clk_2Hz)
		);

	 
	 
	 
	 
//	 reg  [3:0] door_counter;
//	 always @(posedge clk_1Hz or posedge door_open_signal or posedge clk_2Hz) begin
//		if (door_open_signal)begin 
//			door_counter <= 4'b0000;
//	//door_open_light <= 1'b1;
//		end
//		if (door_counter == 4'b1010) begin
//			 door_open_light<= 1'b0;
//		end
//		else begin
//			if (clk_1Hz) begin
//				door_counter <= door_counter + 1;
//			end
//			if (clk_2Hz) begin
//				door_open_light <= ~ door_open_light;
//			end
//		end
//	 end


    reg [3:0] door_counter;
    reg state; // 0: Door closed, 1: Door open

    always @(posedge clk_1Hz or posedge door_open_signal) begin
        if (door_open_signal) begin
            door_counter <= 4'b0000;
            state <= 1'b1;
        end else if (door_counter == 4'b1010) begin
            state <= 1'b0;
        end else if (state == 1'b1) begin
            door_counter <= door_counter + 1;
        end
    end

    // Blinking light logic handled with clk_2Hz
    always @(posedge clk_2Hz) begin
        if (state == 1'b1) begin
            door_open_light <= ~door_open_light;
        end
    end

		

    // Slot Manager (handles occupancy and slot assignments)
    //SlotManager slot_manager (
    //    .clk(clk),
    //    .reset(reset),
    //    .entry_sensor(entry_sensor_db),
    //    .exit_sensor(exit_sensor_db),
    //    .exit_location(exit_location),
    ///    .current_state(current_state),
    //    .best_slot(best_slot),
    //    .slot_status(car_exit_signal)
    //);

    // Timer Module (handles timing and display logic)
    //Timer timer_module (
    //    .clk(clk),
    //    .reset(reset),
    //    .car_entry(car_exit_signal),
    //    .car_exit(exit_location),
    //    .bcd_display_left(timer_display_left),
    //    .bcd_display_right(timer_display_right)
    //);

    // BCD to 7-Segment Display Controllers
    //DisplayDriver display_left_1 (
    //    .bcd(timer_display_left),
    //    .segments(seg_display_left_1)
    //);

    //DisplayDriver display_left_2 (
    //    .bcd(timer_display_right),
    //    .segments(seg_display_left_2)
    //);

    //DisplayDriver display_right_1 (
	 // 	  .clk
    //    .bcd(capacity_display),
    //    .segments(seg_display_right_1)
    //);

    //DisplayDriver display_right_2 (
    //    .bcd(exit_location[3:0]),
    //    .segments(seg_display_right_2)
    //);

    //UltrasonicSensor ultrasonic_sensor (
    //    .clk(clk),
    //    .reset(reset),
    //    .echo(echo),
    //    .trig(trig),
    //    .detected(detected)
    //);
    // Output signals

    assign full_light = full_signal;


endmodule
