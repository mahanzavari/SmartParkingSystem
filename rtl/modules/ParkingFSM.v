
module ParkingFSM (
    input clk,                  // System clock
    input reset,                // Reset signal
    input entry_sensor,         // Entry button/sensor
    input exit_sensor,          // Exit button/sensor
    input [3:0] exit_slot,      // Slot number on car exit
    output reg door_open,       // Door control signal
    output reg full,            // Parking full indicator
    output reg [3:0] slot_assigned, // Assigned slot for new car
    output reg [3:0] available_slots // Number of available slots
);

    // State encoding
    localparam IDLE           = 3'b000;
    localparam ENTRY_CHECK    = 3'b001;
    localparam SLOT_ASSIGN    = 3'b010;
    localparam EXIT_CHECK     = 3'b011;
    localparam UPDATE_DISPLAY = 3'b100;

    // State registers
    reg [2:0] current_state, next_state;

    // Slot availability register (1 = occupied, 0 = free)
    reg [3:0] slot_status;

    initial begin
        current_state = IDLE;
        available_slots = 4;    // All slots initially available
        slot_status = 4'b0000;  // All slots are free
        full = 0;
        door_open = 0;
    end

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state and output logic
    always @(*) begin
        // Default values
        next_state = current_state;
        door_open = 0;
        slot_assigned = 4'b0000;
        full = (available_slots == 0);

        case (current_state)
            IDLE: begin
                if (entry_sensor && available_slots > 0)
                    next_state = ENTRY_CHECK;
                else if (exit_sensor)
                    next_state = EXIT_CHECK;
            end

            ENTRY_CHECK: begin
                door_open = 1;
                next_state = SLOT_ASSIGN;
            end

            SLOT_ASSIGN: begin
                // Assign the lowest free slot
                if (!slot_status[0])
                    slot_assigned = 4'b0001;
                else if (!slot_status[1])
                    slot_assigned = 4'b0010;
                else if (!slot_status[2])
                    slot_assigned = 4'b0100;
                else if (!slot_status[3])
                    slot_assigned = 4'b1000;

                // Update slot status
                slot_status[slot_assigned] = 1;
                available_slots = available_slots - 1;
                next_state = UPDATE_DISPLAY;
            end

            EXIT_CHECK: begin
                // Free the slot based on exit_slot
                if (slot_status[exit_slot]) begin
                    slot_status[exit_slot] = 0;
                    available_slots = available_slots + 1;
                end
                next_state = UPDATE_DISPLAY;
            end

            UPDATE_DISPLAY: begin
                next_state = IDLE;  // Return to IDLE
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
