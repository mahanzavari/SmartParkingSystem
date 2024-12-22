module ParkingFSM (
    input wire clk,
    input wire reset,
    input wire entry_sensor,
    input wire exit_sensor,
    input wire [1:0] exit_location,
    output reg door_open,
    output reg full_light,
    output reg [3:0] current_state,
    output reg [2:0] capacity,
    output reg [1:0] best_slot
);

    reg [3:0] next_state;
    reg is_valid_car_location;

    initial begin
        // Default values
        current_state = 4'b0000;
        next_state = current_state;
        door_open = 1'b0;
        full_light = 1'b0;
        best_slot = 2'b00;
        capacity = 2'b00;
        is_valid_car_location = 1'b0;
    end

    always @(posedge clk or posedge reset) begin
        // Default value
        next_state = current_state;

        // Handle exit_sensor (free the specified slot)
        if (exit_sensor) begin
            case (exit_location)
                2'b00: is_valid_car_location = current_state[0];
                2'b01: is_valid_car_location = current_state[1];
                2'b10: is_valid_car_location = current_state[2];
                2'b11: is_valid_car_location = current_state[3];
                default: is_valid_car_location = 1'b0;
            endcase
            if (is_valid_car_location) begin
                case (exit_location)
                    2'b00: next_state = current_state & ~4'b0001;
                    2'b01: next_state = current_state & ~4'b0010;
                    2'b10: next_state = current_state & ~4'b0100;
                    2'b11: next_state = current_state & ~4'b1000;
                endcase
                door_open = 1'b1;
            end
        end

        // Handle entry_sensor (find nearest slot and update state)
        else if (entry_sensor) begin
            if(current_state != 4'b1111) begin
                case (best_slot)
                    2'b00: next_state = current_state | 4'b0001;
                    2'b01: next_state = current_state | 4'b0010;
                    2'b10: next_state = current_state | 4'b0100;
                    2'b11: next_state = current_state | 4'b1000;
                    default: next_state = current_state; // Should not occur
                endcase
                door_open = 1'b1;
            end
            else
                full_light = 1'b1;
        end

        // State transition and reset logic
        if (reset) begin
            current_state <= 4'b0000;
            door_open <= 1'b0;
            best_slot = 2'b00;
            capacity <= 2'b00;
            is_valid_car_location = 1'b0;
        end else begin
            current_state = next_state;
        end

        // Update capacity based on current state
        capacity = ~current_state[0] + ~current_state[1] + ~current_state[2] + ~current_state[3];

         // Determine best_slot based on the first available slot (rightmost empty)
        case (current_state)
            4'b0000: best_slot = 2'b00;
            4'b0001: best_slot = 2'b01;
            4'b0011: best_slot = 2'b10;
            4'b0111: best_slot = 2'b11;
            default: begin
                if (~current_state[0]) best_slot = 2'b00;
                else if (~current_state[1]) best_slot = 2'b01;
                else if (~current_state[2]) best_slot = 2'b10;
                else if (~current_state[3]) best_slot = 2'b11;
                else best_slot = 2'b00; // Parking full (no slot available) - don't care
            end
        endcase
    end

    // Reset the door and full signal at negative edge of clock
    always @(negedge clk) begin
        full_light <= 1'b0;
        door_open <= 1'b0;
    end
endmodule