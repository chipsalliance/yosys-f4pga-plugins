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

PLUGIN_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

NAME = ql-qlf
SOURCES = synth_quicklogic.cc \
          ql-dsp.cc \
          pp3_braminit.cc \
          quicklogic_eqn.cc \
          ql-edif.cc \
          ql-dsp-simd.cc \
          ql-dsp-macc.cc \
          ql-bram-split.cc \
          ql-dsp-io-regs.cc \
          ql-bram-asymmetric.cc

include ../Makefile_plugin.common

# For pmgen/*.h
CXXFLAGS += -I$(BUILD_DIR)

COMMON          = common
QLF_K4N8_DIR    = qlf_k4n8
QLF_K6N10_DIR   = qlf_k6n10
QLF_K6N10F_DIR  = qlf_k6n10f
PP3_DIR         = pp3
VERILOG_MODULES = $(COMMON)/cells_sim.v         \
                  $(QLF_K4N8_DIR)/arith_map.v   \
                  $(QLF_K4N8_DIR)/cells_sim.v   \
                  $(QLF_K4N8_DIR)/ffs_map.v     \
                  $(QLF_K6N10_DIR)/arith_map.v \
                  $(QLF_K6N10_DIR)/brams_map.v \
                  $(QLF_K6N10_DIR)/brams.txt   \
                  $(QLF_K6N10_DIR)/cells_sim.v \
                  $(QLF_K6N10_DIR)/ffs_map.v   \
                  $(QLF_K6N10_DIR)/dsp_map.v   \
                  $(QLF_K6N10_DIR)/lut_map.v   \
                  $(QLF_K6N10F_DIR)/arith_map.v \
                  $(QLF_K6N10F_DIR)/brams_map.v \
                  $(QLF_K6N10F_DIR)/brams_final_map.v \
                  $(QLF_K6N10F_DIR)/brams.txt   \
                  $(QLF_K6N10F_DIR)/cells_sim.v \
                  $(QLF_K6N10F_DIR)/dsp_sim.v \
                  $(QLF_K6N10F_DIR)/primitives_sim.v \
                  $(QLF_K6N10F_DIR)/brams_sim.v \
                  $(QLF_K6N10F_DIR)/sram1024x18.v \
                  $(QLF_K6N10F_DIR)/TDP18K_FIFO.v \
                  $(QLF_K6N10F_DIR)/ufifo_ctl.v \
                  $(QLF_K6N10F_DIR)/ffs_map.v   \
                  $(QLF_K6N10F_DIR)/dsp_map.v   \
                  $(QLF_K6N10F_DIR)/dsp_final_map.v \
                  $(PP3_DIR)/abc9_map.v    \
                  $(PP3_DIR)/abc9_model.v  \
                  $(PP3_DIR)/abc9_unmap.v  \
                  $(PP3_DIR)/cells_map.v   \
                  $(PP3_DIR)/cells_sim.v   \
                  $(PP3_DIR)/ffs_map.v     \
                  $(PP3_DIR)/latches_map.v \
                  $(PP3_DIR)/lut_map.v     \
                  $(PP3_DIR)/lutdefs.txt   \
                  $(PP3_DIR)/brams_sim.v   \
                  $(PP3_DIR)/brams_map.v   \
                  $(PP3_DIR)/brams.txt     \
                  $(PP3_DIR)/bram_init_8_16.vh \
                  $(PP3_DIR)/bram_init_32.vh   \
                  $(PP3_DIR)/qlal4s3b_sim.v    \
                  $(PP3_DIR)/mult_sim.v        \
                  $(PP3_DIR)/qlal3_sim.v

PMGEN_OUT_DIR := $(BUILD_DIR)/pmgen

$(PMGEN_OUT_DIR):
	mkdir -p $@

DEPS := $(PMGEN_OUT_DIR)/ql-dsp-pm.h \
        $(PMGEN_OUT_DIR)/ql-dsp-macc.h \
        $(PMGEN_OUT_DIR)/ql-bram-asymmetric-wider-write.h \
        $(PMGEN_OUT_DIR)/ql-bram-asymmetric-wider-read.h

$(DEPS): $(PMGEN_PY) | $(PMGEN_OUT_DIR)

$(OBJECTS): $(DEPS)

$(PMGEN_OUT_DIR)/ql-dsp-pm.h: ql_dsp.pmg
	python3 $(PMGEN_PY) -o $@ -p ql_dsp ql_dsp.pmg

$(PMGEN_OUT_DIR)/ql-dsp-macc.h: ql-dsp-macc.pmg
	python3 $(PMGEN_PY) -o $@ -p ql_dsp_macc ql-dsp-macc.pmg

$(PMGEN_OUT_DIR)/ql-bram-asymmetric-wider-write.h: ql-bram-asymmetric-wider-write.pmg
	python3 $(PMGEN_PY) -o $@ -p ql_bram_asymmetric_wider_write ql-bram-asymmetric-wider-write.pmg

$(PMGEN_OUT_DIR)/ql-bram-asymmetric-wider-read.h: ql-bram-asymmetric-wider-read.pmg
	python3 $(PMGEN_PY) -o $@ -p ql_bram_asymmetric_wider_read ql-bram-asymmetric-wider-read.pmg

install_modules: $(VERILOG_MODULES)
	mkdir -p $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(COMMON) $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(QLF_K4N8_DIR) $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(QLF_K6N10_DIR) $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(QLF_K6N10F_DIR) $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(PP3_DIR)
	$(foreach f,$^,install $(f) $(YOSYS_DATA_DIR)/quicklogic_f4pga/$(f);)

install: install_modules
