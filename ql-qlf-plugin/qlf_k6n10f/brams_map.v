// Copyright 2020-2022 F4PGA Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

`define MODE_36 3'b011	// 36 or 32-bit
`define MODE_18 3'b010	// 18 or 16-bit
`define MODE_9  3'b001	// 9 or 8-bit
`define MODE_4  3'b100	// 4-bit
`define MODE_2  3'b110	// 32-bit
`define MODE_1  3'b101	// 32-bit

module \$__QLF_FACTOR_BRAM36_TDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, C1ADDR, C1DATA, C1EN, CLK1, CLK2, D1ADDR, D1DATA, D1EN);
	parameter CFG_ABITS = 10;
	parameter CFG_DBITS = 36;
	parameter CFG_ENABLE_B = 4;
	parameter CFG_ENABLE_D = 4;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [36863:0] INIT = 36864'bx;

	input CLK1;
	input CLK2;

	input [CFG_ABITS-1:0] A1ADDR;
	output [CFG_DBITS-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [CFG_DBITS-1:0] B1DATA;
	input [CFG_ENABLE_B-1:0] B1EN;

	input [CFG_ABITS-1:0] C1ADDR;
	output [CFG_DBITS-1:0] C1DATA;
	input C1EN;

	input [CFG_ABITS-1:0] D1ADDR;
	input [CFG_DBITS-1:0] D1DATA;
	input [CFG_ENABLE_B-1:0] D1EN;

	wire FLUSH1;
	wire FLUSH2;
	wire SPLIT;

	wire [14:CFG_ABITS] A1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] B1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] C1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] D1ADDR_CMPL = {15-CFG_ABITS{1'b0}};

	wire [14:0] A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
	wire [14:0] B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};
	wire [14:0] C1ADDR_TOTAL = {C1ADDR_CMPL, C1ADDR};
	wire [14:0] D1ADDR_TOTAL = {D1ADDR_CMPL, D1ADDR};

	wire [35:CFG_DBITS] A1DATA_CMPL;
	wire [35:CFG_DBITS] B1DATA_CMPL;
	wire [35:CFG_DBITS] C1DATA_CMPL;
	wire [35:CFG_DBITS] D1DATA_CMPL;

	wire [35:0] A1DATA_TOTAL;
	wire [35:0] B1DATA_TOTAL;
	wire [35:0] C1DATA_TOTAL;
	wire [35:0] D1DATA_TOTAL;

	wire [14:0] PORT_A_ADDR;
	wire [14:0] PORT_B_ADDR;

	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16
	case (CFG_DBITS)
		9: begin
			assign A1DATA = {A1DATA_TOTAL[16], A1DATA_TOTAL[7:0]};
			assign C1DATA = {C1DATA_TOTAL[16], C1DATA_TOTAL[7:0]};
			assign B1DATA_TOTAL = {B1DATA_CMPL[35:17], B1DATA[8], B1DATA_CMPL[16:9], B1DATA[7:0]};
			assign D1DATA_TOTAL = {D1DATA_CMPL[35:17], D1DATA[8], D1DATA_CMPL[16:9], D1DATA[7:0]};
		end
		default: begin
			assign A1DATA = A1DATA_TOTAL[CFG_DBITS-1:0];
			assign C1DATA = C1DATA_TOTAL[CFG_DBITS-1:0];
			assign B1DATA_TOTAL = {B1DATA_CMPL, B1DATA};
			assign D1DATA_TOTAL = {D1DATA_CMPL, D1DATA};
		end
	endcase

	case (CFG_DBITS)
		1: begin
			assign PORT_A_ADDR = A1EN ? A1ADDR_TOTAL : (B1EN ? B1ADDR_TOTAL : 15'd0);
			assign PORT_B_ADDR = C1EN ? C1ADDR_TOTAL : (D1EN ? D1ADDR_TOTAL : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, 1'd0
            };
		end

		2: begin
			assign PORT_A_ADDR = A1EN ? (A1ADDR_TOTAL << 1) : (B1EN ? (B1ADDR_TOTAL << 1) : 15'd0);
			assign PORT_B_ADDR = C1EN ? (C1ADDR_TOTAL << 1) : (D1EN ? (D1ADDR_TOTAL << 1) : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, 1'd0
            };
		end

		4: begin
			assign PORT_A_ADDR = A1EN ? (A1ADDR_TOTAL << 2) : (B1EN ? (B1ADDR_TOTAL << 2) : 15'd0);
			assign PORT_B_ADDR = C1EN ? (C1ADDR_TOTAL << 2) : (D1EN ? (D1ADDR_TOTAL << 2) : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, 1'd0
            };
		end

		8, 9: begin
			assign PORT_A_ADDR = A1EN ? (A1ADDR_TOTAL << 3) : (B1EN ? (B1ADDR_TOTAL << 3) : 15'd0);
			assign PORT_B_ADDR = C1EN ? (C1ADDR_TOTAL << 3) : (D1EN ? (D1ADDR_TOTAL << 3) : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, 1'd0
            };
		end

		16, 18: begin
			assign PORT_A_ADDR = A1EN ? (A1ADDR_TOTAL << 4) : (B1EN ? (B1ADDR_TOTAL << 4) : 15'd0);
			assign PORT_B_ADDR = C1EN ? (C1ADDR_TOTAL << 4) : (D1EN ? (D1ADDR_TOTAL << 4) : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, 1'd0
            };
		end

		32, 36: begin
			assign PORT_A_ADDR = A1EN ? (A1ADDR_TOTAL << 5) : (B1EN ? (B1ADDR_TOTAL << 5) : 15'd0);
			assign PORT_B_ADDR = C1EN ? (C1ADDR_TOTAL << 5) : (D1EN ? (D1ADDR_TOTAL << 5) : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0
            };
		end
		default: begin
			assign PORT_A_ADDR = A1EN ? A1ADDR_TOTAL : (B1EN ? B1ADDR_TOTAL : 15'd0);
			assign PORT_B_ADDR = C1EN ? C1ADDR_TOTAL : (D1EN ? D1ADDR_TOTAL : 15'd0);
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0
            };
		end
	endcase


	assign SPLIT = 1'b0;
	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;

	TDP36K _TECHMAP_REPLACE_ (
		.RESET_ni(1'b1),
		.WDATA_A1_i(B1DATA_TOTAL[17:0]),
		.WDATA_A2_i(B1DATA_TOTAL[35:18]),
		.RDATA_A1_o(A1DATA_TOTAL[17:0]),
		.RDATA_A2_o(A1DATA_TOTAL[35:18]),
		.ADDR_A1_i(PORT_A_ADDR),
		.ADDR_A2_i(PORT_A_ADDR),
		.CLK_A1_i(CLK1),
		.CLK_A2_i(CLK1),
		.REN_A1_i(A1EN),
		.REN_A2_i(A1EN),
		.WEN_A1_i(B1EN[0]),
		.WEN_A2_i(B1EN[0]),
		.BE_A1_i({B1EN[1],B1EN[0]}),
		.BE_A2_i({B1EN[3],B1EN[2]}),

		.WDATA_B1_i(D1DATA_TOTAL[17:0]),
		.WDATA_B2_i(D1DATA_TOTAL[35:18]),
		.RDATA_B1_o(C1DATA_TOTAL[17:0]),
		.RDATA_B2_o(C1DATA_TOTAL[35:18]),
		.ADDR_B1_i(PORT_B_ADDR),
		.ADDR_B2_i(PORT_B_ADDR),
		.CLK_B1_i(CLK2),
		.CLK_B2_i(CLK2),
		.REN_B1_i(C1EN),
		.REN_B2_i(C1EN),
		.WEN_B1_i(D1EN[0]),
		.WEN_B2_i(D1EN[0]),
		.BE_B1_i({D1EN[1],D1EN[0]}),
		.BE_B2_i({D1EN[3],D1EN[2]}),

		.FLUSH1_i(FLUSH1),
		.FLUSH2_i(FLUSH2)
	);
endmodule

// ------------------------------------------------------------------------

module \$__QLF_FACTOR_BRAM18_TDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, C1ADDR, C1DATA, C1EN, CLK1, CLK2, CLK3, CLK4, D1ADDR, D1DATA, D1EN);
	parameter CFG_ABITS = 11;
	parameter CFG_DBITS = 18;
	parameter CFG_ENABLE_B = 4;
	parameter CFG_ENABLE_D = 4;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [18431:0] INIT = 18432'bx;

	input CLK1;
	input CLK2;
	input CLK3;
	input CLK4;

	input [CFG_ABITS-1:0] A1ADDR;
	output [CFG_DBITS-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [CFG_DBITS-1:0] B1DATA;
	input [CFG_ENABLE_B-1:0] B1EN;

	input [CFG_ABITS-1:0] C1ADDR;
	output [CFG_DBITS-1:0] C1DATA;
	input C1EN;

	input [CFG_ABITS-1:0] D1ADDR;
	input [CFG_DBITS-1:0] D1DATA;
	input [CFG_ENABLE_D-1:0] D1EN;

	BRAM2x18_TDP #(
		.CFG_ABITS(CFG_ABITS),
		.CFG_DBITS(CFG_DBITS),
		.CFG_ENABLE_B(CFG_ENABLE_B),
		.CFG_ENABLE_D(CFG_ENABLE_D),
		.CLKPOL2(CLKPOL2),
		.CLKPOL3(CLKPOL3),
		.INIT0(INIT),
	) _TECHMAP_REPLACE_ (
		.A1ADDR(A1ADDR),
		.A1DATA(A1DATA),
		.A1EN(A1EN),
		.B1ADDR(B1ADDR),
		.B1DATA(B1DATA),
		.B1EN(B1EN),
		.CLK1(CLK1),

		.C1ADDR(C1ADDR),
		.C1DATA(C1DATA),
		.C1EN(C1EN),
		.D1ADDR(D1ADDR),
		.D1DATA(D1DATA),
		.D1EN(D1EN),
		.CLK2(CLK2),

		.E1ADDR(),
		.E1DATA(),
		.E1EN(),
		.F1ADDR(),
		.F1DATA(),
		.F1EN(),
		.CLK3(),

		.G1ADDR(),
		.G1DATA(),
		.G1EN(),
		.H1ADDR(),
		.H1DATA(),
		.H1EN(),
		.CLK4()
	);
endmodule

module \$__QLF_FACTOR_BRAM18_SDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, CLK1, CLK2);
	parameter CFG_ABITS = 11;
	parameter CFG_DBITS = 18;
	parameter CFG_ENABLE_B = 4;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [18431:0] INIT = 18432'bx;

	input CLK1;
	input CLK2;

	input [CFG_ABITS-1:0] A1ADDR;
	output [CFG_DBITS-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [CFG_DBITS-1:0] B1DATA;
	input [CFG_ENABLE_B-1:0] B1EN;

	BRAM2x18_SDP #(
		.CFG_ABITS(CFG_ABITS),
		.CFG_DBITS(CFG_DBITS),
		.CFG_ENABLE_B(CFG_ENABLE_B),
		.CLKPOL2(CLKPOL2),
		.CLKPOL3(CLKPOL3),
		.INIT0(INIT),
	) _TECHMAP_REPLACE_ (
		.A1ADDR(A1ADDR),
		.A1DATA(A1DATA),
		.A1EN(A1EN),
		.CLK1(CLK1),

		.B1ADDR(B1ADDR),
		.B1DATA(B1DATA),
		.B1EN(B1EN),
		.CLK2(CLK2)
	);
endmodule

module \$__QLF_FACTOR_BRAM36_SDP (CLK2, CLK3, A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN);
	parameter CFG_ABITS = 10;
	parameter CFG_DBITS = 36;
	parameter CFG_ENABLE_B = 4;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [36863:0] INIT = 36864'bx;

	localparam MODE_36  = 3'b111;	// 36 or 32-bit
	localparam MODE_18  = 3'b110;	// 18 or 16-bit
	localparam MODE_9   = 3'b101;	// 9 or 8-bit
	localparam MODE_4   = 3'b100;	// 4-bit
	localparam MODE_2   = 3'b010;	// 32-bit
	localparam MODE_1   = 3'b001;	// 32-bit

	input CLK2;
	input CLK3;

	input [CFG_ABITS-1:0] A1ADDR;
	output [CFG_DBITS-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [CFG_DBITS-1:0] B1DATA;
	input [CFG_ENABLE_B-1:0] B1EN;

	wire [14:0] A1ADDR_15;
	wire [14:0] B1ADDR_15;

	wire [35:0] DOBDO;

	wire [14:CFG_ABITS] A1ADDR_CMPL;
	wire [14:CFG_ABITS] B1ADDR_CMPL;
	wire [35:CFG_DBITS] A1DATA_CMPL;
	wire [35:CFG_DBITS] B1DATA_CMPL;

	wire [14:0] A1ADDR_TOTAL;
	wire [14:0] B1ADDR_TOTAL;
	wire [35:0] A1DATA_TOTAL;
	wire [35:0] B1DATA_TOTAL;

	wire FLUSH1;
	wire FLUSH2;

	assign A1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	assign B1ADDR_CMPL = {15-CFG_ABITS{1'b0}};

	assign A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
	assign B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};

	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16
	case (CFG_DBITS)
		9: begin
			assign A1DATA = {A1DATA_TOTAL[16], A1DATA_TOTAL[7:0]};
			assign B1DATA_TOTAL = {B1DATA_CMPL[35:17], B1DATA[8], B1DATA_CMPL[16:9], B1DATA[7:0]};
		end
		default: begin
			assign A1DATA = A1DATA_TOTAL[CFG_DBITS-1:0];
			assign B1DATA_TOTAL = {B1DATA_CMPL, B1DATA};
		end
	endcase

	case (CFG_DBITS)
		1: begin
			assign A1ADDR_15 = A1ADDR_TOTAL;
			assign B1ADDR_15 = B1ADDR_TOTAL;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, 1'd0
            };
		end

		2: begin
			assign A1ADDR_15 = A1ADDR_TOTAL << 1;
			assign B1ADDR_15 = B1ADDR_TOTAL << 1;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, 1'd0
            };
		end

		4: begin
			assign A1ADDR_15 = A1ADDR_TOTAL << 2;
			assign B1ADDR_15 = B1ADDR_TOTAL << 2;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, 1'd0
            };
		end
		8, 9: begin
			assign A1ADDR_15 = A1ADDR_TOTAL << 3;
			assign B1ADDR_15 = B1ADDR_TOTAL << 3;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, 1'd0
            };
		end

		16, 18: begin
			assign A1ADDR_15 = A1ADDR_TOTAL << 4;
			assign B1ADDR_15 = B1ADDR_TOTAL << 4;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, 1'd0
            };
		end
		32, 36: begin
			assign A1ADDR_15 = A1ADDR_TOTAL << 5;
			assign B1ADDR_15 = B1ADDR_TOTAL << 5;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0
            };
		end
		default: begin
			assign A1ADDR_15 = A1ADDR_TOTAL;
			assign B1ADDR_15 = B1ADDR_TOTAL;
            defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0
            };
		end
	endcase


	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;

	TDP36K _TECHMAP_REPLACE_ (
		.RESET_ni(1'b1),
		.WDATA_A1_i(18'h3FFFF),
		.WDATA_A2_i(18'h3FFFF),
		.RDATA_A1_o(A1DATA_TOTAL[17:0]),
		.RDATA_A2_o(A1DATA_TOTAL[35:18]),
		.ADDR_A1_i(A1ADDR_15),
		.ADDR_A2_i(A1ADDR_15),
		.CLK_A1_i(CLK2),
		.CLK_A2_i(CLK2),
		.REN_A1_i(A1EN),
		.REN_A2_i(A1EN),
		.WEN_A1_i(1'b0),
		.WEN_A2_i(1'b0),
		.BE_A1_i({A1EN, A1EN}),
		.BE_A2_i({A1EN, A1EN}),

		.WDATA_B1_i(B1DATA_TOTAL[17:0]),
		.WDATA_B2_i(B1DATA_TOTAL[35:18]),
		.RDATA_B1_o(DOBDO[17:0]),
		.RDATA_B2_o(DOBDO[35:18]),
		.ADDR_B1_i(B1ADDR_15),
		.ADDR_B2_i(B1ADDR_15),
		.CLK_B1_i(CLK3),
		.CLK_B2_i(CLK3),
		.REN_B1_i(1'b0),
		.REN_B2_i(1'b0),
		.WEN_B1_i(B1EN[0]),
		.WEN_B2_i(B1EN[0]),
		.BE_B1_i(B1EN[1:0]),
		.BE_B2_i(B1EN[3:2]),

		.FLUSH1_i(FLUSH1),
		.FLUSH2_i(FLUSH2)
	);
endmodule


module FIFO_36K_BLK (
    DIN,
    PUSH,
    POP,
    Push_Clk,
    Pop_Clk,
    Async_Flush,
    Overrun_Error,
    Full_Watermark,
    Almost_Full,
    Full,
    Underrun_Error,
    Empty_Watermark,
    Almost_Empty,
    Empty,
    DOUT
);

  parameter CFG_DBITS = 36;
  parameter UPAE_DBITS = 12'd10;
  parameter UPAF_DBITS = 12'd10;
  parameter SYNC_FIFO = 1'b0;
    
  localparam MODE_36  = 3'b111;	// 36 or 32-bit
	localparam MODE_18  = 3'b110;	// 18 or 16-bit
	localparam MODE_9   = 3'b101;	// 9 or 8-bit
	localparam MODE_4   = 3'b100;	// 4-bit
	localparam MODE_2   = 3'b010;	// 32-bit
	localparam MODE_1   = 3'b001;	// 32-bit

  input Push_Clk, Pop_Clk;
  input PUSH, POP;
  input [CFG_DBITS-1:0] DIN;
  input Async_Flush;
  output [CFG_DBITS-1:0] DOUT;
  output Almost_Full, Almost_Empty;
  output Full, Empty;
  output Full_Watermark, Empty_Watermark;
  output Overrun_Error, Underrun_Error;
  
  wire [35:0] in_reg;
  wire [35:0] out_reg;
  wire [17:0] fifo_flags;
  
  assign Overrun_Error = fifo_flags[0];
  assign Full_Watermark = fifo_flags[1];
  assign Almost_Full = fifo_flags[2];
  assign Full = fifo_flags[3];
  assign Underrun_Error = fifo_flags[4];
  assign Empty_Watermark = fifo_flags[5];
  assign Almost_Empty = fifo_flags[6];
  assign Empty = fifo_flags[7];
   
  generate
    if (CFG_DBITS == 36) begin
      assign in_reg[CFG_DBITS-1:0] = DIN[CFG_DBITS-1:0];
    end else if (CFG_DBITS > 9 && CFG_DBITS < 36) begin
      assign in_reg[35:CFG_DBITS]  = 0;
      assign in_reg[CFG_DBITS-1:0] = DIN[CFG_DBITS-1:0];
    end else if (CFG_DBITS <= 9) begin
      assign in_reg[35:CFG_DBITS]  = 0;
      assign in_reg[CFG_DBITS-1:0] = DIN[CFG_DBITS-1:0];
    end
  endgenerate
  
  case (CFG_DBITS)
		1: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_1, `MODE_1, `MODE_1, `MODE_1, SYNC_FIFO
            };
		end

		2: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_2, `MODE_2, `MODE_2, `MODE_2, SYNC_FIFO
            };
		end

		4: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_4, `MODE_4, `MODE_4, `MODE_4, SYNC_FIFO
            };
		end
		8, 9: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_9, `MODE_9, `MODE_9, `MODE_9, SYNC_FIFO
            };
		end

		16, 18: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_18, `MODE_18, `MODE_18, `MODE_18, SYNC_FIFO
            };
		end
		32, 36: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, SYNC_FIFO
            };
		end
		default: begin
          defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'b0,
                11'd10, 11'd10, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, 1'd0,
                UPAF_DBITS, UPAE_DBITS, 4'd0, `MODE_36, `MODE_36, `MODE_36, `MODE_36, SYNC_FIFO
            };
		end
	endcase
  

 	TDP36K _TECHMAP_REPLACE_ (
		.RESET_ni(1'b1),
		.WDATA_A1_i(in_reg[17:0]),
		.WDATA_A2_i(in_reg[35:18]),
		.RDATA_A1_o(fifo_flags),
		.RDATA_A2_o(),
		.ADDR_A1_i(14'h0),
		.ADDR_A2_i(14'h0),
		.CLK_A1_i(Push_Clk),
		.CLK_A2_i(1'b0),
		.REN_A1_i(1'b1),
		.REN_A2_i(1'b0),
		.WEN_A1_i(PUSH),
		.WEN_A2_i(1'b0),
		.BE_A1_i(2'b11),
		.BE_A2_i(2'b11),

		.WDATA_B1_i(18'h0),
		.WDATA_B2_i(18'h0),
		.RDATA_B1_o(out_reg[17:0]),
		.RDATA_B2_o(out_reg[35:18]),
		.ADDR_B1_i(14'h0),
		.ADDR_B2_i(14'h0),
		.CLK_B1_i(Pop_Clk),
		.CLK_B2_i(1'b0),
		.REN_B1_i(POP),
		.REN_B2_i(1'b0),
		.WEN_B1_i(1'b0),
		.WEN_B2_i(1'b0),
		.BE_B1_i(2'b11),
		.BE_B2_i(2'b11),

		.FLUSH1_i(Async_Flush),
		.FLUSH2_i(1'b0)
	);

  assign DOUT[CFG_DBITS-1 : 0] = out_reg[CFG_DBITS-1 : 0];

endmodule

module FIFO_18K_BLK (
    DIN,
    PUSH,
    POP,
    Push_Clk,
    Pop_Clk,
    Async_Flush,
    Overrun_Error,
    Full_Watermark,
    Almost_Full,
    Full,
    Underrun_Error,
    Empty_Watermark,
    Almost_Empty,
    Empty,
    DOUT
);
  
  parameter CFG_DBITS = 18;
  parameter UPAE_DBITS = 11'd10;
  parameter UPAF_DBITS = 11'd10;
  parameter SYNC_FIFO = 1'b0;

  input Push_Clk, Pop_Clk;
  input PUSH, POP;
  input [CFG_DBITS-1:0] DIN;
  input Async_Flush;
  output [CFG_DBITS-1:0] DOUT;
  output Almost_Full, Almost_Empty;
  output Full, Empty;
  output Full_Watermark, Empty_Watermark;
  output Overrun_Error, Underrun_Error;
  
 	BRAM2x18_FIFO  #(
      .CFG_DBITS(CFG_DBITS), 
      .UPAE_DBITS1(UPAE_DBITS),
      .UPAF_DBITS1(UPAF_DBITS),
      .SYNC_FIFO1(SYNC_FIFO), 
      .UPAE_DBITS2(),
      .UPAF_DBITS2(),
      .SYNC_FIFO2()         
       ) _TECHMAP_REPLACE_
      (
      .DIN1(DIN),
      .PUSH1(PUSH),
      .POP1(POP),
      .Push_Clk1(Push_Clk),
      .Pop_Clk1(Pop_Clk),
      .Async_Flush1(Async_Flush),
      .Overrun_Error1(Overrun_Error),
      .Full_Watermark1(Full_Watermark),
      .Almost_Full1(Almost_Full),
      .Full1(Full),
      .Underrun_Error1(Underrun_Error),
      .Empty_Watermark1(Empty_Watermark),
      .Almost_Empty1(Almost_Empty),
      .Empty1(Empty),
      .DOUT1(DOUT),
      
      .DIN2(),
      .PUSH2(),
      .POP2(),
      .Push_Clk2(),
      .Pop_Clk2(),
      .Async_Flush2(),
      .Overrun_Error2(),
      .Full_Watermark2(),
      .Almost_Full2(),
      .Full2(),
      .Underrun_Error2(),
      .Empty_Watermark2(),
      .Almost_Empty2(),
      .Empty2(),
      .DOUT2()
	);

endmodule

