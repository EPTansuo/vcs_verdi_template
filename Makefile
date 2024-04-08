TOP_NMAE=i2c_tb
WAVE=i2c.fsdb

PLATFORM=LINUX64

BUILD_DIR = ./build
VSRC_DIR = ./vsrc
TB_DIR = ./tb
INC_FLAGS = +incdir+$(VSRC_DIR)

VCS_LOG=$(BUILD_DIR)/vcs.log
SIM_LOG=$(BUILD_DIR)/sim.log
FILE_LIST_F=./build/file.list.f
VERDI_LOG_DIR=$(BUILD_DIR)/verdiLog
VERDI_RUN_LOG=$(BUILD_DIR)/verdi_run.log
CSRC_DIR=$(BUILD_DIR)/csrc
BIN=$(BUILD_DIR)/$(TOP_NMAE)

VCS_FLAGS = -full64 -notice -kdb -lca -debug_acc+all +dmptf +warn=all \
		-R +fsdb+autoflush -l run.log


VSRCS = $(shell find $(abspath $(VSRC_DIR)) -name "*.v")
VSRCS += $(shell find $(abspath $(TB_DIR)) -name "*.v")
$(shell mkdir -p $(BUILD_DIR))


default: $(BIN)

$(BIN): $(VSRCS)
	$(shell echo $(VSRCS) > $(FILE_LIST_F))
	vcs	$(INC_FLAGS) -l $(VCS_LOG) $(VCS_FLAGS)\
		-P $(VERDI_HOME)/share/PLI/VCS/$(PLATFORM)/novas.tab\
		$(VERDI_HOME)/share/PLI/VCS/$(PLATFORM)/pli.a\
		+libext+.v+v2k+acc -f $(FILE_LIST_F)\
		-Mdir=$(CSRC_DIR) -o $(BIN)

run: $(BIN)
	@#$^ -verdi -l $(SIM_LOG)
	verdi \
	-logdir $(abspath $(VERDI_LOG_DIR)) \
	-logfile $(abspath $(VERDI_RUN_LOG))\
	-rcFile $(abspath $(BUILD_DIR)/novas.rc)\
	-guiConf $(abspath $(BUILD_DIR)/novas.conf)\
	-sv -f $(FILE_LIST_F) -ssf *.fsdb -nologo

	@#Log file settings below do not work, so I use mv here.`
	-@mv  ./verdi* ./novas* ucli.key run.log  $(BUILD_DIR) >  /dev/null 2>&1

all: default
	

sim: $(BIN)
	$^ 


clean:
	-rm -rf ./build/* $(WAVE)





