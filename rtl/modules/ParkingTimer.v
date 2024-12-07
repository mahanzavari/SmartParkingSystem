module ParkingTimer (
    input clk,                     // System clock
    input reset,                   // Reset signal
    input [3:0] car_entry,         // Signals for car entry in each slot
    input [3:0] car_exit,          // Signals for car exit in each slot
    output reg [15:0] display_time // HH:MM ([15:8] for Hours, [7:0] for Minutes)
);

    reg [15:0] slot_timer [3:0];   // Array of counters for each slot
    reg [1:0] display_slot;        // Currently displayed slot (0–3)
    reg [3:0] active_slots;        // Active slots tracking car presence
    reg [23:0] display_timer;      // Timer for 15-second display cycles // REPLACE IT WITH A FREQ DIVIDER

    // Increment timers for active slots
    always @(posedge clk or posedge reset) begin
        if (reset) begin // simply reset everything to their initial state
            slot_timer[0] <= 16'd0;
            slot_timer[1] <= 16'd0;
            slot_timer[2] <= 16'd0;
            slot_timer[3] <= 16'd0;
            active_slots <= 4'b0;
            display_timer <= 24'd0;
            display_slot <= 2'd0;
        end else begin
            // Update active slots
            active_slots <= (active_slots | car_entry) & ~car_exit;

            // Increment counters for active slots
            if (active_slots[0]) slot_timer[0] <= slot_timer[0] + 1;
            if (active_slots[1]) slot_timer[1] <= slot_timer[1] + 1;
            if (active_slots[2]) slot_timer[2] <= slot_timer[2] + 1;
            if (active_slots[3]) slot_timer[3] <= slot_timer[3] + 1;

            // Reset counter for exited cars
            if (car_exit[0]) slot_timer[0] <= 16'd0;
            if (car_exit[1]) slot_timer[1] <= 16'd0;
            if (car_exit[2]) slot_timer[2] <= 16'd0;
            if (car_exit[3]) slot_timer[3] <= 16'd0;

            // Update display timer
            display_timer <= display_timer + 1;

            // Cycle display slot every 15 seconds
            if (display_timer == 24'd15_000_000) begin
                display_timer <= 24'd0;
                display_slot <= display_slot + 1;
            end
        end
    end

    // Update display_time based on the currently displayed slot
    always @(*) begin
        display_time[15:8] = slot_timer[display_slot] / 60; // Hours
        display_time[7:0] = slot_timer[display_slot] % 60;  // Minutes
    end

endmodule
