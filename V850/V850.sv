`default_nettype none

module V850 (
input wire clk,
input wire sw0,
input wire sw1,
input wire rst_n,
output wire fan
);


//logic[31:0][0] r0
logic[31:0] GR[31:0];

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



//logic imm5;

logic[31:0] PSW;

logic[31:0] GR[31:0];

//assign GR[0] = 32'b0;

logic[63:0] instruction_ifid;    //IF ID
logic[24:0] PC_ifid;    // virtually [25:1] ([31:26] is automatically filled by sign extension. value of PC[0] is always 0)

IFetcher inst_IFetcher(
    .clk(clk),
    .PC_i(),        // when branch??
    .instruction_o(instruction_ifid),
    .PC_o(PC_ifid)  //IF -> ID
);

logic[31:0] reg1_idex, reg2_idex;    // ID EX
logic[31:0] reg3_idex;
logic[4:0] destination_idex;    // GR[0] is always 0, and then destination is set up 0, PC is pointed as a destination register.
logic[4:0] destination2_idex;
logic increment_bit_idex;
logic[9:0] circuit_sel_idex;

Decorder inst_Decorder(
    .instruction_i(instruction_ifid),
    .reg1_o(reg1_idex),
    .reg2_o(reg2_idex),
    .reg3_o(reg3_idex),
    .increment_bit_o(increment_bit_idex),
    .destination_o(destination_idex),
    .destination2_o(destination2_idex),
    .clk(clk),
    .PC_i(PC_ifid),
    .GR(GR),
    .PSW(PSW),
    .circuit_sel_o(circuit_sel_idex)
);

logic[24:0] PC_exmem;           // EX -> MEM
logic[31:0] result_exmem;
logic[31:0] result2_exmem;
logic[4:0] destination_exwb;    // EX -> MEM & WB
logic[4:0] destination2_exwb;   // EX -> MEM & WB

Executer inst_Executer(
    .clk(clk),
    .destination_i(destination_idex),
    .destination2_i(destination2_idex),
    .reg1_i(reg1_idex),
    .reg2_i(reg2_idex),
    .reg3_i(reg3_idex),
    .increment_bit_i(increment_bit_idex),
    .result_o(result_exmem),
    .result2_o(result2_exmem),
    .destination_o(destination_exwb),
    .destination2_o(destination2_exwb),
    .PSW(PSW),
    .circuit_sel_i(circuit_sel_idex),
    .PC_o(PC_exmem)
);


endmodule

`default_nettype wire
