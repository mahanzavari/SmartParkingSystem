`timescale 1ns / 1ps

module ParkingTimer (
    input clk_1Hz,                     
    input reset,                   
    input [3:0] car_entry,         // Signals for car entry in each slot
    input [3:0] car_exit,          // Signals for car exit in each slot
    output reg [15:0] display_time // HH:MM ([15:8] for Hours, [7:0] for Minutes)
);

    reg [15:0] slot_timer [3:0];   // Array of counters for each slot
    reg [3:0] active_slots;        // Active slots tracking car presence
    reg [23:0] display_timer;      // Timer for 15-second display cycles
    reg [1:0] display_slot;        // Currently displayed slot (0–3)
    reg display_active;            // Flag to indicate if display is active


    always @(posedge clk_1Hz or posedge reset) begin
        if (reset) begin
            slot_timer[0] <= 16'd0;
            slot_timer[1] <= 16'd0;
            slot_timer[2] <= 16'd0;
            slot_timer[3] <= 16'd0;
            active_slots <= 4'b0;
            display_timer <= 24'd0;
            display_slot <= 2'd0;
            display_active <= 1'b0;
        end else begin
            active_slots <= (active_slots | car_entry) & ~car_exit;

            if (active_slots[0]) slot_timer[0] <= slot_timer[0] + 1;
            if (active_slots[1]) slot_timer[1] <= slot_timer[1] + 1;
            if (active_slots[2]) slot_timer[2] <= slot_timer[2] + 1;
            if (active_slots[3]) slot_timer[3] <= slot_timer[3] + 1;

            // bitwise OR (The if argument)
            if (|car_exit) begin
                display_active <= 1'b1; // Activate display
                display_timer <= 24'd0; // Reset display timer
                case (1'b1) // Find the exiting slot
                    car_exit[0]: display_slot <= 2'b00;
                    car_exit[1]: display_slot <= 2'b01;
                    car_exit[2]: display_slot <= 2'b10;
                    car_exit[3]: display_slot <= 2'b11;
                endcase
            end

            
            if (display_active) begin
                if (display_timer == 24'd15_000_000) begin // 15 seconds
                    display_active <= 1'b0; // Deactivate display
                end else begin
                    display_timer <= display_timer + 1; 
                end
            end
        end
    end

    // Update display_time based on the currently displayed slot - Combinational
    always @(*) begin
        if (display_active) begin
            case (display_slot)
                2'b00: display_time = slot_timer[0]; 
                2'b01: display_time = slot_timer[1]; 
                2'b10: display_time = slot_timer[2]; 
                2'b11: display_time = slot_timer[3]; 
                default: display_time = 16'd0;       
            endcase
        end else begin
            display_time = 16'd0; // Display nothing if no car is exiting
        end
    end
endmodule