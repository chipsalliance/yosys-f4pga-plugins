// Basic DFF

module \$_DFF_P_ (D, Q, C);
    input D;
    input C;
    output Q;
    dff _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C));
endmodule

// reset
module \$_DFF_PP0_ (D, Q, C, R);
    input D;
    input C;
    input R;
    output Q;
    dffr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .R(!R));
endmodule

// Sync reset, enable.

module  \$_SDFFE_PP0P_ (input D, C, E, R, output Q);
  parameter _TECHMAP_WIREINIT_Q_ = 1'bx;
  dffre  _TECHMAP_REPLACE_ (.D(D), .Q(Q), .C(C), .E(E), .R(R));
endmodule


// Latches with reset.

module  \$_DLATCH_PP0_ (input E, R, D, output Q);
  parameter _TECHMAP_WIREINIT_Q_ = 1'bx;
  latch _TECHMAP_REPLACE_ (.D(D), .Q(Q), .E(E), .R(R));
  wire _TECHMAP_REMOVEINIT_Q_ = 1;
endmodule

