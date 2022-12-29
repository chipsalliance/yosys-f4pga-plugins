# Copyright 2020-2022 F4PGA Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

TESTBENCH = bram18k_tdp_tb.v
POST_SYNTH = dpram_18x1024_9x2048_post_synth dpram_9x2048_x2_post_synth dpram_18x1024_x2_post_synth   
ADDR_WIDTH0 = 10 11 10
DATA_WIDTH0 = 18 9 18
ADDR_WIDTH1 = 11 11 10
DATA_WIDTH1 = 9 9 18
TOP = dpram_18x1024_9x2048 dpram_9x2048_x2 dpram_18x1024_x2
ADDR_DEFINES0 = $(foreach awidth0, $(ADDR_WIDTH0),-DADDR_WIDTH0="$(awidth0)")
ADDR_DEFINES1 = $(foreach awidth1, $(ADDR_WIDTH1),-DADDR_WIDTH1="$(awidth1)")
DATA_DEFINES0 = $(foreach dwidth0, $(DATA_WIDTH0),-DDATA_WIDTH0="$(dwidth0)")
DATA_DEFINES1 = $(foreach dwidth1, $(DATA_WIDTH1),-DDATA_WIDTH1="$(dwidth1)")
TOP_DEFINES = $(foreach top, $(TOP),-DTOP="$(top)")
VCD_DEFINES = $(foreach vcd, $(POST_SYNTH),-DVCD="$(vcd).vcd")

SIM_LIBS = $(shell find ../../../../qlf_k6n10f -name "*.v" -not -name "*_map.v")

define simulate_post_synth
	@iverilog  -vvvv -g2005 $(word $(1),$(ADDR_DEFINES0)) $(word $(1),$(ADDR_DEFINES1)) $(word $(1),$(DATA_DEFINES0)) $(word $(1),$(DATA_DEFINES1)) $(word $(1),$(TOP_DEFINES)) $(word $(1),$(VCD_DEFINES)) -o $(word $(1),$(POST_SYNTH)).vvp $(word $(1),$(POST_SYNTH)).v $(SIM_LIBS) $(TESTBENCH) > $(word $(1),$(POST_SYNTH)).vvp.log 2>&1
	@vvp -vvvv $(word $(1),$(POST_SYNTH)).vvp > $(word $(1),$(POST_SYNTH)).vcd.log 2>&1
endef

define clean_post_synth_sim
	@rm -rf  $(word $(1),$(POST_SYNTH)).vcd $(word $(1),$(POST_SYNTH)).vvp $(word $(1),$(POST_SYNTH)).vvp.log $(word $(1),$(POST_SYNTH)).vcd.log
endef

sim:
	$(call simulate_post_synth,1)
	$(call clean_post_synth_sim,1)
	$(call simulate_post_synth,2)
	$(call clean_post_synth_sim,2)
	$(call simulate_post_synth,3)
	$(call clean_post_synth_sim,3)