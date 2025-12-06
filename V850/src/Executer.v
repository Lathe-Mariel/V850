module Executer(
input logic clk,

input logic[4:0] destination_i,    // number of destination register
input logic[31:0] reg1_i,
input logic[31:0] reg2_i,
input logic[4:0] imm5_i,
output logic[31:0] GR[31:0],
output logic PSW[31:0]
);

//logic[31:0] GR[31:0];    //general registers. r[1] is r1.
//logic[31:0] PSW;    // program status word (18:NPV, 17:DMP, 16:IMP, 7:NP, 6:EP, 5:ID, 4:SAT, 3:CY, 2:OV, 1:S, 0:Z)

always_ff @(posedge clk)begin
        {PSW[3], GR[destination_i]} <= {1'b0, reg2_i} + {1'b0, reg1_i};
        PSW[2] <= (reg1_i[31] & reg2_i[31] & !(reg1_i[31] & reg2_i[31])) | (!reg1_i[31] & !reg2_i[31] & (reg1_i[31] & reg2_i[31]));  // OF = A・B・_C + _A・_B・C
        PSW[1] <= reg2_i + reg1_i >> 31;
        PSW[0] <= (reg2_i + reg1_i)==0?1:0;    // zero flag

end

endmodule