# SymbiYosys formal verification
# Requires: sby, yosys (OSS CAD Suite or equivalent)

SBY     ?= sby
JOBS    ?= 4
TASKS   ?= axi_handshake axi_slave

.PHONY: all handshake slave clean

all: handshake slave
	@echo "========== Formal: all tasks finished =========="

handshake:
	$(SBY) -f axi_handshake.sby -j $(JOBS)

slave:
	$(SBY) -f axi_slave.sby -j $(JOBS)

clean:
	rm -rf axi_handshake axi_slave
