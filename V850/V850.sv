`default_nettype none

module V850 (
input wire clk
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
    end
end

endmodule

`default_nettype wire