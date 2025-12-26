module Decorder_tb();

logic clk;
logic[63:0] inst_data;
logic[24:0] PC;
logic [63:0] test_inst_data[16];    // for test_memory
logic reset;

logic[31:0] reg1, reg2, reg3;
logic inc_bit;
logic[4:0] dest, dest2;
logic[9:0] circuit_sel;
logic[31:0] test_PSW;

// 16'b00010_001110_00001    ADD reg1, reg2
// 16'b00010_010010_11111    ADD imm5, reg2
// 16'b00100_001010_00001    AND reg1, reg2
// 16'b01001_001111_00001    CMP reg1, reg2
// 16'b00011_110110_00001  16'b00000_000000_01011    ANDI imm16, reg1, reg2
// 16'b00000_000000_00000    NOP



Decorder inst_Decorder(
    .reg1_o(reg1),
    .reg2_o(reg2),
    .reg3_o(reg3),
    .increment_bit_o(inc_bit),
    .destination_o(dest),    // number of destination register
    .destination2_o(dest2),   // number of destination2 register
    .circuit_sel_o(circuit_sel),
    .clk(clk),
    .PC_ID_i(PC),             // Virtually [25:1] PC at ID stage
    .GR(GR),
    .PSW_i(test_PSW),
    .instruction_ID_i(inst_data)           // cpu instruction on decord section
);

initial begin
     PC = 24'b0;

    test_inst_data[0] = {16'b00010_001110_00001};    //ADD       11C1
    test_inst_data[1] = {16'b00010_010010_11111};    //ADD       125F
    test_inst_data[2] = {16'b00100_001010_00001};    //AND       2141
    test_inst_data[3] = {16'b00011_110110_00001};    //ANDI 32   1EC1
    test_inst_data[4] = {16'b00000_000000_01011};    //          000B
    test_inst_data[5] = {16'b01001_001111_00001};  //CMP
    test_inst_data[6] = {16'b00000_000000_00000};  //NOP
    test_inst_data[7] = {16'b00000_000000_00000};  //NOP
    test_inst_data[8] = {16'b00000_000000_00000};  //NOP
    test_inst_data[9] = {16'b00000_000000_00000};  //NOP

reset = 1'b1;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;

clk <= 1'b1; reset = 1'b0;#10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;
clk <= 1'b0; #10;
clk <= 1'b1; #10;

$finish;

end


endmodule