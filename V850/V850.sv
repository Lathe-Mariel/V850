`default_nettype none

module V850 (
input wire clk,
input wire sw0,
input wire sw1,
input wire rst_n,
output wire fan
);

logic[31:0] PC;    // [31:26] is automatically filled by sign extension. value of PC[0] is always 0.
//logic[31:0][0] r0
logic[31:0] r[31:0];    //general registers. r[1] is r1.

// CPU Function group system registers
logic[31:0] EIPC;   // status save register when EI level exception received
logic[31:0] EIPSW;  // status save register when EI level exception received
logic[31:0] FEPC;   // status save register when FE level exception received
logic[31:0] FEPSW;  // status save register when FE level exception received
logic[31:0] ECR;    // factor of exception
logic[31:0] PSW;    // program status word
logic[31:0] SCCFG;  // action setting for SYSCALL
logic[31:0] SCBP;   //SYSCALL base pointer
logic[31:0] EIIC;   // factor of EI level exception
logic[31:0] FEIC;   //factor of FE level exception
logic[31:0] DBIC;   //factor of DB level exception
logic[31:0] CTPC;   // status save register when execute CALLT
logic[31:0] CTPSW;  //status save register when execute CALLT
logic[31:0] DBPC;   // status save register when DB level exception received
logic[31:0] DBPSW;  // status save register when DB level exception received
logic[31:0] CTBP;   //CALLT base pointer
logic[31:0] debug_register;  // debug function registers
logic[31:0] EIWR;   // working register for EI level exception
logic[31:0] FEWR;   // working register for FE level exception
logic[31:0] DBWR;   // working register for DB level exception
logic[31:0] BSEL;   // selection of register bank

logic[31:0] decord_instruction;  // cpu instruction on decord section

// decorder
always @(posedge clk)begin
    if(decord_instruction[10:5] == 6'b001110)begin
        // ADD reg1, reg2
    end else if(decord_instruction[10:5] == 6'b010010)begin
        // ADD imm5, reg2
    end else if(decord_instruction[10:5] == 6'b110000)begin
        // ADDI imm16, reg1, reg2
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011101)begin
        // ADF cccc, reg1, reg2, reg3(cccc is conditions)
    end else if(decord_instruction[10:5] == 6'b001010)begin
        // AND reg1, reg2
    end else if(decord_instruction[10:5] == 6'b110110)begin
        // ANDI imm16, reg1, reg2
    end else if(decord_instruction[11:8] == 4'b1011)begin    // ddddd1011dddcccc
        // Bcound disp9
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000010)begin    // rrrrr11111100000 wwwww01101000010
        // BSH reg2, reg3
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000000)begin    // rrrrr11111100000 wwwww01101000000
        // BSW reg2, reg3
    end else if(decord_instruction[15:6] == 10'b0000001000)begin    // 0000001000iiiiii
        // CALLT imm6
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 00011101110)begin    //rrrrr111111RRRRR wwwww00011101110
        // CAXI [reg1], reg2, reg3
    end else if(decord_instruction[15:14] == 2'b10 && decord_instruction[10:5] == 6'b111110)begin    // 10bbb111110RRRRR dddddddddddddddd
        // CLR1 bit#3, disp16 [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100100)begin    // rrrrr111111RRRRR 0000000011100100
        // CLR1 reg2, [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011001 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwwww011001cccc0
        // CMOV cccc, reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011000 && decord_instruction[16] == 1'b0)begin    // rrrrr111111iiiii wwwww011000cccc0
        // CMOV cccc, imm5, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b001111)begin    // rrrrr001111RRRRR
        // CMP reg1, reg2
    end else if(decord_instruction[10:5] == 6'b010011)begin    // rrrrr010011iiiii
        // CMP imm5, reg2
    end else if(decord_instruction[31:0] == {16'b0000000101000100, 16'b0000011111100000})begin    // 0000011111100000 0000000101000100
        // CTRET
    end else if(decord_instruction[31:0] == {16'b0000000101100000, 16'b0000011111100000})begin    // 0000011111100000 0000000101100000
        // DI
    end else if(decord_instruction[15:6] == 10'b0000011001 && decord_instruction[4:0] == 5'b00000)begin    //0000011001iiiiiL LLLLLLLLLLL00000
        // DISPOSE imm5, list12
    end else if(decord_instruction[15:6] == 10'b0000011001)begin    // 0000011001iiiiiL LLLLLLLLLLLRRRRR (RRRR!=00000)
        // DISPOSE imm5, list12, [reg1]    <p82>
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011000000)begin    // rrrrr111111RRRRR wwwww01011000000
        // DIV reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b000010)begin    // rrrrr000010RRRRR
        // DIVH reg1, reg2    (RRRRR != 00000,    rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01010000000)begin    // rrrrr111111RRRRR wwwww01010000000
        // DIVH reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01010000010)begin    // rrrrr111111RRRRR wwwww01010000010
        // DIVHU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011111100)begin    // rrrrr111111RRRRR wwwww01011111100
        // DIVQ reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011111110)begin    // rrrrr111111RRRRR wwwww01011111110
        // DIVQU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011000010)begin    // rrrrr111111RRRRR wwwww01011000010
        // DIVU reg1, reg2, reg3
    end else if(decord_instruction[31:0] == {16'b0000000101100000, 16'b1000011111100000})begin    // 1000011111100000 0000000101100000
        // EI    <p90>
    end else if(decord_instruction[31:0] == {16'b0000000101001000, 16'b0000011111100000})begin    // 0000011111100000 0000000101001000
        // EIRET
    end else if(decord_instruction[31:0] == {16'b0000000101001010, 16'b0000011111100000})begin    // 0000011111100000 0000000101001010
        // FERET
    end else if(decord_instruction[15] == 0 && decord_instruction[10:0] == 11'b00001000000)begin    // 0vvvv00001000000
        // FETRAP vector4    (vvvv != 0000)
    end else if(decord_instruction[31:0] == {16'b0000000100100000, 16'b0000011111100000})begin    // 0000011111100000 0000000100100000
        // HALT
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000110)begin    // rrrrr11111100000 wwwww01101000110
        // HSH reg2, reg3    <p95>
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000100)begin    // rrrrr11111100000 wwwww01101000100
        // HSW reg2, reg3
    end else if(decord_instruction[10:6] == 5'b11110 && decord_instruction[16] == 1'b0)begin    // rrrrr11110dddddd ddddddddddddddd0
        // JARL disp22, reg2    (rrrrr != 00000)
    end else if(decord_instruction[15:5] == 11'b00000010111 && decord_instruction[16] == 1'b0)begin    // 00000010111RRRRR ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JARL disp32, reg1    (RRRRR != 00000)
    end else if(decord_instruction[15:5] == 11'b00000000011)begin    // 00000000011RRRRR
        // JMP [reg1]
    end else if(decord_instruction[15:5] == 11'b00000110111 && decord_instruction[16] == 1'b0)begin    // 00000110111RRRRR ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JMP disp32 [reg1]
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[16] == 1'b0)begin    // 0000011110dddddd ddddddddddddddd0
        // JR disp22
    end else if(decord_instrcution[15:0] == 16'b0000001011100000 && decord_instruction[16] == 1'b0)begin    // 0000001011100000 ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JR disp32
    end else if(decord_instruction[10:5] == 6'b111000)begin    // rrrrr111000RRRRR dddddddddddddddd
        // LD.B disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[19:16] == 4'b0101)begin    // 00000111100RRRRR wwwwwddddddd0101 DDDDDDDDDDDDDDDD
        // LD.B dis23 [reg1], reg3
    end else if(decord_instruction[10:6] == 5'b11110 && decord_instruction[16] == 1'b1)begin    // rrrrr11110bRRRRR ddddddddddddddd1
        // LD.BU disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111101 && decord_instruction[19:16] == 4'b0101)begin    // 00000111101RRRRR wwwwwddddddd0101 DDDDDDDDDDDDDDDD
        // LD.BU disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111001 && decord_instruction[16] == 1'b0)begin    // rrrrr111001RRRRR ddddddddddddddd0
        // LD.H disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100RRRRR && decord_instruction[20:16] == 5'b00111)begin    // 00000111100RRRRR wwwwwdddddd00111 DDDDDDDDDDDDDDDD
        // LD.H disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[16] == 1'b1)begin    // rrrrr111111RRRRR ddddddddddddddd1
        // LD.HU disp16 [reg1], reg2    (rrrrr != 00000
    end else if(decord_instruction[15:5] == 11'b00000111101 && decord_instruction[20:16] == 5'b00111)begin    // 00000111101RRRRR wwwwwdddddd00111 DDDDDDDDDDDDDDDD
        // LD.HU disp23 [reg1], reg3    <p104>
    end else if(decord_instruction[10:5] == 6'b111001 && decord_instruction[16] == 1'b1)begin    // rrrrr111001RRRRR ddddddddddddddd1
        // LD.W disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[20:16] == 01001)begin    // 00000111100RRRRR wwwwwdddddd01001 DDDDDDDDDDDDDDDD
        // LD.w disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000000100000)begin    // rrrrr111111RRRRR 0000000000100000
        // LDSR reg2, regID
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 7'b0011110 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwww0011110mmmm0
        // MAC reg1, reg2, reg3, reg4
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 7'b0011111 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwww0011111mmmm0
        // MACU reg1, reg2, reg3, reg4
    end else if(decord_instruction[10:5] == 6'b000000)begin    // rrrrr000000RRRRR
        // MOV reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b010000)begin    // rrrrr010000iiiii
        // MOV imm5, reg2    (rrrrr != 00000)
    end else if(decord_instruction[15:5] == 6'b00000110001)begin    // 00000110001RRRRR iiiiiiiiiiiiiiii IIIIIIIIIIIIIIII
        // MOV imm32, reg1
    end else if(decord_instruction[10:5] == 6'b110001)begin    // rrrrr110001RRRRR iiiiiiiiiiiiiiii
        // MOVEA imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b110010)begin    // rrrrr110010RRRRR iiiiiiiiiiiiiiii
        // MOVHI imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01000100000)begin    // rrrrr111111RRRRR wwwww01000100000
        // MUL reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:22] == 5'b01001 && decord_instruction[17:16] == 2'b00)begin    // rrrrr111111iiiii wwwww01001IIII00
        // MUL imm9, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b000111)begin    // rrrrr000111RRRRR
        // MULH reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b010111)begin    // rrrrr010111iiiii
        // MULH imm5, reg2    (rrrrr != 00000
    end else if(decord_instruction[10:5] == 6'b110111)begin    // rrrrr110111RRRRR iiiiiiiiiiiiiiii
        // MULHI imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01000100010)begin    // rrrrr111111RRRRR wwwww01000100010
        // MULU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:22] == 5'b01001 && decord_instruction[17:16] == 2'b10)begin    // rrrr111111iiiii wwwww01001IIII10
        // MULU imm9, reg2, reg3
    end else if(decord_instruction[15:0] == 16'b0000000000000000)begin
        // NOP    (=MOV r0, r0)
    end else if(decord_instruction[10:5] == 6'b000001)begin    // rrrrr000001RRRRR
        // NOT reg1, reg2
    end else if(decord_instruction[15:14] == 2'b01 && decord_instruction[10:5] == 6'b111110)begin    // 01bbb111110RRRRR dddddddddddddddd
        // NOT1 bit#3, disp16 [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100010)begin    // rrrrr111111RRRRR 0000000011100010
        // NOT1 reg2, [reg1]    <p118>
    end else if(decord_instruction[10:5] == 6'b001000)begin    // rrrrr001000RRRRR
        // OR reg1, reg2
    end else if(decord_instruction[10:5] == 6'b110100)begin    // rrrrr110100RRRRR iiiiiiiiiiiiiiii
        // ORI imm16, reg1, reg2
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[20:16] == 5'b00001)begin    // 0000011110iiiiiL LLLLLLLLLLL00001
        // PREPARE list12, imm5
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[18:16] == 3'b011)begin    // 0000011110iiiiiL LLLLLLLLLLLff011 (imm16 / imm32)
        // PREPARE list12, imm5, sp/imm
    end else if(decord_instruction[31:0] == {16'b0000000101000000, 16'b0000011111100000})begin    // 0000011111100000 0000000101000000
        // RETI
    end else if(decord_instruction[15:0] == 16'b0000000001000000)begin    // 0000000001000000
        // RIE
    end else if(decord_instruction[10:4] == 7'b1111111 && decord_instruction[31:16] == 16'b0000000000000000)begin    // iiiii1111111IIII 0000000000000000
        // RIE imm5, imm4    <p126>
    end
end

endmodule

`default_nettype wire
