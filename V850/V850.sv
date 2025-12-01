`default_nettype none

module top (

);

logic[0:31] PC;    // [31:26] is automatically filled by sign extension. value of PC[0] is always 0.
//logic[31:0][0] r0
logic[0:31] r[31:0];    //general registers. r[1] is r1.

// CPU Function group system registers
logic[0:31] EIPC;   // status save register when EI level exception received
logic[0:31] EIPSW;  // status save register when EI level exception received
logic[0:31] FEPC;   // status save register when FE level exception received
logic[0:31] FEPSW;  // status save register when FE level exception received
logic[0:31] ECR;    // factor of exception
logic[0:31] PSW;    // program status word
logic[0:31] SCCFG;  // action setting for SYSCALL
logic[0:31] SCBP;   //SYSCALL base pointer
logic[0:31] EIIC;   // factor of EI level exception
logic[0:31] FEIC;   //factor of FE level exception
logic[0:31] DBIC;   //factor of DB level exception
logic[0:31] CTPC;   // status save register when execute CALLT
logic[0:31] CTPSW;  //status save register when execute CALLT
logic[0:31] DBPC;   // status save register when DB level exception received
logic[0:31] DBPSW;  // status save register when DB level exception received
logic[0:31] CTBP;   //CALLT base pointer
logic[0:31] debug_register;  // debug function registers
logic[0:31] EIWR;   // working register for EI level exception
logic[0:31] FEWR;   // working register for FE level exception
logic[0:31] DBWR;   // working register for DB level exception
logic[0:31] BSEL;   // selection of register bank


// decorder
always @(posedge clk)begin
    
end

endmodule

`default_nettype wire