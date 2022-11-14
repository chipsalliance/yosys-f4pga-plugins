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

`timescale 1ps/1ps

`default_nettype none

(* abc9_flop, lib_whitebox *)
module sh_dff(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C
);

    initial Q <= 1'b0;
    always @(posedge C)
        Q <= D;
		
    specify
      (posedge C => (Q +: D)) = 0;
      $setuphold(posedge C, D, 0, 0);
    endspecify

endmodule

(* abc9_box, lib_blackbox *)
module adder_carry(
    output wire sumout,
    output wire cout,
    input wire p,
    input wire g,
    input wire cin
);
    assign sumout = p ^ cin;
    assign cout = p ? cin : g;
	
    specify
        (p => sumout) = 0;
        (g => sumout) = 0;
        (cin => sumout) = 0;
        (p => cout) = 0;
        (g => cout) = 0;
        (cin => cout) = 0;
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module dff(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C
);
    initial Q <= 1'b0;

    always @(posedge C)
      Q <= D;

    specify
	    (posedge C=>(Q+:D)) = 0;
	    $setuphold(posedge C, D, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module dffn(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C
);
    initial Q <= 1'b0;

    always @(negedge C)
      Q <= D;
	  
    specify
	    (negedge C=>(Q+:D)) = 0;
	    $setuphold(negedge C, D, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module dffsre(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C,
    input wire E,
    input wire R,
    input wire S
);
    initial Q <= 1'b0;

    always @(posedge C or negedge S or negedge R)
      if (!R)
        Q <= 1'b0;
      else if (!S)
        Q <= 1'b1;
      else if (E)
        Q <= D;

    specify
      (posedge C => (Q +: D)) = 0;
      (R => Q) = 0;
      (S => Q) = 0;
      $setuphold(posedge C, D, 0, 0);
      $setuphold(posedge C, E, 0, 0);
      $setuphold(posedge C, R, 0, 0);
      $setuphold(posedge C, S, 0, 0);
      $recrem(posedge R, posedge C, 0, 0);
      $recrem(posedge S, posedge C, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module dffnsre(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C,
    input wire E,
    input wire R,
    input wire S
);
    initial Q <= 1'b0;

    always @(negedge C or negedge S or negedge R)
      if (!R)
        Q <= 1'b0;
      else if (!S)
        Q <= 1'b1;
      else if (E)
        Q <= D;
		
    specify
      (negedge C => (Q +: D)) = 0;
      (R => Q) = 0;
      (S => Q) = 0;
      $setuphold(negedge C, D, 0, 0);
      $setuphold(negedge C, E, 0, 0);
      $setuphold(negedge C, R, 0, 0);
      $setuphold(negedge C, S, 0, 0);
      $recrem(posedge R, negedge C, 0, 0);
      $recrem(posedge S, negedge C, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module sdffsre(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C,
    input wire E,
    input wire R,
    input wire S
);
    initial Q <= 1'b0;

    always @(posedge C)
      if (!R)
        Q <= 1'b0;
      else if (!S)
        Q <= 1'b1;
      else if (E)
        Q <= D;
		
    specify
        (posedge C => (Q +: D)) = 0;
        $setuphold(posedge C, D, 0, 0);
        $setuphold(posedge C, R, 0, 0);
        $setuphold(posedge C, S, 0, 0);
        $setuphold(posedge C, E, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module sdffnsre(
    output reg Q,
    input wire D,
    (* clkbuf_sink *)
    input wire C,
    input wire E,
    input wire R,
    input wire S
);
    initial Q <= 1'b0;

    always @(negedge C)
      if (!R)
        Q <= 1'b0;
      else if (!S)
        Q <= 1'b1;
      else if (E)
        Q <= D;
		
    specify
        (negedge C => (Q +: D)) = 0;
        $setuphold(negedge C, D, 0, 0);
        $setuphold(negedge C, R, 0, 0);
        $setuphold(negedge C, S, 0, 0);
        $setuphold(negedge C, E, 0, 0);
    endspecify

endmodule

(* abc9_flop, lib_whitebox *)
module latchsre (
    output reg Q,
    input wire S,
    input wire R,
    input wire D,
    input wire G,
    input wire E
);
    initial Q <= 1'b0;

    always @*
      begin
        if (!R)
          Q <= 1'b0;
        else if (!S)
          Q <= 1'b1;
        else if (E && G)
          Q <= D;
      end
	  
    specify
      (posedge G => (Q +: D)) = 0;
      $setuphold(posedge G, D, 0, 0);
      $setuphold(posedge G, E, 0, 0);
      $setuphold(posedge G, R, 0, 0);
      $setuphold(posedge G, S, 0, 0);
    endspecify      

endmodule

(* abc9_flop, lib_whitebox *)
module latchnsre (
    output reg Q,
    input wire S,
    input wire R,
    input wire D,
    input wire G,
    input wire E
);
    initial Q <= 1'b0;

    always @*
      begin
        if (!R)
          Q <= 1'b0;
        else if (!S)
          Q <= 1'b1;
        else if (E && !G)
          Q <= D;
      end
	  
    specify
      (negedge G => (Q +: D)) = 0;
      $setuphold(negedge G, D, 0, 0);
      $setuphold(negedge G, E, 0, 0);
      $setuphold(negedge G, R, 0, 0);
      $setuphold(negedge G, S, 0, 0);
    endspecify 

endmodule

module fpga_interconnect(datain, dataout);
    input  wire datain;
    output wire dataout;

    assign dataout = datain;

    specify
        (datain => dataout) = 0;
    endspecify

endmodule

module LUT_K #(
    //The Look-up Table size (number of inputs)
    // supports 1<=K<=6
    parameter K = 5, 

    //The lut mask.  
    //Left-most (MSB) bit corresponds to all inputs logic one. 
    //Defaults to always false.
    parameter LUT_MASK={2**K{1'b0}} 
) (
    //input  wire [K-1:0] in,
    input  wire [5:0] in,
    output wire out
);

    wire    [63:0]  LUT_MASK_full;
    assign LUT_MASK_full =  (K == 6) ?  LUT_MASK[63:0] :
                            (K == 5) ?  {32'b0, LUT_MASK[31:0]} :
                            (K == 4) ?  {48'b0, LUT_MASK[15:0]} :
                            (K == 3) ?  {56'b0, LUT_MASK[7:0]} :
                            (K == 2) ?  {60'b0, LUT_MASK[3:0]} :
                                        {62'b0, LUT_MASK[1:0]} ;
    
    reg     [5:0]   in_full;
    always @(*)
        case(K)
            6:          in_full <= in[5:0];
            5:          in_full <= {1'b0, in[4:0]};
            4:          in_full <= {2'b0, in[3:0]};
            3:          in_full <= {3'b0, in[2:0]};
            2:          in_full <= {4'b0, in[1:0]};
            1:          in_full <= {5'b0, in[0]};
            default:    in_full <= in[5:0];
        endcase

    assign out = LUT_MASK_full[in_full];

    specify
        (in[0] => out) = 0;
        (in[1] => out) = 0;
        (in[2] => out) = 0;
        (in[3] => out) = 0;
        (in[4] => out) = 0;
        (in[5] => out) = 0;
    endspecify    

endmodule