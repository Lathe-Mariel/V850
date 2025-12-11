module Executer(
input logic clk,

input logic[4:0] destination_i,    // number of destination register
input logic[31:0] reg1_i,
input logic[31:0] reg2_i,
input logic increment_bit_i,
//input logic[4:0] imm5_i,
output logic[31:0] GR[31:0],
output logic[31:0] PSW,
output logic[31:0] PC,
input logic[4:0] circuit_sel_i    //circuit select(5bits temporarily)
);

//logic[31:0] GR[31:0];    //general registers. r[1] is r1.
//logic[31:0] PSW;    // program status word (18:NPV, 17:DMP, 16:IMP, 7:NP, 6:EP, 5:ID, 4:SAT, 3:CY, 2:OV, 1:S, 0:Z)

always_ff @(posedge clk)begin
    if(circuit_sel_i == 5'b00001)begin                           // ADD,ADDI,ADF,Bcond
        if(destination_i == 5'b00000)begin
            PC <= reg2_i + reg1_i;
        end else begin
            {PSW[3], GR[destination_i]} <= {1'b0, reg2_i} + {1'b0, reg1_i} + increment_bit_i;
        end
        PSW[2] <= (reg1_i[31] & reg2_i[31] & !((reg1_i + reg2_i + increment_bit_i) >> 31)) | (!reg1_i[31] & !reg2_i[31] & ((reg1_i + reg2_i + increment_bit_i) >> 31));  // OF = A・B・_C + _A・_B・C
        PSW[1] <= (reg2_i + reg1_i + increment_bit_i) >> 31;
        PSW[0] <= (reg2_i + reg1_i + increment_bit_i)==0?1:0;    // zero flag
    end else if(circuit_sel_i == 5'b00000)begin                  // CMP,SUB
        GR[destination_i] <= {1'b0, reg2_i} + {1'b0, reg1_i};
        PSW[3] <= ~(({1'b0, reg2_i} + {1'b0, reg1_i}) >> 31);    // borrow flag(carry flag)
        PSW[2] <= (reg1_i[31] & reg2_i[31] & !((reg1_i + reg2_i) >> 31)) | (!reg1_i[31] & !reg2_i[31] & ((reg1_i + reg2_i) >> 31));  // OF = A・B・_C + _A・_B・C
        PSW[1] <= (reg2_i + reg1_i + increment_bit_i) >> 31;
        PSW[0] <= (reg2_i + reg1_i + increment_bit_i)==0?1:0;    // zero flag
    end else if(circuit_sel_i == 5'b00010)begin                  // AND,ANDI
        GR[destination_i] <= reg2_i & reg1_i;
        PSW[2] <= 1'b0;                                          // OV flag
        PSW[1] <= (reg2_i & reg1_i) >> 31;
        PSW[0] <= (reg2_i + reg1_i)==0?1:0;                      // zero flag
    end else if(circuit_sel_i == 5'b00011)begin                  // OR
        GR[destination_i] <= reg2_i | reg1_i;
        PSW[2] <= 1'b0;                                          // OV flag
        PSW[1] <= (reg2_i & reg1_i) >> 31;
        PSW[0] <= (reg2_i + reg1_i)==0?1:0;                      // zero flag
    end else if(circuit_sel_i[4:1] == 4'b0011)begin              // BSH,BSW
        GR[destination_i] <= reg2_i;
        PSW[2] <= 1'b0;
        PSW[1] <= reg2_i[31];
        if(circuit_sel_i[0])begin
            PSW[3] <= (reg2_i[31:24]==8'b0 || reg2_i[23:16]==8'b0 || reg2_i[15:8]==8'b0 || reg2_i[7:0]==8'b0);
            PSW[0] <= (reg2_i==32'b0);
        end else begin
            PSW[3] <= (reg2_i[15:8]==8'b0 || reg2_i[7:0]==8'b0);
            PSW[0] <= (reg2_i[15:0]==16'b0);
        end
    end
end


endmodule