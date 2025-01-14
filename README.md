# Parking Management System - FPGA-Based Smart Parking Solution

## Project Overview

This project is an FPGA-based smart parking management system designed to optimize the process of parking vehicles in a small parking lot. The system uses digital logic and state machines to manage the entry and exit of vehicles, display available parking slots, and control the parking lot's door and full indicators. The project is implemented using Verilog and is designed to run on an FPGA board.

### Key Features:
- **Entry and Exit Management**: The system detects vehicle entry and exit using ultrasonic sensors and updates the parking status accordingly.
- **Slot Allocation**: The system automatically allocates the nearest available parking slot to incoming vehicles.
- **Display System**: A 4-digit 7-segment display shows the number of available slots and the best slot for parking.
- **Door Control**: The system controls the parking lot door, opening it for entry or exit and indicating the door status with a blinking light.
- **Full Indicator**: When the parking lot is full, a light blinks to indicate no available slots.

### Modules:
1. **ClockDivider**: Generates multiple clock signals from the main clock for different system components.
2. **Debouncer**: Debounces input signals from buttons or sensors to avoid false triggers.
3. **ParkingFSM**: Finite State Machine (FSM) that manages the parking system's states, including entry, exit, and slot allocation.
4. **ParkingTimer**: Tracks the parking duration for each slot and displays the time when a vehicle exits.
5. **SlotManager**: Manages the status of parking slots and updates the number of available slots.
6. **UltraSonicSensor**: Detects vehicles using an ultrasonic sensor (HC-SR04) for entry and exit.
7. **SevenSegmentDisplay**: Controls the 4-digit 7-segment display to show parking information.
8. **TopModule**: Integrates all the modules and manages the overall system functionality.

## Contributors:
- **Mahan Zavari**
- **Amin Rezaeeyan**

## Project Structure:
- **ClockDivider.v**: Clock divider module to generate different clock frequencies.
- **Debouncer.v**: Debouncer module to stabilize input signals.
- **ParkingFSM.v**: Finite State Machine for parking management.
- **ParkingTimer.v**: Timer module to track parking duration.
- **SlotManager.v**: Manages parking slot status and availability.
- **UltraSonicSensor.v**: Ultrasonic sensor module for vehicle detection.
- **SevenSegmentDisplay.v**: Controls the 7-segment display.
- **TopModule.v**: Top-level module integrating all components.

## Requirements:
- **FPGA Board**: The project is designed to run on an FPGA board with a 40 MHz clock.
- **Ultrasonic Sensor (HC-SR04)**: Used for vehicle detection.
- **7-Segment Display**: A 4-digit 7-segment display to show parking information.
- **Buttons/Switches**: For simulating entry and exit signals during testing.

## How to Run:
1. **Synthesize the Design**: Use an FPGA synthesis tool (e.g., Xilinx Vivado) to synthesize the Verilog code.
2. **Upload to FPGA**: Load the synthesized design onto the FPGA board.
3. **Connect Sensors and Display**: Connect the ultrasonic sensor and 7-segment display to the FPGA board as per the pin configuration.
4. **Test the System**: Use buttons or switches to simulate vehicle entry and exit. Observe the display and door control behavior.

## Additional Features (Optional):
- **Ultrasonic Sensor Integration**: The system can be enhanced to use an ultrasonic sensor for automatic vehicle detection.
- **Parking Duration Display**: When a vehicle exits, the system can display the parking duration on the 7-segment display.

## Notes:
- **Debouncing**: The system includes debouncing logic to ensure stable input signals from buttons or sensors.
- **Clock Management**: The system uses a clock divider to generate different clock frequencies for various components, such as the display and door control.

## Future Improvements:
- **Advanced Slot Allocation**: Implement a more sophisticated algorithm for slot allocation based on vehicle size or priority.
- **Real-Time Monitoring**: Add a real-time monitoring system to track parking lot status remotely.

## License:
This project is open-source and available under the MIT License. Feel free to modify and distribute it as per the license terms.

---

For any questions or issues, please contact the contributors:
- **Mahan Zavari**: [mahanzavari@gmail.com]
- **Amin Rezaeeyan**: [aminrezaeeyan@gmail.com]

---

**Happy Parking!** 🚗