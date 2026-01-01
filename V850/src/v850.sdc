//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 (64-bit) 
//Created Time: 2026-01-01 15:10:07
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]
create_generated_clock -name memory_clk -source [get_ports {clk}] -master_clock clk -multiply_by 8 [get_nets {memory_clk}]
create_generated_clock -name clk_x1 -source [get_ports {clk}] -master_clock clk -multiply_by 2 [get_nets {inst_ddr3/gw3_top/clk_x1}]
