
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
`timescale 1ns / 1ps

module UltrasonicSensor#(parameter ten_us = 10'd400) // 10 µs at 40 MHz
( 
  input clk, //40 MHz
  input rst,
  input measure,
  output reg [1:0] state,
  output ready,
  //HC-SR04 signals
  input echo,  //JA1(Pins)
  output trig, //JA2(Pins)
  output reg [21:0] distanceRAW,
  // Outputs for ParkingFSM
  output reg car_entry, // Signal to indicate a car is entering
  output reg car_exit   // Signal to indicate a car is exiting
);
  localparam IDLE = 2'b00,
          TRIGGER = 2'b01,
             WAIT = 2'b11,
        COUNTECHO = 2'b10;
  wire inIDLE, inTRIGGER, inWAIT, inCOUNTECHO;
  reg [9:0] counter;
  wire trigcountDONE, counterDONE;

  // Thresholds for car entry/exit detection (in distanceRAW units)
  localparam ENTRY_THRESHOLD = 22'd11664; // 50 cm
  localparam EXIT_THRESHOLD = 22'd23328;  // 100 cm

  //Ready
  assign ready = inIDLE;
  
  //Decode states
  assign inIDLE = (state == IDLE);
  assign inTRIGGER = (state == TRIGGER);
  assign inWAIT = (state == WAIT);
  assign inCOUNTECHO = (state == COUNTECHO);

  //State transactions
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          state <= IDLE;
          car_entry <= 1'b0;
          car_exit <= 1'b0;
        end
      else
        begin
          case(state)
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
                state <= (echo) ? state : IDLE;
              end
          endcase
          
        end
    end
  
  //Trigger
  assign trig = inTRIGGER;
  
  //Counter
  always@(posedge clk)
    begin
      if(inIDLE)
        begin
          counter <= 10'd0;
        end
      else
        begin
          counter <= counter + {9'd0, (|counter | inTRIGGER)};
        end
    end
  assign trigcountDONE = (counter == ten_us);

  //Get distance
  always@(posedge clk)
    begin
      if(inWAIT)
        distanceRAW <= 22'd0;
      else
        distanceRAW <= distanceRAW + {21'd0, inCOUNTECHO};
    end

  // Detect car entry/exit based on distance
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          car_entry <= 1'b0;
          car_exit <= 1'b0;
        end
      else
        begin
          if (inIDLE && distanceRAW > 0)
            begin
              if (distanceRAW < ENTRY_THRESHOLD)
                begin
                  car_entry <= 1'b1; // Car is entering
                  car_exit <= 1'b0;
                end
              else if (distanceRAW > EXIT_THRESHOLD)
                begin
                  car_exit <= 1'b1; // Car is exiting
                  car_entry <= 1'b0;
                end
              else
                begin
                  car_entry <= 1'b0;
                  car_exit <= 1'b0;
                end
            end
          else
            begin
              car_entry <= 1'b0;
              car_exit <= 1'b0;
            end
        end
    end
endmodule