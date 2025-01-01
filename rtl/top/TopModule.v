`timescale 1ns / 1ps

module TopModule(
    input wire clk,
    input wire reset,
    input wire entry_echo,          // Echo signal for entry sensor
    input wire exit_echo,           // Echo signal for exit sensor
    output wire entry_trig,         // Trigger signal for entry sensor
    output wire exit_trig,          // Trigger signal for exit sensor
    output reg door_status_light,   // Indicates the door status (blinking when open)
    output reg lot_full_light,      // Indicates when the parking lot is full (blinking logic)
    output wire [3:0] parking_state, // Parking current state
    output wire [6:0] seg_out,      // Seven-segment output
    output wire [3:0] anode         // Anode signals for 7-segment display
);

    // <------<< Ultrasonic for entry and exit sensor
    wire entry_detected;
    wire exit_detected;

    // Ultrasonic Sensor Modules
    UltrasonicSensor entry_ultrasonic (
        .clk(clk),
        .reset(reset),
        .echo(entry_echo),
        .trig(entry_trig),
        .detected(entry_detected)  // Car detected at entry
    );

    UltrasonicSensor exit_ultrasonic (
        .clk(clk),
        .reset(reset),
        .echo(exit_echo),
        .trig(exit_trig),
        .detected(exit_detected)   // Car detected at exit
    );

    // <------<< Internal wires >>------>

    // Debounced wires
    wire [1:0] debounced_exit_location;

    // Door and full signals
    wire door_open_signal;
    wire lot_full_signal;

    // Clock division outputs
    wire clk_1Hz;
    wire clk_2Hz;

    // Parking status
    wire [3:0] parking_state_wire;
    wire [2:0] parking_capacity;
    wire [1:0] best_slot;

    // <------<< Helper modules >>------>

    // Clock Divider for generating 1Hz and 2Hz clocks
    ClockDivider clock_divider (
        .clk(clk),
        .reset(reset),
        .clk_1Hz(clk_1Hz),
        .clk_2Hz(clk_2Hz)
    );
    
    // Debouncing each bit of the `exit_location` signal
    wire debounced_exit_location_bit0;
    wire debounced_exit_location_bit1;

    Debouncer location_debouncer_bit0 (
        .clk(clk),
        .reset(reset),
        .noisy_signal(exit_location[0]),
        .stable_signal(debounced_exit_location_bit0)
    );

    Debouncer location_debouncer_bit1 (
        .clk(clk),
        .reset(reset),
        .noisy_signal(exit_location[1]),
        .stable_signal(debounced_exit_location_bit1)
    );

    // Combine the debounced bits back into a 2-bit signal
    assign debounced_exit_location = {debounced_exit_location_bit1, debounced_exit_location_bit0};

    // <------<< FSM Module for Parking System >>------>

    ParkingFSM parking_fsm (
        .clk(clk),
        .reset(reset),
        .entry_sensor(entry_detected),
        .exit_sensor(exit_detected),
        .exit_location(debounced_exit_location),
        .door_open(door_open_signal),
        .full_light(lot_full_signal),
        .current_state(parking_state_wire),
        .capacity(parking_capacity),
        .best_slot(best_slot)
    );

    // <------<< Door Status Logic >>------>

    reg [3:0] door_open_timer;
    reg door_active; // 0: Door closed, 1: Door open

    always @(posedge clk_1Hz or posedge clk_2Hz or posedge reset) begin
        if (reset) begin
            door_open_timer <= 4'b0000;
            door_active <= 1'b0;
            door_status_light <= 1'b0;
        end else if (clk_1Hz) begin
            if (door_open_signal) begin
                door_open_timer <= 4'b0000;
                door_active <= 1'b1;
            end else if (door_open_timer == 4'b1010) begin
                door_active <= 1'b0;
            end else if (door_active) begin
                door_open_timer <= door_open_timer + 1;
            end
        end else if (clk_2Hz && door_active) begin
            door_status_light <= ~door_status_light;
        end else begin
            door_status_light <= 1'b0;
        end
    end

    // <------<< Full Signal Blinking Logic >>------>

    reg [1:0] full_blink_counter;
    reg full_blink_active;

    always @(posedge clk_1Hz or posedge reset) begin
        if (reset) begin
            full_blink_counter <= 2'b00;
            full_blink_active <= 1'b0;
            lot_full_light <= 1'b0;
        end else if (lot_full_signal && !full_blink_active) begin
            full_blink_active <= 1'b1;
            full_blink_counter <= 2'b00;
        end else if (full_blink_active) begin
            if (full_blink_counter < 2'b11) begin
                lot_full_light <= ~lot_full_light;
                full_blink_counter <= full_blink_counter + 1;
            end else begin
                full_blink_active <= 1'b0;
                lot_full_light <= 1'b0;
            end
        end
    end

    // <------<< Seven-Segment Display >>------>
    SevenSegmentDisplay seven_segment_display (
        .clk(clk),
        .reset(reset),
        .digit_0(4'b0000),
        .digit_1(parking_capacity),
        .digit_2(4'b0000),
        .digit_3(best_slot),
        .seg_out(seg_out),
        .anode(anode)
    );

    // Output assignments
    assign lot_full_light = lot_full_signal;
    assign parking_state = parking_state_wire;

endmodule
