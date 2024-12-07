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
module SmartParkingSystem (
    input clk,                      
    input reset,
    input entry_sensor,             // Entry button/sensor (debounced!)
    input exit_sensor,              // Exit button/sensor (debounced!)
    input echo,                     // Ultrasonic sensor echo signal
    output trig,                    // Ultrasonic sensor trigger signal
    input [3:0] exit_slot,          // Slot number for exiting car
    output [6:0] seg_out,           // 7-segment display output
    output [3:0] anode,             // Anode signals for 7-segment display
    output door_open,               // Door open indicator
    output full,                    // Parking full indicator
    output [15:0] display_time      // Parking duration display (HH:MM)
);

    // Internal signals
    wire detected;                  // Ultrasonic sensor car detection
    wire [3:0] assigned_slot;       // Slot assigned to the car
    wire [3:0] available_slots;     // Number of available parking slots
    wire [3:0] slot_status;         // Slot occupancy status
    wire [3:0] stable_exit; // Debounced sensor signals
    wire stable_entry;
    wire clk_div;                   // Divided clock for timing 
    // Instantiate Clock Divider
    ClockDivider clock_divider (
        .clk_in(clk),
        .clk_out(clk_div)
    );   
    // Instantiate Debouncers
    Debouncer entry_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_signal(entry_sensor),
        .stable_signal(stable_entry)
    );   
    Debouncer exit_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_signal(exit_sensor),
        .stable_signal(stable_exit)
    );   
    // Instantiate FSM
    ParkingFSM fsm (
        .clk(clk),
        .reset(reset),
        .entry_sensor(stable_entry),
        .exit_sensor(stable_exit),
        .exit_slot(exit_slot),
        .door_open(door_open),
        .full(full),
        .slot_assigned(assigned_slot),
        .available_slots(available_slots)
    );
    // Instantiate Slot Manager
    SlotManager slot_manager (
        .clk(clk),
        .reset(reset),
        .slot_update(assigned_slot),
        .timer_status(stable_entry),
        .slot_status(slot_status),
        .available_slots(available_slots)
    );   
    // Instantiate Display Driver
    DisplayDriver display_driver (
        .clk(clk),
        .reset(reset),
        .available_slots(available_slots),
        .assigned_slot(assigned_slot),
        .seg_out(seg_out),
        .anode(anode)
    );   
    // Instantiate Ultrasonic Sensor
    UltrasonicSensor ultrasonic_sensor (
        .clk(clk),
        .reset(reset),
        .echo(echo),
        .trig(trig),
        .detected(detected)
    );
    // Instantiate Parking Timer
    ParkingTimer parking_timer (
        .clk(clk_div),               // Use divided clock for 1-second intervals
        .reset(reset),
        .car_entry(exit_slot),
        .car_exit(stable_exit),   // Start or stop based on exit signal
        .display_time(display_time)
    );
endmodule

