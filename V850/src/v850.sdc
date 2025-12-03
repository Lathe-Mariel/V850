//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.01 (64-bit) 
//Created Time: 2025-09-15 23:20:50

create_clock -name clk -period 20 -waveform {0 10} [get_ports {clk}]
