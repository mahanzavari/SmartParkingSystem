## TODO
## Note that this is simply a test

# Variables
TOP_MODULE = parking_system
TESTBENCH = parking_system_tb
SRC_FILES = $(TOP_MODULE).v
TB_FILES = $(TESTBENCH).v
WAVE_FILE = waveform.vcd
COMPILER = iverilog
SIMULATOR = vvp

# Targets
all: simulate

# Compile the source and testbench
compile:
	$(COMPILER) -o simulation $(SRC_FILES) $(TB_FILES)

# Run the simulation and generate waveforms
simulate: compile
	$(SIMULATOR) simulation

# View waveforms in GTKWave
view: $(WAVE_FILE)
	gtkwave $(WAVE_FILE)

# Clean up generated files
clean:
	rm -f simulation $(WAVE_FILE)
