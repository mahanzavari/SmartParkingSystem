module SlotManager (
    input clk,                       // System clock
    input reset,                     // Reset signal
    input [3:0] slot_update,         // Slot vector 
    input timer_status,              // 1 for entrance, 0 for exit
    output reg [3:0] slot_status,    // Occupied status of slots (1 = occupied) 
    output reg [3:0] available_slots // Number of available slots
    // the last two outputs could be merged since the computational cost is not of concern
    // keeping the last two elements results in simpler Design    
);

    initial begin
        slot_status = 4'b0000;      // All slots are initially free
        available_slots = 4;        // All 4 slots are initially available
    end  
    always @(posedge clk or posedge reset) begin 
        if (reset) begin // simply reset
            slot_status <= 4'b0000;
            available_slots <= 4;
        end else begin
            if (timer_status) begin
                // The entrance prosedur 
                if (!slot_status[slot_update]) begin 
                    slot_status[slot_update] <= 1;
                    available_slots <= available_slots - 1; // decrementing the available slots since one slot is being occupied 
                end
            end else begin
                // The EXIT procedure
                if (slot_status[slot_update]) begin
                    slot_status[slot_update] <= 0;
                    available_slots <= available_slots + 1;
                end
            end
        end
    end
endmodule
