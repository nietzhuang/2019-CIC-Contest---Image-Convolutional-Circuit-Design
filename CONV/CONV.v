`timescale 1ns/10ps
`include "ctrl.v"
`include "nn.v"
`include "mac.v"

module  CONV(
    input       clk,
    input       reset,
    output      busy, 
    input       ready,
            
    output  [11:0]  iaddr,
    input   [19:0]  idata,

    output      cwr,
    output  [11:0]  caddr_wr,
    output  [19:0]  cdata_wr,

    output      crd,
    output  [11:0]  caddr_rd,
    input   [19:0]  cdata_rd,

    output  [2:0]   csel
    );

    wire done, load_done, load_done_2;
    wire fm;
    wire [1:0]layer;
    wire flag_corner, flag_upbot, flag_lfri;
    wire [3:0] cnt_pixel;
    
    ctrl ctrl0(.clk(clk),
               .reset(reset),
               .busy(busy),
               .ready(ready),
               .flag_corner(flag_corner),
               .flag_upbot(flag_upbot),
               .flag_lfri(flag_lfri),
               .cnt_pixel(cnt_pixel),
               .done(done),
               .load_done(load_done),
               .load_done_2(load_done_2),
               .crd(crd),
               .cwr(cwr),
               .csel(csel),
               .fm(fm),
               .layer(layer)
               );
               
               
    nn     nn0(.clk(clk),
               .reset(reset),
               .csel(csel),
               .busy(busy),
               .ready(ready),
               .iaddr(iaddr),
               .idata(idata),
               .caddr_wr(caddr_wr),
               .cdata_wr(cdata_wr),
               .caddr_rd(caddr_rd),
               .cdata_rd(cdata_rd),
               .fm(fm),
               .layer(layer),
               .flag_corner(flag_corner),
               .flag_upbot(flag_upbot),
               .flag_lfri(flag_lfri),
               .cnt_pixel(cnt_pixel),
               .done(done),
               .load_done(load_done),
               .load_done_2(load_done_2)
               );

endmodule

