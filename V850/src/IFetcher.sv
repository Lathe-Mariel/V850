module IFetcher(
input logic clk,
input logic[24:0] PC_i,
output logic[63:0] instruction_o,
output logic[24:0] PC_o
);

logic [7:0] test_memory[64];    // for test_memory

logic[24:0] PC;

// 16'b00010_001110_00001    ADD reg1, reg2
// 16'b00010_010010_11111    ADD imm5, reg2
// 16'b00100_001010_00001    AND reg1, reg2
// 16'b01001_001111_00001    CMP reg1, reg2
// 16'b00011_110110_00001  16'b00000_000000_01011    ANDI imm16, reg1, reg2

assign {test_memory[0], test_memory[1]} = {16'b00010_001110_00001};    //ADD
assign {test_memory[2], test_memory[3]} = {16'b00010_010010_11111};    //ADD
assign {test_memory[4], test_memory[5]} = {16'b00100_001010_00001};    //AND
assign {test_memory[6], test_memory[7]} = {16'b00011_110110_00001};    //ANDI
assign {test_memory[8], test_memory[9]} = {16'b00000_000000_01011};
assign {test_memory[10], test_memory[11]} = {16'b01001_001111_00001};  //CMP


logic [15:0] fetch;  // tmp instruction
logic reg2_en;       // reg2 number is not 0

assign reg2_en = |{test_memory[PC << 1 + 1][7:3]};  // when reg2 number is 0

always_ff @(posedge clk)begin
    fetch = {test_memory[{PC, 1}], test_memory[{PC, 0}]};    // 16 bit fetch
    if(fetch[10:9] == 2'b11)begin
        if(reg2_en && (fetch[8] + fetch[7] + fetch[6]) == 1'b0)begin
            // 32bit inst
            PC <= PC + 25'd2;
            instruction_o <= {fetch, test_memory[PC+2], test_memory[PC+3]};
        end else begin
            // ★
            // 48 bit
            PC <= PC + 25'd3;

            //  64 bit
            PC <= 25'd4;
        end

    end else begin
        // 16bit inst
        instruction_o <= fetch;
        PC <= PC + 25'd1;
    end


end

endmodule