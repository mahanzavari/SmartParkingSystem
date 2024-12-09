`timescale 1ns / 1ps

module ClockDivider_tb;
    reg clk_in;
    wire clk_out;

    ClockDivider uut (
        .clk_in(clk_in),
        .clk_out(clk_out)
    );

    initial begin
        clk_in = 0;
    end
        
    always #12.5 clk_in = ~clk_in; // 40 MHz clock -> 25 ns period -> 12.5 ns half period

    initial begin
        $dumpfile("build/clockdivider.vcd");
        $dumpvars(0, ClockDivider_tb);
        $monitor("Time = %0t | clk_in = %b | clk_out = %b", $time, clk_in, clk_out);

        // 1000 million ns, or 1s
        #1000000000;
        
        $finish;
    end
endmodule