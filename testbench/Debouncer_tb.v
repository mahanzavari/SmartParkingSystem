`timescale 1ns / 1ps

module Debouncer_tb;
    reg clk;
    reg reset;
    reg noisy_signal;
    wire stable_signal;

    Debouncer uut (
        .clk(clk),
        .reset(reset),
        .noisy_signal(noisy_signal),
        .stable_signal(stable_signal)
    );

    // Clock generation (40 MHz)
    always #12.5 clk = ~clk;  // 40 MHz clock -> 25 ns period -> 12.5 ns half period

    initial begin
        clk = 0;
        reset = 0;
        noisy_signal = 0;

        reset = 1;
        #50 reset = 0;

        #100 noisy_signal = 1;
        #100 noisy_signal = 0;
        #100 noisy_signal = 1;
        #200 noisy_signal = 0;
        #100 noisy_signal = 1;

        #1000;

        $finish;
    end

    // Monitor the signals during the simulation
    initial begin
        $monitor("Time = %0t | reset = %b | noisy_signal = %b | stable_signal = %b", 
                 $time, reset, noisy_signal, stable_signal);
        $dumpfile("build/debouncer.vcd");
        $dumpvars(0, Debouncer_tb);

    end
endmodule
