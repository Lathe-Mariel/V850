module tb_Fetcher();

logic clk;
logic[63:0] inst_data;
logic[24:0] PC;
logic [7:0] test_memory[64];    // for test_memory
logic reset;

// 16'b00010_001110_00001    ADD reg1, reg2
// 16'b00010_010010_11111    ADD imm5, reg2
// 16'b00100_001010_00001    AND reg1, reg2
// 16'b01001_001111_00001    CMP reg1, reg2
// 16'b00011_110110_00001  16'b00000_000000_01011    ANDI imm16, reg1, reg2

always @(posedge clk)begin
    inst_data <= {test_memory[PC%16], test_memory[PC%16+1], test_memory[PC%16+2], test_memory[PC%16+3], test_memory[PC%16+4], test_memory[PC%16+5], test_memory[PC%16+6], test_memory[PC%16+7]};
end

IFetcher inst_IFetcher(
  .clk(clk),
  .reset(reset),
  .PC_i(),
  .mem_i(inst_data),
  .instruction_o(),
  .PC_o(PC)
);

initial begin
    {test_memory[0], test_memory[1]} = {16'b00010_001110_00001};    //ADD
    {test_memory[2], test_memory[3]} = {16'b00010_010010_11111};    //ADD
    {test_memory[4], test_memory[5]} = {16'b00100_001010_00001};    //AND
    {test_memory[6], test_memory[7]} = {16'b00011_110110_00001};    //ANDI
    {test_memory[8], test_memory[9]} = {16'b00000_000000_01011};
    {test_memory[10], test_memory[11]} = {16'b01001_001111_00001};  //CMP

reset = 1'b1;#100;
reset = 1'b0;

#2000;
$finish;

end

    always begin
        clk <= 1'b1; #10;
        clk <= 1'b0; #10;
    end

endmodule