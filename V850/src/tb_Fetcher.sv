module tb_Fetcher();

logic clk;
logic[63:0] inst_data;
logic[24:0] memory_address;
logic [7:0] test_memory[64];    // for test_memory
logic reset;
logic[2:0] next_fetch;

// 16'b00010_001110_00001    ADD reg1, reg2
// 16'b00010_010010_11111    ADD imm5, reg2
// 16'b00100_001010_00001    AND reg1, reg2
// 16'b01001_001111_00001    CMP reg1, reg2
// 16'b00011_110110_00001  16'b00000_000000_01011    ANDI imm16, reg1, reg2
// 16'b00000_000000_00000    NOP

logic [25:0] current_address;

assign current_address = {memory_address, 1'b0};
assign inst_data = {test_memory[current_address+7], test_memory[current_address+6], test_memory[current_address+5], test_memory[current_address+4], test_memory[current_address+3], test_memory[current_address+2], test_memory[current_address+1], test_memory[current_address]};

/*
always @(posedge clk)begin
    // 64 bit data
    inst_data <= {test_memory[current_address+7], test_memory[current_address+6], test_memory[current_address+5], test_memory[current_address+4], test_memory[current_address+3], test_memory[current_address+2], test_memory[current_address+1], test_memory[current_address]};
end
*/

IFetcher inst_IFetcher(
  .clk(clk),
  .rst_n(~reset),
  .PC_i(),
  .memory_data_i(inst_data),
  .instruction_o(),
  .memory_address(memory_address),
  .next_fetch(next_fetch)
);

initial begin
    {test_memory[1], test_memory[0]}   = {16'b00010_001110_00001};    //ADD       11C1
    {test_memory[3], test_memory[2]}   = {16'b00010_010010_11111};    //ADD       125F
    {test_memory[5], test_memory[4]}   = {16'b00100_001010_00001};    //AND       2141
    {test_memory[7], test_memory[6]}   = {16'b00011_110110_00001};    //ANDI 32   1EC1
    {test_memory[9], test_memory[8]}   = {16'b00000_000000_01011};    //          000B
    {test_memory[11], test_memory[10]} = {16'b01001_001111_00001};  //CMP        49E1
    {test_memory[13], test_memory[12]} = {16'b01000_001110_00010};  //ADD        41C2
    {test_memory[15], test_memory[14]} = {16'b00010_010010_11110};  //ADD        125E
    {test_memory[17], test_memory[16]} = {16'b00000_001110_00000};  //NOP        01C0
    {test_memory[19], test_memory[18]} = {16'b00000_001110_00000};  //NOP        01C0
//    {test_memory[21], test_memory[20]} = {16'b10000_111111_00100};  //DIV        87E4
//    {test_memory[23], test_memory[22]} = {16'b10001_010110_00000};  //           8AC0
    {test_memory[21], test_memory[20]} = {16'b10000_000010_00100};  //DIVH         8044
    {test_memory[23], test_memory[22]} = {16'b00000_001110_00000};  //NOP          01C0
//    {test_memory[25], test_memory[24]} = {16'b01001_111111_00000};  //BSH        4FE0
//    {test_memory[27], test_memory[26]} = {16'b01010_011010_00010};  //           5342
    {test_memory[25], test_memory[24]} = {16'b00010_110110_00001};  //ADDI         16C1
    {test_memory[27], test_memory[26]} = {16'b00000_000000_00010};  //             0002
    {test_memory[29], test_memory[28]} = {16'b00000_001110_00000};  //NOP          01C0
    {test_memory[31], test_memory[30]} = {16'b00000_001110_00000};  //NOP          01C0

reset = 1'b1;
clk = 1'b0;
#150;
#5;
reset = 1'b0; #5;

#1100
$finish;

end
always #10 clk = ~clk;

endmodule