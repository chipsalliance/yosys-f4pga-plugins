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

NAME = systemverilog
SOURCES = UhdmAst.cc \
          uhdmastfrontend.cc \
          uhdmcommonfrontend.cc \
          uhdmsurelogastfrontend.cc \
          uhdmastreport.cc \
          third_party/yosys/const2ast.cc \
          third_party/yosys/simplify.cc

# Directory to search for Surelog and UHDM libraries
UHDM_INSTALL_DIR ?= /usr/local

# Tell pkg-config to look in the provided install path first.
# PKG_CONFIG_PATH and PKG_CONFIG_PATH_FOR_TARGET are search paths it looks in
# so set the environment variables and prefix with our local install first
PKG_CONFIG_INVOKE = \
   PKG_CONFIG_PATH=$(UHDM_INSTALL_DIR)/lib/pkgconfig:${PKG_CONFIG_PATH} \
   PKG_CONFIG_PATH_FOR_TARGET=$(UHDM_INSTALL_DIR)/lib/pkgconfig:${PKG_CONFIG_PATH_FOR_TARGET} \
   pkg-config

include ../Makefile_plugin.common

# A litmus-test: make compilation fail if pkg-config fails
.SECONDARY: $(BUILD_DIR)/.$(NAME)-deps-test
$(BUILD_DIR)/.$(NAME)-deps-test:
	$(PKG_CONFIG_INVOKE) --cflags Surelog

${SO_LIB}: | $(BUILD_DIR)/.$(NAME)-deps-test

CXXFLAGS += -std=c++17 -Wall -W -Wextra \
            -Wno-deprecated-declarations \
            -Wno-unused-parameter \
            $(shell $(PKG_CONFIG_INVOKE) --cflags Surelog)

LDFLAGS += $(shell $(PKG_CONFIG_INVOKE) --libs-only-L Surelog)

LDLIBS += $(shell $(PKG_CONFIG_INVOKE) --libs-only-l --libs-only-other Surelog)
