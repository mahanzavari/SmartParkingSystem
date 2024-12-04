
/*
The UltraSoundSensor module that uses the HC-SR04 sensor 
useful informantion about this sensor that help you out understading it
The DataSheet Link : https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf
it has four pins:
1. Vcc (5V supply)
2. Trigger Pulse Input
3. Echo Pulse Output
4. Ground (0V)
It's Elevtric Parameter :
- Working Frequncy : 40Hz
- Its detection Range : [2cm , 4m]
- Measuring Angle : 15 Degrees (The cone-shaped detection area has a spread angle of 15 degrees)
This module works by emitting burst of UltraSonic pulses and measure how
long they takes to go back 
The formula that is used is pretty simple :  
IF the signal back, through high level , time of high output IO duration is 
the time from sending ultrasonic to returning. 
    Formula: uS / 58 = centimeters or uS / 148 =inch; or: the 
    range = high level time * velocity (340M/S) / 2,
Attention : 
    - When tested objects, the range of area is not less than 0.5 square meters 
and the plane requests as smooth as possible, otherwise ,it will affect the 
results of measuring.
*/
module UltrasonicSensor (
    input clk,                  // System clock
    input reset,                // Reset signal
    input echo,                 // Echo signal from sensor
    output reg trig,            // Trigger signal to sensor
    output reg detected         // Car detected (1 = Yes, 0 = No)
);

    reg [19:0] counter;         // Counter for timing
    reg [19:0] echo_time;       // Time measured for echo
    reg state;                  // State for sensor control (0 = trigger, 1 = measure)

    parameter TRIG_TIME = 20'd1000;  // Trigger pulse duration
    parameter MAX_TIME = 20'd60000; // Max time to consider an object

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trig <= 0;
            detected <= 0;
            counter <= 0;
            echo_time <= 0;
            state <= 0;
        end else begin
            case (state)
                0: begin
                    // Trigger state: Send a 10us pulse
                    trig <= (counter < TRIG_TIME); // asset trig to 1 while this condition is True
                    counter <= counter + 1; //ensuring that the trigger time interval is exactly 10 µs 
                    if (counter == TRIG_TIME) begin
                        counter <= 0;
                        state <= 1;
                    end
                end
                1: begin
                    // Measure echo time
                    if (echo) begin
                        echo_time <= echo_time + 1; // calculating the echotime when the sensor is receiving the Echo
                    end else if (echo_time > 0) begin
                        // Check if distance is within range
                        detected <= (echo_time < MAX_TIME); // detected if the object is within the sensor's range
                        echo_time <= 0; // reset
                        state <= 0;
                    end
                end
            endcase
        end
    end
endmodule

