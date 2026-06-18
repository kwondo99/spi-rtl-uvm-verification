.PHONY: compile sim clean

UVM_VERBOSITY = UVM_MEDIUM
UVM_TESTNAME	=	spi_master_test 

RUN_OPT = +UVM_TESTNAME=$(UVM_TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY)

VCS_SRC_FILES = ./rtl/spi_master.sv ./tb/spi_master_interface.sv ./tb/spi_master_pkg.sv ./tb/tb_spi_master.sv
VCS_INCDIR = +incdir+tb +incdir+rtl

VCS_OPTS = -full64 -sverilog 
VCS_OPTS += -debug_access+all -kdb -lca 
VCS_OPTS += -ntb_opts uvm-1.2 -timescale=1ns/1ps 
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert
VCS_OUTPUT = -o simv

SIMV_OPTS = -l simv.log $(RUN_OPT)
SIMV_OPTS += +ntb_random_seed=1234
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name sim1

all : clean compile sim

compile:
	vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_SRC_FILES) $(VCS_OUTPUT)
	@echo "target [$@]"

sim: compile 
		./simv $(SIMV_OPTS) 
	@echo "dependent target [$<]"
	@echo "target [$@]"

clean :
	rm -rf simv* csrc *.log *.key *.h *.vdb *.conf *.rc *.fsdb vdCovLog verdiLog
	@echo "clear run...."

coverage : 
	verdi -dbdir simv.daidir/ -ssf spi_master_tb.fsdb -cov -covdir coverage.vdb/
	@echo "report coverage"
