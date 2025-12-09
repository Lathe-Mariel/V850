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


// CPU Function group system registers
logic[31:0] EIPC;   // status save register when EI level exception received
logic[31:0] EIPSW;  // status save register when EI level exception received
logic[31:0] FEPC;   // status save register when FE level exception received
logic[31:0] FEPSW;  // status save register when FE level exception received
logic[31:0] ECR;    // factor of exception

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



logic[31:0] reg1, reg2;
//logic imm5;
logic[31:0] PSW;
logic[4:0] destination;
logic increment_bit;

logic[31:0] GR[31:0];

Decorder inst_Decorder(
    .reg1_o(reg1),
    .reg2_o(reg2),
    .increment_bit_o(increment_bit),
    .destination_o(destination),
    .clk(clk),
    .PC(PC),
    .GR(GR),
    .PSW(PSW)
);

Executer inst_Executer(
    .clk(clk),
    .destination_i(destination),
    .reg1_i(reg1),
    .reg2_i(reg2),
    .increment_bit_i(increment_bit),
    .GR(GR),
    .PSW(PSW)
);


endmodule

`default_nettype wire
