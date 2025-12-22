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
// 16'b00000_000000_00000    NOP

logic [25:0] current_address;

assign current_address = {PC, 1'b0};

always @(posedge clk)begin
    // 64 bit data
    inst_data <= {test_memory[current_address], test_memory[current_address+1], test_memory[current_address+2], test_memory[current_address+3], test_memory[current_address+4], test_memory[current_address+5], test_memory[current_address+6], test_memory[current_address+7]};
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
    {test_memory[0], test_memory[1]}   = {16'b00010_001110_00001};    //ADD
    {test_memory[2], test_memory[3]}   = {16'b00010_010010_11111};    //ADD
    {test_memory[4], test_memory[5]}   = {16'b00100_001010_00001};    //AND
    {test_memory[6], test_memory[7]}   = {16'b00011_110110_00001};    //ANDI 32
    {test_memory[8], test_memory[9]}   = {16'b00000_000000_01011};
    {test_memory[10], test_memory[11]} = {16'b01001_001111_00001};  //CMP
    {test_memory[12], test_memory[13]} = {16'b00000_000000_00000};  //NOP
    {test_memory[14], test_memory[15]} = {16'b00000_000000_00000};  //NOP
    {test_memory[16], test_memory[17]} = {16'b00000_000000_00000};  //NOP
    {test_memory[18], test_memory[18]} = {16'b00000_000000_00000};  //NOP

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