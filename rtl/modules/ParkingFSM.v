// FSM for Parking System (Mealy Machine with 16 states)
module ParkingFSM (
    input wire clk,
    input wire reset,
    input wire entry_sensor,         // Signal when a car is entering
    input wire exit_sensor,          // Signal when a car is exiting
    input wire [1:0] exit_location,  // Slot being freed up during exit
    output reg door_open,            // Door control for entry
    output reg full_light,           // Indicates parking is full
    output reg [3:0] occupancy,      // Indicates the occupancy of the parking
    output reg [3:0] current_state,  // Current parking occupancy state
    output reg [1:0] best_slot       // Suggested slot for entry
);

    reg [3:0] next_state;
    reg is_valid_car_location;

    // State Transition Logic (Sequential Logic)
    always @(posedge clk or posedge reset) begin
        if (reset) 
        begin
            current_state <= 4'b0000; // Reset to all slots empty
            occupancy <= 4'b0000;
        end 
        else begin
            current_state <= next_state;
        end
    end

    // Combinational Logic: Next State and Output Logic (Mealy Machine)
    always @(*) begin
        // Default Outputs
        next_state = current_state;
        door_open = 1'b0;
        full_light = 1'b0;
        best_slot = 4'b00;
        is_valid_car_location = 1'b1;

        case (current_state)
            // 0 Slots Occupied
            4'b0000: begin
                door_open = 1'b0;
                full_light = 1'b0; 
                occupancy = 4'b0000;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0001;
                end
            end

            // 1 Slot Occupied
            4'b0001: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0001;
                best_slot = 2'b01;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0011;
                end else if (exit_sensor && exit_location == 2'b00) begin
                    next_state = 4'b0000;
                    door_open = 1'b1;
                end
            end

            // 2 Slots Occupied
            4'b0011: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0011;
                best_slot = 2'b10;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b0010;
                        2'b01: next_state = 4'b0001;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end

            // 3 Slots Occupied
            4'b0111: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0111;
                best_slot = 2'b11;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b0110;
                        2'b01: next_state = 4'b0101;
                        2'b10: next_state = 4'b0011;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end

            // 4 Slots Occupied
            4'b1111: begin
                door_open = 1'b0;
                full_light = 1'b1; // Parking Full
                best_slot = 2'b00; // don't care
                occupancy = 4'b1111;
                if (exit_sensor) begin
                is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b1110;
                        2'b01: next_state = 4'b1101;
                        2'b10: next_state = 4'b1011;
                        2'b11: next_state = 4'b0111;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end

            // 5 Slots: Add transitions for partially freed states
            4'b1110: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1110;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b01: next_state = 4'b1100;
                        2'b10: next_state = 4'b1010;
                        2'b11: next_state = 4'b0110;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 6
            4'b1101: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1101;
                best_slot = 2'b01;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b1100;
                        2'b10: next_state = 4'b1001;
                        2'b11: next_state = 4'b0101;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 7
            4'b1011: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1011;
                best_slot = 2'b10;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b1010;
                        2'b01: next_state = 4'b1001;
                        2'b11: next_state = 4'b0011;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 8
            4'b0110: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0110;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1110;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b01: next_state = 4'b0100;
                        2'b10: next_state = 4'b0010;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end

            // 9
            4'b1100: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1100;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1110;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b10: next_state = 4'b1000;
                        2'b11: next_state = 4'b0100;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 10
            4'b1001: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1001;
                best_slot = 2'b01;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1101;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b1000;
                        2'b11: next_state = 4'b0001;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 11
            4'b0101: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0101;
                best_slot = 2'b01;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0111;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b00: next_state = 4'b0100;
                        2'b10: next_state = 4'b0001;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end

            // 12
            4'b0010: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0010;
                best_slot = 2'b00; 
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0011;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b01: next_state = 4'b0000;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end 
            // 13
            4'b0100: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b0100;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b0101;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b10: next_state = 4'b0000;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 14
            4'b1000: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1000;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1001;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b11: next_state = 4'b0000;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            // 15
            4'b1010: begin
                door_open = 1'b0;
                full_light = 1'b0;
                occupancy = 4'b1010;
                best_slot = 2'b00;
                if (entry_sensor) begin
                    door_open = 1'b1;
                    next_state = 4'b1011;
                end else if (exit_sensor) begin
                    is_valid_car_location = 1;
                    case (exit_location)
                        2'b01: next_state = 4'b1000;
                        2'b11: next_state = 4'b0010;
                        default: is_valid_car_location = 1'b0;
                    endcase
                    if (is_valid_car_location)
                        door_open = 1'b1;
                end
            end
            default: begin
                next_state = 4'b0000;
            end
        endcase
    end
endmodule
