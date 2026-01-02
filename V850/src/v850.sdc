//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 (64-bit) 
//Created Time: 2026-01-02 18:21:32
create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]
create_generated_clock -name memory_clk -source [get_ports {clk}] -master_clock clk -multiply_by 8 [get_nets {memory_clk}]
create_generated_clock -name clk_x1 -source [get_ports {clk}] -master_clock clk -multiply_by 2 [get_nets {inst_ddr3/gw3_top/clk_x1}]
set_clock_groups -asynchronous -group [get_clocks {clk_x1}] -group [get_clocks {memory_clk}] -group [get_clocks {clk}]
