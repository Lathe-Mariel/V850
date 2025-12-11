module Decorder(
output logic[31:0] reg1_o, reg2_o, reg3_o,
output logic increment_bit_o,
output logic[4:0] destination_o,    // number of destination register
output logic[4:0] circuit_sel_o,
input clk,
input logic[31:0] PC,
input logic[31:0] GR[31:0],
input logic[31:0] PSW
);

logic[31:0] decord_instruction;  // cpu instruction on decord section

function condition4(
    input logic[3:0] cond_i
);
    case(cond_i)
        4'b1110:condition4= !(PSW[1] ^ PSW[2]);                // (S xor OV) ==0           Greater than or equal signed
        4'b1111:condition4= !((PSW[1] ^ PSW[2]) || PSW[0]);    // ((S xor OV) or Z) ==0    Greater than signed
        4'b0111:condition4= ((PSW[1] ^ PSW[2]) || PSW[0]);     // ((S xor OV) or Z) ==1    Less than or equal signed
        4'b0110:condition4= (PSW[1] ^ PSW[2]);                 // ((S xor OV) ==1          Less than signed
        4'b1011:condition4= !(PSW[3] || PSW[0]);               // ((CY or Z) ==0           Higher(Greater than)
        4'b0001:condition4= PSW[3];                            // CY ==1                   Lower(Less than)
        4'b0011:condition4= (PSW[3] || PSW[0]);                // (CY or Z) ==1            Not higher(Less than or equal)
        4'b1001:condition4= !PSW[3];                           // CY ==0                   Not lower(Greater than or equal)
        4'b0010:condition4= PSW[0];                            // Z ==1                    Equal
        4'b1010:condition4= !PSW[0];                           // Z ==0                    Not equal

//      4'b0001:condition4= PSW[3];                            // CY ==1                   Carry
//      4'b1010:condition4= !PSW[0];                           // Z ==0                    False
        4'b0100:condition4= PSW[1];                            // S ==1                    Negative
//      4'b1001:condition4= !PSW[3];                           // Z ==0                    No carry
        4'b1000:condition4= !PSW[2];                           // OV ==0                   No overflow
//      4'b1010:condition4= !PSW[0];                           // Z ==0                    Not zero
        4'b1100:condition4= !PSW[1];                           // S ==0                    Positive
        4'b0101:condition4= 1'b1;                              //                          Always
        4'b1101:condition4= PSW[4];                            // SAT ==1                  Saturated
//      4'b0010:condition4= PSW[0];                            // Z ==1                    True
        4'b0000:condition4= PSW[2];                            // OV =1                    Overflow
//      4'b0010:condition4= PSW[0];                            // Z ==1                    Zero
    endcase
endfunction


