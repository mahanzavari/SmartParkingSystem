
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
outputs: 
- When the distanceRAW value is below ENTRY_THRESHOLD, the car_entry signal is asserted.
- When the distanceRAW value is above EXIT_THRESHOLD, the car_exit signal is asserted.
Formula: uS / 58 = centimeters or uS / 148 =inch; or: the 
range = high level time * velocity (340M/S) / 2,
Attention : 
    - When tested objects, the range of area is not less than 0.5 square meters 
and the plane requests as smooth as possible, otherwise ,it will affect the 
results of measuring.
*/
module UltraSonicSensor#(
    parameter ten_us = 10'd400,  // 10 µs at 40 MHz (400 clock cycles)
    parameter threshold_RAW = 22'd69600  // Threshold for 30 cm at 40 MHz
)(
    input clk, //40 MHz
    input rst,
    input measure,
    output reg [1:0] state,
    output ready,
    //HC-SR04 signals
    input echo,  //ECHO
    output trig, //TRIGGER
    output reg [21:0] distanceRAW,
    output reg exit_car  // indicates a car exit
);

    localparam IDLE = 2'b00,
              TRIGGER = 2'b01,
              WAIT = 2'b11,
              COUNTECHO = 2'b10;
    wire inIDLE, inTRIGGER, inWAIT, inCOUNTECHO;
    reg [9:0] counter;
    wire trigcountDONE;

    //Ready
    assign ready = inIDLE;
    
    //Decode states
    assign inIDLE = (state == IDLE);
    assign inTRIGGER = (state == TRIGGER);
    assign inWAIT = (state == WAIT);
    assign inCOUNTECHO = (state == COUNTECHO);

    //State transactions
    always @(posedge clk or posedge rst)
        begin
            if (rst)
                begin
                    state <= IDLE;
                    exit_car <= 0;  // Initialize exit_car on reset
                end
            else
                begin
                    case (state)
                        IDLE:
                            begin
                                state <= (measure & ready) ? TRIGGER : state;
                            end
                        TRIGGER:
                            begin
                                state <= (trigcountDONE) ? WAIT : state;
                            end
                        WAIT:
                            begin
                                state <= (echo) ? COUNTECHO : state;
                            end
                        COUNTECHO:
                            begin
                                state <= (~echo) ? IDLE : state;
                            end
                    endcase
                    // Object detection logic
                    if (inIDLE && ready)
                        begin
                            if (distanceRAW < threshold_RAW)
                                exit_car <= 1;  // Object detected (distance < 30 cm)
                            else
                                exit_car <= 0;  // No object detected (distance >= 30 cm)
                        end
                end
        end

    //Trigger
    assign trig = (state == TRIGGER);

    //Counter for 10 µs trigger pulse
    always @(posedge clk)
        begin
            if (inIDLE)
                counter <= 10'd0;
            else
                counter <= counter + 1;
        end
    assign trigcountDONE = (counter == ten_us);

    //Get distance
    always @(posedge clk)
        begin
            if (inWAIT)
                distanceRAW <= 22'd0;
            else if (inCOUNTECHO)
                distanceRAW <= distanceRAW + 1;
            else
                distanceRAW <= distanceRAW;
        end
endmodule