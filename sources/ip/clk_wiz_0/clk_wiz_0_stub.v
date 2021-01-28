// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
// Date        : Thu Jun 25 16:42:07 2015
// Host        : WK86 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/Work/Vivado/14.2/Nexys4DdrSpectralSources/src/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(ck100MHz, ck4800kHz, ck25MHz, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="ck100MHz,ck4800kHz,ck25MHz,reset,locked" */;
  input ck100MHz;
  output ck4800kHz;
  output ck25MHz;
  input reset;
  output locked;
endmodule
