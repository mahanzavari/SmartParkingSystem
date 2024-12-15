// -------------------------------------------------------------
// Xilinx ISE
// File: [Mahanin or Aminhan Park].v
// Author: [Mahan zavvari & Amin Rezayeean]
// Professors maybe?
// Version: 1.0 
// Date: [12/3/2024]
// Amirkabir University of Technology (Tehran Polytechnic)
// Digital Logic Design Project, fall of 2024
// Description: Smart pakring for now
// -------------------------------------------------------------
`timescale 1ns/1ps
// integrigating all the signals 
module TopIntegrator (
    input wire clk,
    input wire reset,
    input wire entry_sensor,
    input wire exit_sensor,
    input wire echo,
    input wire [3:0] exit_location, // Location of the car exiting
    output wire [6:0] seg_display_left_1, // Leftmost 7-segment display
    output wire trig,
    output wire [6:0] seg_display_left_2, // Second leftmost 7-segment display
    output wire [6:0] seg_display_right_1, // Rightmost 7-segment display
    output wire [6:0] seg_display_right_2, // Second rightmost 7-segment display
    output wire door_open_light,
    output wire full_light
);

    // Internal wires and registers
    wire [3:0] current_state;
    wire [3:0] best_slot;
    wire door_open_signal;
    wire full_signal;

    wire [3:0] car_exit_signal;
    wire [3:0] timer_display_left;
    wire [3:0] timer_display_right;
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
        .btn_input(entry_sensor),
        .btn_output(entry_sensor_db)
    );

    Debouncer debouncer_exit (
        .clk(clk),
        .reset(reset),
        .btn_input(exit_sensor),
        .btn_output(exit_sensor_db)
    );

    Debouncer debouncer_location (
        .clk(clk),
        .reset(reset),
        .btn_input(|exit_location), // Reduce location signal to a single bit for debouncing
        .btn_output(car_exit_signal)
    );

    // FSM Module
    FSM parking_fsm (
        .clk(clk),
        .reset(reset),
        .entry_sensor(entry_sensor_db),
        .exit_sensor(exit_sensor_db),
        .exit_location(exit_location),
        .door_open(door_open_signal),
        .full_light(full_signal),
        .current_state(current_state),
        .capacity_display(capacity_display),
        .best_slot(best_slot)
    );

    // Slot Manager (handles occupancy and slot assignments)
    SlotManager slot_manager (
        .clk(clk),
        .reset(reset),
        .entry_sensor(entry_sensor_db),
        .exit_sensor(exit_sensor_db),
        .exit_location(exit_location),
        .current_state(current_state),
        .best_slot(best_slot),
        .slot_status(car_exit_signal)
    );

    // Timer Module (handles timing and display logic)
    Timer timer_module (
        .clk(clk),
        .reset(reset),
        .car_active(car_exit_signal),
        .car_exit(exit_location),
        .bcd_display_left(timer_display_left),
        .bcd_display_right(timer_display_right)
    );

    // BCD to 7-Segment Display Controllers
    BCDto7Segment display_left_1 (
        .bcd(timer_display_left),
        .segments(seg_display_left_1)
    );

    BCDto7Segment display_left_2 (
        .bcd(timer_display_right),
        .segments(seg_display_left_2)
    );

    BCDto7Segment display_right_1 (
        .bcd(capacity_display),
        .segments(seg_display_right_1)
    );

    BCDto7Segment display_right_2 (
        .bcd(exit_location[3:0]),
        .segments(seg_display_right_2)
    );

    UltrasonicSensor ultrasonic_sensor (
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .trig(trig),
        .detected(detected)
    );
    // Output signals
    assign door_open_light = door_open_signal;
    assign full_light = full_signal;

endmodule


