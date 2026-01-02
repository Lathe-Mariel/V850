module Memory_tb();


logic clk;
logic rst_n;

logic[28:0] test_memory_address;
logic[28:0] memory_address_o;
logic[9:0] circuit_sel_i;
logic[4:0] dest_reg_i;
logic[4:0] dest_reg_o;
logic[31:0] write_back_data;
logic ddr_cmd_rdy;
logic read_or_write;     // memory_cmd;
logic memory_enable;
logic cmd_rdy;
logic readdata_valid;
logic readdata_end;

logic[31:0] store_data;
logic write_enable;
logic write_rdy;
logic[31:0] write_data;
logic write_data_end;

// 16'b00010_001110_00001    ADD reg1, reg2
// 16'b00010_010010_11111    ADD imm5, reg2
// 16'b00100_001010_00001    AND reg1, reg2
// 16'b01001_001111_00001    CMP reg1, reg2
// 16'b00011_110110_00001  16'b00000_000000_01011    ANDI imm16, reg1, reg2
// 16'b00000_000000_00000    NOP


/*******************
target module instanciate
*******************/
Memory inst_Memory(
  .clk(clk),
  .destination_i(dest_reg_i),
  .memory_address_i(test_memory_address),
  .memory_address_o(memory_address_o),
  .circuit_sel_i(circuit_sel_i),
  .wb_data_o(write_back_data),
  .destination_o(dest_reg_o),

  .memory_cmd_rdy_i(cmd_rdy),               // DDR3 command recieve ready
  .memory_read_data_valid_i(readdata_valid),
  .memory_read_data_end_i(readdata_end),
  .memory_enable_o(memory_enable),                // -> DDR3 IP
  .memory_cmd_o(read_or_write),

  .store_data_i(store_data),                  // ST data
  .memory_write_enable_o(write_enable),
  .memory_write_rdy_i(write_rdy),
  .memory_write_data_o(write_data),
  .memory_write_data_end_o(write_data_end)
);


initial begin
// assign circuit_sel_i = 10'b01_0000_0000;
// assign circuit_sel_i = 10'b01_0000_0001;

dest_reg_i = 5'b00001;

memory_enable = 1'b1;
readdata_valid = 1'b0;
readdata_end = 1'b0;

/*
    {test_memory[1], test_memory[0]}   = {16'b00010_001110_00001};    //ADD       11C1
    {test_memory[3], test_memory[2]}   = {16'b00010_010010_11111};    //ADD       125F
    {test_memory[5], test_memory[4]}   = {16'b00100_001010_00001};    //AND       2141
    {test_memory[7], test_memory[6]}   = {16'b00011_110110_00001};    //ANDI 32   1EC1
    {test_memory[9], test_memory[8]}   = {16'b00000_000000_01011};    //          000B
    {test_memory[11], test_memory[10]} = {16'b01001_001111_00001};  //CMP
    {test_memory[13], test_memory[12]} = {16'b00000_000000_00000};  //NOP
    {test_memory[15], test_memory[14]} = {16'b00000_000000_00000};  //NOP
    {test_memory[17], test_memory[16]} = {16'b00000_000000_00000};  //NOP
    {test_memory[19], test_memory[18]} = {16'b00000_000000_00000};  //NOP
*/

//rst_n = 1'b1;
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

clk <= 1'b1; rst_n = 1'b0;#10;
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