# AXI Protocol Verification - Simulation Makefile
# Supports: Questa/ModelSim (default), Synopsys VCS

PROJ_ROOT  := $(abspath ..)
SIM_DIR    := $(abspath .)
WORK_LIB   := work
TOP        := tb_top

TEST       ?= axi_smoke_test
SEED       ?= 1
VERBOSITY  ?= UVM_MEDIUM

# Tool selection: questa (default) | vcs
SIMULATOR  ?= questa

# UVM home - override if not in default path
UVM_HOME   ?= $(QUESTA_UVM_HOME)

ifeq ($(SIMULATOR),questa)
  ifeq ($(UVM_HOME),)
    # Questa ships UVM; use -uvmswitch or built-in
    UVM_FLAGS := -uvmver 1.2
  else
    UVM_FLAGS := +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv
  endif
  VLOG     = vlog -sv -timescale 1ns/1ps +acc $(UVM_FLAGS)
  VLOG_INC = +incdir+$(PROJ_ROOT)/tb/interfaces
  VOPT     = vopt +acc -debugdb $(TOP) -o $(TOP)_opt
  VSIM     = vsim -c $(TOP)_opt -sv_seed $(SEED) +UVM_TESTNAME=$(TEST) \
             -do "run -all; quit -code [coverage [assertion -summary]]"
  VSIM_GUI = vsim -gui $(TOP)_opt -sv_seed $(SEED) +UVM_TESTNAME=$(TEST)
endif

ifeq ($(SIMULATOR),vcs)
  UVM_HOME ?= $(VCS_HOME)/etc/uvm-1.2
  VCS      = vcs -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 \
             -f compile.f +incdir+$(PROJ_ROOT)/tb/interfaces \
             -top $(TOP) -o simv
  RUN_VCS = ./simv +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED)
endif

.PHONY: all compile run regression wave clean help

all: compile run

help:
	@echo "AXI UVM DV Flow"
	@echo "  make compile              - compile design and testbench"
	@echo "  make run TEST=axi_smoke_test"
	@echo "  make regression           - run all tests"
	@echo "  make wave TEST=axi_smoke_test"
	@echo "  SIMULATOR=questa|vcs      - default: questa"

compile:
ifeq ($(SIMULATOR),questa)
	@if not exist $(WORK_LIB) vlib $(WORK_LIB)
	vlog -work $(WORK_LIB) $(VLOG_INC) $(UVM_FLAGS) -f compile.f
	vopt -work $(WORK_LIB) $(VOPT)
endif
ifeq ($(SIMULATOR),vcs)
	cd $(SIM_DIR) && $(VCS)
endif

run: compile
ifeq ($(SIMULATOR),questa)
	vsim -work $(WORK_LIB) -c $(TOP)_opt -sv_seed $(SEED) \
	  +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERBOSITY) \
	  -l logs/$(TEST)_$(SEED).log \
	  -do "run -all; coverage report -file logs/$(TEST)_cov.txt; quit -f"
endif
ifeq ($(SIMULATOR),vcs)
	mkdir -p logs
	cd $(SIM_DIR) && $(RUN_VCS) -l logs/$(TEST)_$(SEED).log
endif

regression:
	@powershell -ExecutionPolicy Bypass -File $(SIM_DIR)/regression.ps1

wave: compile
ifeq ($(SIMULATOR),questa)
	@if not exist logs mkdir logs
	vsim -work $(WORK_LIB) -gui $(TOP)_opt -sv_seed $(SEED) \
	  +UVM_TESTNAME=$(TEST) -do run.do
endif

clean:
	-rmdir /s /q $(WORK_LIB) 2>nul
	-del /q simv simv.daidir *.log transcript 2>nul
	-rmdir /s /q logs 2>nul
