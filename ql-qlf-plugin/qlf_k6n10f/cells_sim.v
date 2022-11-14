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

endmodule

