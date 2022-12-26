module spram_36x1024 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 10;
parameter RD_ADDR_WIDTH = 10;
parameter WR_DATA_WIDTH = 36;
parameter RD_DATA_WIDTH = 36;
parameter BE_WIDTH = 4;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(4'b1111),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule    

module spram_32x1024 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 10;
parameter RD_ADDR_WIDTH = 10;
parameter WR_DATA_WIDTH = 32;
parameter RD_DATA_WIDTH = 32;
parameter BE_WIDTH = 4;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(4'b1111),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule   

module spram_18x2048 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 11;
parameter RD_ADDR_WIDTH = 11;
parameter WR_DATA_WIDTH = 18;
parameter RD_DATA_WIDTH = 18;
parameter BE_WIDTH = 2;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(2'b11),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule    

module spram_16x2048 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 11;
parameter RD_ADDR_WIDTH = 11;
parameter WR_DATA_WIDTH = 16;
parameter RD_DATA_WIDTH = 16;
parameter BE_WIDTH = 2;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(2'b11),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule    

module spram_9x4096 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 12;
parameter RD_ADDR_WIDTH = 12;
parameter WR_DATA_WIDTH = 9;
parameter RD_DATA_WIDTH = 9;
parameter BE_WIDTH = 1;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(1'b1),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule    

module spram_8x4096 (
    WEN_i,
    REN_i,
    clock0,
    clock1,
    WR_ADDR_i,
    RD_ADDR_i,
    WDATA_i,
    RDATA_o
);

parameter WR_ADDR_WIDTH = 12;
parameter RD_ADDR_WIDTH = 12;
parameter WR_DATA_WIDTH = 8;
parameter RD_DATA_WIDTH = 8;
parameter BE_WIDTH = 1;

input wire WEN_i;
input wire REN_i;
input wire clock0;
input wire clock1;
input wire [WR_ADDR_WIDTH-1 :0] WR_ADDR_i;
input wire [RD_ADDR_WIDTH-1 :0] RD_ADDR_i;
input wire [WR_DATA_WIDTH-1 :0] WDATA_i;
output wire [RD_DATA_WIDTH-1 :0] RDATA_o;

RAM_36K_BLK #(
              .WR_ADDR_WIDTH(WR_ADDR_WIDTH),
              .RD_ADDR_WIDTH(RD_ADDR_WIDTH),
              .WR_DATA_WIDTH(WR_DATA_WIDTH),
              .RD_DATA_WIDTH(RD_DATA_WIDTH),
              .BE_WIDTH(BE_WIDTH)
              ) spram_x36_inst (
              
              .WEN_i(WEN_i),
              .WR_BE_i(1'b1),
              .REN_i(REN_i),              
              .WR_CLK_i(clock0),
              .RD_CLK_i(clock1),
              .WR_ADDR_i(WR_ADDR_i),
              .RD_ADDR_i(RD_ADDR_i),
              .WDATA_i(WDATA_i),
              .RDATA_o(RDATA_o)
              );
              
endmodule    