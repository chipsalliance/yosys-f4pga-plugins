# Copyright (C) 2019-2022 The SymbiFlow Authors
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC

TESTBENCH = asymmetric_bram36k_sdp_tb.v
POST_SYNTH = spram_9x4096_36x1024_post_synth spram_18x2048_36x1024_post_synth spram_18x2048_9x4096_post_synth spram_36x1024_18x2048_post_synth
ADDR_WIDTH0 = 12 11 11 10
DATA_WIDTH0 = 9 18 18 36
ADDR_WIDTH1 = 10 10 12 11
DATA_WIDTH1 = 36 36 9 18
TOP = spram_9x4096_36x1024 spram_18x2048_36x1024 spram_18x2048_9x4096 spram_36x1024_18x2048
ADDR0_DEFINES = $(foreach awidth0, $(ADDR_WIDTH0),-DADDR_WIDTH0="$(awidth0)")
ADDR1_DEFINES = $(foreach awidth1, $(ADDR_WIDTH1),-DADDR_WIDTH1="$(awidth1)")
DATA0_DEFINES = $(foreach dwidth0, $(DATA_WIDTH0),-DDATA_WIDTH0="$(dwidth0)")
DATA1_DEFINES = $(foreach dwidth1, $(DATA_WIDTH1),-DDATA_WIDTH1="$(dwidth1)")
TOP_DEFINES = $(foreach top, $(TOP),-DTOP="$(top)")
VCD_DEFINES = $(foreach vcd, $(POST_SYNTH),-DVCD="$(vcd).vcd")

SIM_LIBS = $(shell find ../../../../qlf_k6n10f -name "*.v" -not -name "*_map.v")

define simulate_post_synth
	@iverilog  -vvvv -g2005 $(word $(1),$(ADDR0_DEFINES)) $(word $(1),$(ADDR1_DEFINES)) $(word $(1),$(DATA0_DEFINES)) $(word $(1),$(DATA1_DEFINES)) $(word $(1),$(TOP_DEFINES)) $(word $(1),$(VCD_DEFINES)) -o $(word $(1),$(POST_SYNTH)).vvp $(word $(1),$(POST_SYNTH)).v $(SIM_LIBS) $(TESTBENCH) > $(word $(1),$(POST_SYNTH)).vvp.log 2>&1
	@vvp -vvvv $(word $(1),$(POST_SYNTH)).vvp > $(word $(1),$(POST_SYNTH)).vcd.log 2>&1
endef

define clean_post_synth_sim
	@rm -rf  $(word $(1),$(POST_SYNTH)).vcd $(word $(1),$(POST_SYNTH)).vvp $(word $(1),$(POST_SYNTH)).vvp.log $(word $(1),$(POST_SYNTH)).vcd.log
endef

#FIXME: $(call simulate_post_synth,3)
sim:
	$(call simulate_post_synth,1)
	$(call clean_post_synth_sim,1)
	$(call simulate_post_synth,2)
	$(call clean_post_synth_sim,2)
	$(call simulate_post_synth,3)
	$(call clean_post_synth_sim,3)
	$(call simulate_post_synth,4)
	$(call clean_post_synth_sim,4)