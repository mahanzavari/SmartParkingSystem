`timescale 1ns/1ps
// `include "ParkingFSM.v"
module ParkingFSM_tb;

    reg clk;
    reg reset;
    reg entry_sensor;
    reg exit_sensor;
    reg [1:0] exit_location;
    wire door_open;
    wire full_light;
    wire [2:0] occupancy;
    wire [3:0] current_state;
    wire [1:0] best_slot;

    integer infile, outfile, status;
    reg [3:0] input_line;
    reg [3:0] free_slots;

    // Instantiate the FSM
    ParkingFSM uut (
        .clk(clk),
        .reset(reset),
        .entry_sensor(entry_sensor),
        .exit_sensor(exit_sensor),
        .exit_location(exit_location),
        .door_open(door_open),
        .full_light(full_light),
        .current_state(current_state),
        .capacity(occupancy),
        .best_slot(best_slot)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 ns clock period
    end

    initial begin
        // Open input and output files
        infile = $fopen("/input.txt", "r");
        outfile = $fopen("/output.txt", "w");
        if (infile == 0) begin
            $display("Error: Unable to open input file (input.txt). Ensure the file exists.");
            $finish;
        end
        if (outfile == 0) begin
            $display("Error: Unable to open output file (output.txt). Check write permissions.");
            $finish;
        end


        free_slots = 4;

        while (!$feof(infile)) begin
            // Read the entire 4-bit string from the file
            status = $fscanf(infile, "%b\n", input_line);

            if (status != 1) begin
                $display("Error: Malformed input file.");
                $finish;
            end

            // Extract values from the 4-bit string
            entry_sensor = input_line[3];  // Most significant bit
            exit_sensor = input_line[2];   // Second most significant bit
            exit_location = input_line[1:0]; // Last two bits represent exit_location

            #10; // Wait for FSM to process inputs

            // Calculate free slots
            free_slots = 4 - current_state[3] - current_state[2] - current_state[1] - current_state[0];

            // Write outputs to file
            $fwrite(outfile, "%04b [%0d,%0d]", current_state, free_slots, best_slot);

            // Add additional info for "door" and "Full" indications
            if (door_open) $fwrite(outfile, " door");
            if (full_light) $fwrite(outfile, " Full");
            $fwrite(outfile, "\n");
        end

        $fclose(infile);
        $fclose(outfile);

        $finish;
    end

endmodule