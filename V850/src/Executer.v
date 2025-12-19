module Executer(
input logic clk,

input logic[4:0] destination_i,    // number of destination register
input logic[4:0] destination2_i,   // number of destination2 register
input logic[31:0] reg1_i,
input logic[31:0] reg2_i,
input logic[31:0] reg3_i,          // ★is this signal always 5 bits
input logic increment_bit_i,
//input logic[4:0] imm5_i,
output logic[31:0] GR[31:0],
output logic[31:0] PSW,
output logic[31:0] PC_o,
input logic[9:0] circuit_sel_i    //circuit select(5bits temporarily)
);

//logic[31:0] GR[31:0];    //general registers. r[1] is r1.
//logic[31:0] PSW;    // program status word (18:NPV, 17:DMP, 16:IMP, 7:NP, 6:EP, 5:ID, 4:SAT, 3:CY, 2:OV, 1:S, 0:Z)


logic[4:0] destination;
logic[4:0] destination2;   // number of destination2 register
logic[31:0] reg1;
logic[31:0] reg2;
logic[31:0] reg3;          // ★is this signal always 5 bits
logic increment_bit;
logic[9:0] circuit_sel;    //circuit select(5bits temporarily)

//output logic[31:0] GR[31:0],
//output logic[31:0] PSW,
//output logic[31:0] PC,



always_ff @(posedge clk)begin
    destination <= destination_i;
    destination2 <= destination2_i;
    reg1 <= reg1_i;
    reg2 <= reg2_i;
    reg3 <= reg3_i;
    increment_bit <= increment_bit_i;
//    .GR(GR),
//    .PSW(PSW),
    circuit_sel <= circuit_sel_i;
//    .PC(PC)

end



always_ff @(posedge clk)begin
    if(circuit_sel[5] == 1)begin                               // ADD,ADDI,ADF,Bcond,CMOV
        if(circuit_sel[0] == 1)begin    // 10'b0000100001
          GR[destination] <= reg1 + reg2;                  // PSW will not changed
        end else begin    // 10'b0000100000
          if(destination == 5'b00000)begin
//★Bcond            PC <= reg2 + reg1;

          end else begin
            {PSW[3], GR[destination]} <= {1'b0, reg2} + {1'b0, reg1} + increment_bit;
          end
          if(circuit_sel[1] == 1)begin
            PSW[2] <= 1'b0;                                      // OV flag <- 0
          end else begin
            PSW[2] <= (reg1[31] & reg2[31] & !((reg1 + reg2 + increment_bit) >> 31)) | (!reg1[31] & !reg2[31] & ((reg1 + reg2 + increment_bit) >> 31));  // OF = A・B・_C + _A・_B・C
          end
          PSW[1] <= (reg2 + reg1 + increment_bit) >> 31;
          PSW[0] <= (reg2 + reg1 + increment_bit)==0?1:0;  // zero flag
        end
    end else if(circuit_sel == 10'b00000)begin                 // CMP,SUB
        PSW[3] <= ({1'b0, reg2} + {1'b0, reg1}) >> 32;    // borrow flag(carry flag)
        PSW[2] <= (reg1[31] & reg2[31] & !((reg1 + reg2) >> 31)) | (!reg1[31] & !reg2[31] & ((reg1 + reg2) >> 31));  // OF = A・B・_C + _A・_B・C
        PSW[1] <= (reg2 + reg1 + increment_bit) >> 31;
        PSW[0] <= (reg2 + reg1 + increment_bit)==0?1:0;    // zero flag
    end else if(circuit_sel == 10'b00010)begin                 // AND,ANDI
        GR[destination] <= reg2 & reg1;
        PSW[2] <= 1'b0;                                          // OV flag
        PSW[1] <= (reg2 & reg1) >> 31;
        PSW[0] <= (reg2 + reg1)==0?1:0;                      // zero flag
    end else if(circuit_sel == 10'b00011)begin                 // OR
        GR[destination] <= reg2 | reg1;
        PSW[2] <= 1'b0;                                          // OV flag
        PSW[1] <= (reg2 & reg1) >> 31;
        PSW[0] <= (reg2 + reg1)==0?1:0;                      // zero flag
    end else if(circuit_sel[4:1] == 4'b0011)begin              // BSH,BSW
        GR[destination] <= reg2;
        PSW[2] <= 1'b0;
        PSW[1] <= reg2[31];
        if(circuit_sel[0])begin
            PSW[3] <= (reg2[31:24]==8'b0 || reg2[23:16]==8'b0 || reg2[15:8]==8'b0 || reg2[7:0]==8'b0);
            PSW[0] <= (reg2==32'b0);
        end else begin
            PSW[3] <= (reg2[15:8]==8'b0 || reg2[7:0]==8'b0);
            PSW[0] <= (reg2[15:0]==16'b0);
        end

    end else if(circuit_sel == 10'b01000)begin                  // DIV
        GR[destination] <= $signed(reg2) / $signed(reg1);
        GR[reg3] <= $signed(reg2) % $signed(reg1);                                                        // reg3_i is register number
        PSW[2] <= ((reg2 == 32'h80000000 && reg1 == 32'hFFFFFFFF) || reg1 == 0)?1:0;    // OV flag
        PSW[1] <= ($signed(reg2) / $signed(reg1)) >> 31;                                                    // sign flag
        PSW[0] <= ($signed(reg2) / $signed(reg1)) == 1'b0;                                                  // zero flag

    end else if(circuit_sel == 10'b10000)begin                  // HSH,HSW
        GR[destination] <= reg2;
        if(circuit_sel[0] ==1'b1)begin                          // HSW
          PSW[3] <= (reg2[15:0] == 0 || reg2[31:16] == 0)?1:0;
          PSW[0] <= reg2 == 0?1:0;
        end else begin                                            // HSH
          PSW[3] <= reg2[15:0] == 0?1:0;
          PSW[0] <= reg2[15:0] == 0?1:0;
        end
        PSW[2] <= 1'b0;
        PSW[1] <= reg2[31];

    end else if(circuit_sel == 10'b00_0100_0000)begin            // SAR
//★シフター回路構成検討
        //GR[destination] <= { {reg1[4:0]{reg2[31]}}, reg2 >> reg1[4:0]};    // arithmetic right shift
        PSW[3] <= reg1[4:0] == 0?0:
                  reg2[reg1 - 5'b1];
        PSW[2] <= 1'b0;                                            // OV <- 0
        PSW[1] <= reg2[31];                                      // S
        //PSW[0] <= ({{reg1[4:0]{reg2[31]}}, reg2 >> reg1[4:0]} == 0)?1:0;     // Z

    end else if(circuit_sel == 10'b00_1000_0000)begin            // MUL
        {GR[destination2], GR[destination]} <= $signed(reg2) * $signed(reg1);
    end
end


endmodule