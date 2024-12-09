# Project directories
RTL_DIR       := rtl
MODULES_DIR   := $(RTL_DIR)/modules
TOP_DIR       := $(RTL_DIR)/top
TESTBENCH_DIR := testbench
BUILD_DIR     := build

# Simulator (iverilog, VCS, ModelSim)
SIMULATOR     := iverilog
VVP           := vvp
WAVE_VIEWER   := gtkwave

# Default target
default: simulate

# Compilation step
$(BUILD_DIR)/design.out: $(MODULES_DIR)/*.v $(TOP_DIR)/*.v $(TESTBENCH_DIR)/main_tb.v
	@mkdir -p $(BUILD_DIR)
	$(SIMULATOR) -o $@ $^

# Simulation step
simulate: $(BUILD_DIR)/design.out
	$(VVP) $<

# View waveforms
wave: $(BUILD_DIR)/design.out
	$(VVP) $< +dumpfile=$(BUILD_DIR)/main.vcd +dumpvars
	$(WAVE_VIEWER) $(BUILD_DIR)/main.vcd

# Clean up build directory
clean:
	@rm -rf $(BUILD_DIR)

.PHONY: default simulate wave clean