// decorder
always @(posedge clk)begin
    if(decord_instruction[10:5] == 6'b001110)begin                          // rrrrr001110RRRRR
        // ADD reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];
        reg2_o <= GR[decord_instruction[15:10]];
        increment_bit_o <= 1'b0;
        destination_o <= decord_instruction[15:10];
        circuit_sel_o <= 5'b00001;
    end else if(decord_instruction[10:5] == 6'b010010)begin                  // rrrrr010010iiiii
        // ADD imm5, reg2
        reg1_o <= {{27{decord_instruction[4]}}, decord_instruction[4:0]};    // immediate5 value (with sign extension)
        reg2_o <= GR[decord_instruction[15:10]];
        increment_bit_o <= 1'b0;
        destination_o <= decord_instruction[15:10];
        circuit_sel_o <= 5'b00001;
    end else if(decord_instruction[10:5] == 6'b110000)begin                  // rrrrr110000RRRRR iiiiiiiiiiiiiiii
        // ADDI imm16, reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];
        reg2_o <= {{16{decord_instruction[31]}}, decord_instruction[31:16]}; // immediate16 value (with sign extension)
        increment_bit_o <= 1'b0;
        destination_o <= decord_instruction[15:10];
        circuit_sel_o <= 5'b00001;
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011101)begin    //rrrrr111111RRRRR wwwww011101cccc0
        // ADF cccc, reg1, reg2, reg3(cccc is conditions)    (cccc != 1101)
        reg1_o <= GR[decord_instruction[4:0]];
        reg2_o <= GR[decord_instruction[15:11]];
        destination_o <= decord_instruction[31:27];                          // destination regster number
        circuit_sel_o <= 5'b00001;
        increment_bit_o <= condition4(decord_instruction[20:17])?1'b1:1'b0;
/*
        if(decord_instruction[20:17] == 4'b0000)begin                        // cccc==0000
            if(PSW[2] == 1'b1)begin                      // V(OV==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1000)begin    // cccc==1000
            if(PSW[2] == 1'b0)begin                               // NV(OV==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0001)begin    // cccc==0001
            if(PSW[3] == 1'b1)begin                               // C/L(CY==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1001)begin    // cccc==1001
            if(PSW[3] == 1'b0)begin                               // NC/NL(CY==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0010)begin    // cccc==0010
            if(PSW[0] == 1'b1)begin                               // Z(Z==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1010)begin    // cccc==1010
            if(PSW[0] == 1'b0)begin                               // NZ(Z==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0011)begin    // cccc==0011
            if(PSW[3] == 1'b1 || PSW[0] == 1'b1)begin             // NH(CY==1 or Z==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1011)begin    // cccc==1011
            if(PSW[3] == 1'b0 || PSW[0] == 1'b0)begin             // H(CY==0 or Z==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0100)begin    // cccc==0100
            if(PSW[1] == 1'b1)begin                               // S/N(S==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1100)begin    // cccc==1100
            if(PSW[1] == 1'b0)begin                               // NS/P(S==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0101)begin    // cccc==0101
                      // T(always)
                increment_bit_o <= 1'b1;
        end else if(decord_instruction[20:17] == 4'b0110)begin    // cccc==0110
            if(PSW[1] ^ PSW[2])begin                              // LT((S xor OV)==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1110)begin    // cccc==1110
            if(!(PSW[1] ^ PSW[2]))begin                           // GE((S xor OV)==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b0111)begin    // cccc==0111
            if((PSW[1] ^ PSW[2]) || PSW[0])begin                  // LT((S xor OV)or Z==1)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end else if(decord_instruction[20:17] == 4'b1111)begin    // cccc==1111
            if(!((PSW[1] ^ PSW[2]) || PSW[0]))begin               // GT((S xor OV)or Z==0)
                increment_bit_o <= 1'b1;
            end else begin
                increment_bit_o <= 1'b0;
            end
        end*/

    end else if(decord_instruction[10:5] == 6'b001010)begin                  //rrrrr001010RRRRR    Format I
        // AND reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];                 // reg1 value
        reg2_o <= GR[decord_instruction[15:11]];               // reg2 value
        destination_o <= decord_instruction[15:11];            // destination regster number
        circuit_sel_o <= 5'b00010;
    end else if(decord_instruction[10:5] == 6'b110110)begin    // rrrrr110110RRRRR iiiiiiiiiiiiiiii     Format VI
        // ANDI imm16, reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];                 // reg1 value
        reg2_o <= {{16{0}},GR[decord_instruction[31:16]]};     // immediate16 with zero extension
        destination_o <= decord_instruction[15:11];            // destination regster number
        circuit_sel_o <= 5'b00010;
    end else if(decord_instruction[11:8] == 4'b1011)begin                              // ddddd1011dddcccc    Format III
        // Bcond disp9
        if(condition4(decord_instruction[3:0]))begin
/*
            decord_instruction[3:0] == 4'b1110 && !(PSW[1] ^ PSW[2]) ||                // (S xor OV) ==0           Greater than or equal signed
            decord_instruction[3:0] == 4'b1111 && !((PSW[1] ^ PSW[2]) || PSW[0]) ||    // ((S xor OV) or Z) ==0    Greater than signed
            decord_instruction[3:0] == 4'b0111 && ((PSW[1] ^ PSW[2]) || PSW[0]) ||     // ((S xor OV) or Z) ==1    Less than or equal signed
            decord_instruction[3:0] == 4'b0110 && (PSW[1] ^ PSW[2]) ||                 // ((S xor OV) ==1          Less than signed

            decord_instruction[3:0] == 4'b1011 && !(PSW[3] || PSW[0]) ||               // ((CY or Z) ==0           Higher(Greater than)
            decord_instruction[3:0] == 4'b0001 && PSW[3] ||                            // CY ==1                   Lower(Less than)
            decord_instruction[3:0] == 4'b0011 && (PSW[3] || PSW[0]) ||                // (CY or Z) ==1            Not higher(Less than or equal)
            decord_instruction[3:0] == 4'b1001 && !PSW[3] ||                           // CY ==0                   Not lower(Greater than or equal)

            decord_instruction[3:0] == 4'b0010 && PSW[0] ||                            // Z ==1                    Equal
            decord_instruction[3:0] == 4'b1010 && !PSW[0] ||                           // Z ==0                    Not equal

//          decord_instruction[3:0] == 4'b0001 && PSW[3] ||                            // CY ==1                   Carry
//          decord_instruction[3:0] == 4'b1010 && !PSW[0] ||                           // Z ==0                    False
            decord_instruction[3:0] == 4'b0100 && PSW[1] ||                            // S ==1                    Negative
//          decord_instruction[3:0] == 4'b1001 && !PSW[3] ||                           // Z ==0                    No carry
            decord_instruction[3:0] == 4'b1000 && !PSW[2] ||                           // OV ==0                   No overflow
//          decord_instruction[3:0] == 4'b1010 && !PSW[0] ||                           // Z ==0                    Not zero
            decord_instruction[3:0] == 4'b1100 && !PSW[1] ||                           // S ==0                    Positive
            decord_instruction[3:0] == 4'b0101 ||                                      //                          Always
            decord_instruction[3:0] == 4'b1101 && PSW[4] ||                            // SAT ==1                  Saturated
//          decord_instruction[3:0] == 4'b0010 PSW[0] ||                               // Z ==1                    True
            decord_instruction[3:0] == 4'b0000 && PSW[2]                               // OV =1                    Overflow
//          decord_instruction[3:0] == 4'b0010 PSW[0] ||                               // Z ==1                    Zero
*/

            reg1_o <= {{23{decord_instruction[15]}}, decord_instruction[15:11], decord_instruction[6:4], 0};
            reg2_o <= PC;
            destination_o <= 5'b00000;
//          increment_bit_o <= 1'b0;    // when destination_o is 5'b00000(PC) , increment_bit_o doesn't matter
            circuit_sel_o <= 5'b00001;
        end
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000010)begin   // rrrrr11111100000 wwwww01101000010    Format XII
        // BSH reg2, reg3
            reg2_o <= {GR[decord_instruction[15:11]][23:16], GR[decord_instruction[15:11]][31:24], GR[decord_instruction[15:11]][7:0], GR[decord_instruction[15:11]][15:8]};
            destination_o <= decord_instruction[31:27];    // reg3
            circuit_sel_o <= 5'b00110;
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000000)begin   // rrrrr11111100000 wwwww01101000000    Format XII
        // BSW reg2, reg3
            reg2_o <= {GR[decord_instruction[15:11]][7:0], GR[decord_instruction[15:11]][15:8], GR[decord_instruction[15:11]][23:16], GR[decord_instruction[15:11]][31:24]};
            destination_o <= decord_instruction[31:27];    // reg3
            circuit_sel_o <= 5'b00111;
    end else if(decord_instruction[15:6] == 10'b0000001000)begin                                                    // 0000001000iiiiii
        // CALLT imm6

    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 00011101110)begin             //rrrrr111111RRRRR wwwww00011101110
        // CAXI [reg1], reg2, reg3
    end else if(decord_instruction[15:14] == 2'b10 && decord_instruction[10:5] == 6'b111110)begin                   // 10bbb111110RRRRR dddddddddddddddd
        // CLR1 bit#3, disp16 [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100100)begin    // rrrrr111111RRRRR 0000000011100100
        // CLR1 reg2, [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011001 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwwww011001cccc0    Format XI
        // CMOV cccc, reg1, reg2, reg3
        reg1_o <= condition4(decord_instruction[20:17])?
          decord_instruction[4:0]:
          GR[decord_instruction[15:11]];
        reg2_o <= {32{1'b0}};                                              // reg2 <- 0
        destination_o <= decord_instruction[31:27];                        // reg3 number
        increment_bit_o <= 1'b0;
        circuit_sel_o <= 5'b00001;

    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011000 && decord_instruction[16] == 1'b0)begin    // rrrrr111111iiiii wwwww011000cccc0    Format XII
        // CMOV cccc, imm5, reg2, reg3
        reg1_o <= condition4(decord_instruction[20:17])?
          {{27{decord_instruction[4]}} ,decord_instruction[4:0]}:
          GR[decord_instruction[15:11]];                                   // signed extended(imm5)
        reg2_o <= {32{1'b0}};                                              // reg2 <- 0
        destination_o <= decord_instruction[31:27];                        // reg3 number
        increment_bit_o <= 1'b0;
        circuit_sel_o <= 5'b00001;

    end else if(decord_instruction[10:5] == 6'b001111)begin                                                         // rrrrr001111RRRRR    Format I
        // CMP reg1, reg2
        reg2_o <= GR[decord_instruction[15:11]];
        reg1_o <= ~(GR[decord_instruction[4:0]]) + 32'b1;                  // exchange sign ★反転する時オーバーフローしたら？
        increment_bit_o <= 1'b0;
        circuit_sel_o <= 5'b00000;

    end else if(decord_instruction[10:5] == 6'b010011)begin                                                         // rrrrr010011iiiii    Format II
        // CMP imm5, reg2
        reg2_o <= GR[decord_instruction[15:11]];
        reg1_o <= {{27{~decord_instruction[4]}}, ~(decord_instruction[4:0]) + 5'b1};                  // exchange sign ★反転する時オーバーフローしたら？imm5は６ビットで反転処理?
        increment_bit_o <= 1'b0;
        circuit_sel_o <= 5'b00000;

    end else if(decord_instruction[31:0] == {16'b0000000101000100, 16'b0000011111100000})begin                      // 0000011111100000 0000000101000100
        // CTRET
    end else if(decord_instruction[31:0] == {16'b0000000101100000, 16'b0000011111100000})begin                      // 0000011111100000 0000000101100000
        // DI
    end else if(decord_instruction[15:6] == 10'b0000011001 && decord_instruction[4:0] == 5'b00000)begin             // 0000011001iiiiiL LLLLLLLLLLL00000
        // DISPOSE imm5, list12
    end else if(decord_instruction[15:6] == 10'b0000011001)begin                                                    // 0000011001iiiiiL LLLLLLLLLLLRRRRR (RRRR!=00000)
        // DISPOSE imm5, list12, [reg1]    <p82>
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011000000)begin         // rrrrr111111RRRRR wwwww01011000000    Format XI
        // DIV reg1, reg2, reg3
        reg1_o <= GR[decord_instruction[4:0]];
        reg2_o <= GR[decord_instruction[15:11]];
        reg3_o <= decord_instruction[31:27];        // reg3 number
        destination_o <= decord_instruction[15:11]; // reg2 number
        circuit_sel_o <= 5'b01000;

    end else if(decord_instruction[10:5] == 6'b000010)begin                                                         // rrrrr000010RRRRR    Format I
        // DIVH reg1, reg2    (RRRRR != 00000,    rrrrr != 00000)
        reg1_o <= {{16{GR[decord_instruction[4:0]][31]}}, GR[decord_instruction[4:0]][15:0]};
        reg2_o <= GR[decord_instruction[15:11]];
        destination_o <= decord_instruction[15:11]; // reg2 number
        circuit_sel_o <= 5'b01000;

    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01010000000)begin         // rrrrr111111RRRRR wwwww01010000000    Format XI
        // DIVH reg1, reg2, reg3
        reg1_o <= {{16{GR[decord_instruction[4:0]][31]}}, GR[decord_instruction[4:0]][15:0]};    // half word(LSB side)
        reg2_o <= GR[decord_instruction[15:11]];
        reg3_o <= decord_instruction[31:27];        // reg3 number
        destination_o <= decord_instruction[15:11]; // reg2 number
        circuit_sel_o <= 5'b01000;

    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01010000010)begin         // rrrrr111111RRRRR wwwww01010000010
        // DIVHU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011111100)begin         // rrrrr111111RRRRR wwwww01011111100
        // DIVQ reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011111110)begin         // rrrrr111111RRRRR wwwww01011111110
        // DIVQU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01011000010)begin         // rrrrr111111RRRRR wwwww01011000010
        // DIVU reg1, reg2, reg3
    end else if(decord_instruction[31:0] == {16'b0000000101100000, 16'b1000011111100000})begin                      // 1000011111100000 0000000101100000
        // EI    <p90>
    end else if(decord_instruction[31:0] == {16'b0000000101001000, 16'b0000011111100000})begin                      // 0000011111100000 0000000101001000
        // EIRET
    end else if(decord_instruction[31:0] == {16'b0000000101001010, 16'b0000011111100000})begin                      // 0000011111100000 0000000101001010
        // FERET
    end else if(decord_instruction[15] == 0 && decord_instruction[10:0] == 11'b00001000000)begin                    // 0vvvv00001000000
        // FETRAP vector4    (vvvv != 0000)
    end else if(decord_instruction[31:0] == {16'b0000000100100000, 16'b0000011111100000})begin                      // 0000011111100000 0000000100100000
        // HALT
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000110)begin   // rrrrr11111100000 wwwww01101000110
        // HSH reg2, reg3    <p95>
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101000100)begin   // rrrrr11111100000 wwwww01101000100
        // HSW reg2, reg3
    end else if(decord_instruction[10:6] == 5'b11110 && decord_instruction[16] == 1'b0)begin                        // rrrrr11110dddddd ddddddddddddddd0
        // JARL disp22, reg2    (rrrrr != 00000)
    end else if(decord_instruction[15:5] == 11'b00000010111 && decord_instruction[16] == 1'b0)begin                 // 00000010111RRRRR ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JARL disp32, reg1    (RRRRR != 00000)
    end else if(decord_instruction[15:5] == 11'b00000000011)begin                                                   // 00000000011RRRRR
        // JMP [reg1]
    end else if(decord_instruction[15:5] == 11'b00000110111 && decord_instruction[16] == 1'b0)begin                 // 00000110111RRRRR ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JMP disp32 [reg1]
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[16] == 1'b0)begin                  // 0000011110dddddd ddddddddddddddd0
        // JR disp22
    end else if(decord_instruction[15:0] == 16'b0000001011100000 && decord_instruction[16] == 1'b0)begin            // 0000001011100000 ddddddddddddddd0 DDDDDDDDDDDDDDDD
        // JR disp32
    end else if(decord_instruction[10:5] == 6'b111000)begin                                                         // rrrrr111000RRRRR dddddddddddddddd
        // LD.B disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[19:16] == 4'b0101)begin           // 00000111100RRRRR wwwwwddddddd0101 DDDDDDDDDDDDDDDD
        // LD.B dis23 [reg1], reg3
    end else if(decord_instruction[10:6] == 5'b11110 && decord_instruction[16] == 1'b1)begin                        // rrrrr11110bRRRRR ddddddddddddddd1
        // LD.BU disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111101 && decord_instruction[19:16] == 4'b0101)begin           // 00000111101RRRRR wwwwwddddddd0101 DDDDDDDDDDDDDDDD
        // LD.BU disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111001 && decord_instruction[16] == 1'b0)begin                       // rrrrr111001RRRRR ddddddddddddddd0
        // LD.H disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[20:16] == 5'b00111)begin          // 00000111100RRRRR wwwwwdddddd00111 DDDDDDDDDDDDDDDD
        // LD.H disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[16] == 1'b1)begin                       // rrrrr111111RRRRR ddddddddddddddd1
        // LD.HU disp16 [reg1], reg2    (rrrrr != 00000
    end else if(decord_instruction[15:5] == 11'b00000111101 && decord_instruction[20:16] == 5'b00111)begin          // 00000111101RRRRR wwwwwdddddd00111 DDDDDDDDDDDDDDDD
        // LD.HU disp23 [reg1], reg3    <p104>
    end else if(decord_instruction[10:5] == 6'b111001 && decord_instruction[16] == 1'b1)begin                       // rrrrr111001RRRRR ddddddddddddddd1
        // LD.W disp16 [reg1], reg2
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[20:16] == 01001)begin             // 00000111100RRRRR wwwwwdddddd01001 DDDDDDDDDDDDDDDD
        // LD.w disp23 [reg1], reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000000100000)begin    // rrrrr111111RRRRR 0000000000100000
        // LDSR reg2, regID
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 7'b0011110 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwww0011110mmmm0
        // MAC reg1, reg2, reg3, reg4
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 7'b0011111 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwww0011111mmmm0
        // MACU reg1, reg2, reg3, reg4
    end else if(decord_instruction[10:5] == 6'b000000)begin                                                         // rrrrr000000RRRRR
        // MOV reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b010000)begin                                                         // rrrrr010000iiiii
        // MOV imm5, reg2    (rrrrr != 00000)
    end else if(decord_instruction[15:5] == 6'b00000110001)begin                                                    // 00000110001RRRRR iiiiiiiiiiiiiiii IIIIIIIIIIIIIIII
        // MOV imm32, reg1
    end else if(decord_instruction[10:5] == 6'b110001)begin                                                         // rrrrr110001RRRRR iiiiiiiiiiiiiiii
        // MOVEA imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b110010)begin                                                         // rrrrr110010RRRRR iiiiiiiiiiiiiiii
        // MOVHI imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01000100000)begin         // rrrrr111111RRRRR wwwww01000100000
        // MUL reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:22] == 5'b01001 && decord_instruction[17:16] == 2'b00)begin    // rrrrr111111iiiii wwwww01001IIII00
        // MUL imm9, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b000111)begin                                                         // rrrrr000111RRRRR
        // MULH reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b010111)begin                                                         // rrrrr010111iiiii
        // MULH imm5, reg2    (rrrrr != 00000
    end else if(decord_instruction[10:5] == 6'b110111)begin                                                         // rrrrr110111RRRRR iiiiiiiiiiiiiiii
        // MULHI imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01000100010)begin         // rrrrr111111RRRRR wwwww01000100010
        // MULU reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:22] == 5'b01001 && decord_instruction[17:16] == 2'b10)begin    // rrrr111111iiiii wwwww01001IIII10
        // MULU imm9, reg2, reg3
    end else if(decord_instruction[15:0] == 16'b0000000000000000)begin
        // NOP    (=MOV r0, r0)
    end else if(decord_instruction[10:5] == 6'b000001)begin                                                         // rrrrr000001RRRRR
        // NOT reg1, reg2
    end else if(decord_instruction[15:14] == 2'b01 && decord_instruction[10:5] == 6'b111110)begin                   // 01bbb111110RRRRR dddddddddddddddd
        // NOT1 bit#3, disp16 [reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100010)begin    // rrrrr111111RRRRR 0000000011100010
        // NOT1 reg2, [reg1]    <p118>
    end else if(decord_instruction[10:5] == 6'b001000)begin                                                         // rrrrr001000RRRRR    Format I
        // OR reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];                 // reg1 value
        reg2_o <= GR[decord_instruction[15:11]];               // reg2 value
        destination_o <= decord_instruction[15:11];            // destination regster number
        circuit_sel_o <= 5'b00011;
    end else if(decord_instruction[10:5] == 6'b110100)begin                                                         // rrrrr110100RRRRR iiiiiiiiiiiiiiii    Format VI
        // ORI imm16, reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];                 // reg1 value
        reg2_o <= {{16{0}},decord_instruction[31:16]};         // immediate16 with 0 extension
        destination_o <= decord_instruction[15:11];            // destination regster number
        circuit_sel_o <= 5'b0011;
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[20:16] == 5'b00001)begin           // 0000011110iiiiiL LLLLLLLLLLL00001
        // PREPARE list12, imm5
    end else if(decord_instruction[15:6] == 10'b0000011110 && decord_instruction[18:16] == 3'b011)begin             // 0000011110iiiiiL LLLLLLLLLLLff011 (imm16 / imm32)
        // PREPARE list12, imm5, sp/imm
    end else if(decord_instruction[31:0] == {16'b0000000101000000, 16'b0000011111100000})begin                      // 0000011111100000 0000000101000000
        // RETI
    end else if(decord_instruction[15:0] == 16'b0000000001000000)begin                                              // 0000000001000000
        // RIE
    end else if(decord_instruction[10:4] == 7'b1111111 && decord_instruction[31:16] == 16'b0000000000000000)begin   // iiiii1111111IIII 0000000000000000
        // RIE imm5, imm4    <p126>
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000010100000)begin    // rrrrr111111RRRRR 0000000010100000
        // SAR reg1, reg2
    end else if(decord_instruction[10:5] == 6'b010101)begin                                                         // rrrrr010101iiiii
        // SAR imm5, reg2
    end else if(decord_instruction[10:5] == 6'b010101 && decord_instruction[26:16] == 11'b00010100010)begin         // rrrrr111111RRRRR wwwww00010100010
        // SAR reg1, reg2, reg3
    end else if(decord_instruction[10:4] == 7'b1111110 && decord_instruction[31:16] == 16'b0000001000000000)begin   // rrrrr1111110cccc 0000001000000000
        // SASF cccc, reg2    <p129>
    end else if(decord_instruction[10:5] == 6'b000110)begin                                                         // rrrrr000110RRRRR
        // SATADD reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b010001)begin                                                         // rrrrr010001iiiii
        // SATADD imm5, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01110111010)begin         // rrrrr111111RRRRR wwwww01110111010
        // SATADD reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b000101)begin                                                         // rrrrr000101RRRRR
        // SATSUB reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b01110011010)begin         // rrrrr111111RRRRR wwwww01110011010
        // SATSUB reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b110011)begin                                                         // rrrrr110011RRRRR iiiiiiiiiiiiiiii
        // SATSUBI imm16, reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b000100)begin                                                         // rrrrr000100RRRRR
        // SATSUBR reg1, reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:21] == 6'b011100 && decord_instruction[16] == 1'b0)begin    // rrrrr111111RRRRR wwwww011100cccc0
        // SBF cccc, reg1, reg2, reg3
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101100100)begin   // rrrrr11111100000 wwwww01101100100
        // SCH0L reg2, reg3
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101100000)begin   // rrrrr11111100000 wwwww01101100000
        // SCH0R reg2, reg3
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101100110)begin   // rrrrr11111100000 wwwww01101100110
        // SCH1L reg2, reg3
    end else if(decord_instruction[10:0] == 11'b11111100000 && decord_instruction[26:16] == 11'b01101100010)begin   // rrrrr11111100000 wwwww01101100010
        // SCH1R reg2, reg3
    end else if(decord_instruction[15:14] == 2'b00 && decord_instruction[10:5] == 6'b111110)begin                   // 00bbb111110RRRRR dddddddddddddddd
        // SET1 bit#3, dips16[reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100000)begin    // rrrrr111111RRRRR 0000000011100000
        // SET1 reg2, [reg1]
    end else if(decord_instruction[10:4] == 7'b1111110 && decord_instruction[31:16] == 16'b0000000000000000)begin   // rrrrr1111110cccc 0000000000000000
        // SETF cccc, reg2
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011000000)begin    // rrrrr111111RRRRR 0000000011000000
        // SHL reg1, reg2
    end else if(decord_instruction[10:5] == 6'b010110)begin                                                         // rrrrr010110iiiii
        // SHL imm5, reg2
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b00011000010)begin         // rrrrr111111RRRRR wwwww00011000010
        // SHL reg1, reg2, reg3
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000010000000)begin    // rrrrr111111RRRRR 0000000010000000
        // SHR reg1, reg2
    end else if(decord_instruction[10:5] == 6'b010100)begin                                                         // rrrrr010100iiiii
        // SHR imm5, reg2
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[26:16] == 11'b00010000010)begin         // rrrrr111111RRRRR wwwww00010000010
        // SHR reg1, reg2, reg3
    end else if(decord_instruction[10:7] == 4'b0110)begin                                                           // rrrrr0110ddddddd
        // SLD.B disp7[ep], reg2
    end else if(decord_instruction[10:4] == 7'b0000110)begin                                                        // rrrrr0000110dddd
        // SLD.BU disp4[ep], reg2    (rrrrr != 00000)    <p149>
    end else if(decord_instruction[10:7] == 4'b1000)begin                                                           // rrrrr1000ddddddd
        // SLD.H disp8[ep], reg2
    end else if(decord_instruction[10:4] == 7'b0000111)begin                                                        // rrrrr0000111dddd
        // SLD.HU disp5[ep], reg2    (rrrrr != 00000)
    end else if(decord_instruction[10:7] == 4'b1010 && decord_instruction[0] == 1'b0)begin                          // rrrrr1010dddddd0
        // SLD.W disp8[ep], reg2
    end else if(decord_instruction[10:7] == 4'b0111)begin                                                           // rrrrr0111ddddddd
        // SST.B reg2, disp7[ep]
    end else if(decord_instruction[10:7] == 4'b1001)begin                                                           // rrrrr1001ddddddd
        // SST.H reg2, disp8[ep]
    end else if(decord_instruction[10:7] == 4'b1010 && decord_instruction[0] == 1'b1)begin                          // rrrrr1010dddddd1
        // SST.W reg2, disp8[ep]
    end else if(decord_instruction[10:5] == 6'b111010)begin                                                         // rrrrr111010RRRRR dddddddddddddddd
        // ST.B reg2, disp16[reg1]
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[19:16] == 4'b1101)begin           // 00000111100RRRRR wwwwwddddddd1101 DDDDDDDDDDDDDDDD
        // ST.B reg3, disp23[reg1]
    end else if(decord_instruction[10:5] == 6'b111011 && decord_instruction[0] == 1'd0)begin                        // rrrrr111011RRRRR ddddddddddddddd0
        // ST.H reg2, disp16[reg1]
    end else if(decord_instruction[15:5] == 11'b00000111101 && decord_instruction[20:16] == 5'b01101)begin          // 00000111101RRRRR wwwwwdddddd01101 DDDDDDDDDDDDDDDD
        // ST.H reg3, disp23[reg1]
    end else if(decord_instruction[10:5] == 6'b111011 && decord_instruction[16] == 1'b1)begin                       // rrrrr111011RRRRR ddddddddddddddd1
        // ST.W reg2, disp16[reg1]
    end else if(decord_instruction[15:5] == 11'b00000111100 && decord_instruction[20:16] == 5'b01111)begin          // 00000111100RRRRR wwwwwdddddd01111 DDDDDDDDDDDDDDDD
        // ST.W reg3, disp23[reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000001000000)begin    // rrrrr111111RRRRR 0000000001000000
        // STSR regID, reg2
    end else if(decord_instruction[10:5] == 6'b001101)begin                                                         // rrrrr001101RRRRR
        // SUB reg1, reg2
        reg1_o <= ~(GR[decord_instruction[4:0]]) + 32'b1;         // invert rg1 value ★反転するときオーバーフローしたら？
        reg2_o <= GR[decord_instruction[15:11]];       // reg2 value
        destination_o <= decord_instruction[15:11];    // reg2 number
        circuit_sel_o <= 5'b00000;

    end else if(decord_instruction[10:5] == 6'b001100)begin                                                         // rrrrr001100RRRRR
        // SUBR reg1, reg2
        reg1_o <= GR[decord_instruction[4:0]];                    // rg1 value
        reg2_o <= ~(GR[decord_instruction[15:11]]) + 32'b1;       // invert reg2 value ★反転するときオーバーフローしたら？
        destination_o <= decord_instruction[15:11];               // reg2 number
        circuit_sel_o <= 5'b00000;

    end else if(decord_instruction[15:5] == 11'b00000000010)begin                                                   // 00000000010RRRRR
        // SWITCH reg1     (RRRRR != 00000)
    end else if(decord_instruction[15:5] == 11'b00000000101)begin                                                   // 00000000101RRRRR
        // SXB reg1
    end else if(decord_instruction[15:5] == 11'b00000000111)begin                                                   // 00000000111RRRRR
        // SXH reg1
    end else if(decord_instruction[15:0] == 16'b0000000000011101)begin                                              // 0000000000011101
        // SYNCE
    end else if(decord_instruction[15:0] == 16'b0000000000011110)begin                                              // 0000000000011110
        // SYNCM
    end else if(decord_instruction[15:0] == 16'b0000000000011111)begin                                              // 0000000000011111
        // SYNCP
    end else if(decord_instruction[15:5] == 11'b11010111111 && decord_instruction[31:30] == 2'b00 && decord_instruction[26:16] == 11'b00101100000)begin    // 11010111111vvvvv 00VVV00101100000
        // SYSCALL vector8
    end else if(decord_instruction[15:5] == 11'b00000111111 && decord_instruction[31:16] == 16'b0000000100000000)begin    // 00000111111vvvvv 0000000100000000
        // TRAP vector5
    end else if(decord_instruction[10:5] == 6'b001011)begin                                                         // rrrrr001011RRRRR
        // TST reg1, reg2
    end else if(decord_instruction[15:14] == 2'b11 && decord_instruction[10:5] == 111110)begin                      // 11bbb111110RRRRR dddddddddddddddd
        // TST1 bit#3, disp16[reg1]
    end else if(decord_instruction[10:5] == 6'b111111 && decord_instruction[31:16] == 16'b0000000011100110)begin    // rrrrr111111RRRRR 0000000011100110
        // TST1 reg2, [reg1]
    end else if(decord_instruction[10:5] == 6'b001001)begin                                                         // rrrrr001001RRRRR
        // XOR reg1, reg2
    end else if(decord_instruction[10:5] == 6'b110101)begin                                                         // rrrrr110101RRRRR iiiiiiiiiiiiiiii
        // XORI imm16, reg1, reg2
    end else if(decord_instruction[15:5] == 11'b00000000100)begin                                                   // 00000000100RRRRR
        // ZXB reg1
    end else if(decord_instruction[15:5] == 11'b00000000110)begin                                                   // 00000000110RRRRR
        // ZXH reg1
    end
end
endmodule