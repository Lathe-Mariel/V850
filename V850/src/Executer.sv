module Executer(
input logic clk,

input logic[4:0] destination_EX_i,    // number of destination register
input logic[4:0] destination2_EX_i,   // number of destination2 register
input logic[31:0] reg1_i,
input logic[31:0] reg2_i,
input logic[31:0] reg3_i,          // ★is this signal always 5 bits
input logic increment_bit_i,
//input logic[4:0] imm5_i,
output logic[31:0] result_o,
output logic[31:0] result2_o,
output logic[4:0] destination_o,
output logic[4:0] destination2_o,
output logic[31:0] PSW_o,
output logic[31:0] PC_o,
input logic[9:0] circuit_sel_i    //circuit select(5bits temporarily)
);

//logic[31:0] GR[31:0];    //general registers. r[1] is r1.
//logic[31:0] PSW_o;    // program status word (18:NPV, 17:DMP, 16:IMP, 7:NP, 6:EP, 5:ID, 4:SAT, 3:CY, 2:OV, 1:S, 0:Z)


//logic[4:0] destination;
//logic[4:0] destination2;   // number of destination2 register
//logic[31:0] reg1;
//logic[31:0] reg2;
//logic[31:0] reg3;          // ★is this signal always 5 bits
//logic increment_bit;
//logic[9:0] circuit_sel;    //circuit select(5bits temporarily)

//output logic[31:0] GR[31:0],
//output logic[31:0] PSW_o,
//output logic[31:0] PC,



always_ff @(posedge clk)begin
//    destination <= destination_EX_i;
//    destination2 <= destination2_EX_i;
//    reg1 <= reg1_i;
//    reg2 <= reg2_i;
//    reg3 <= reg3_i;
//    increment_bit <= increment_bit_i;
//    .GR(GR),
//    .PSW_o(PSW_o),
//    circuit_sel <= circuit_sel_i;
//    .PC(PC)

end



always_ff @(posedge clk)begin
    if(circuit_sel_i[5] == 1)begin                               // ADD,ADDI,ADF,Bcond,CMOV,MOV
        if(circuit_sel_i[0] == 1)begin    // 10'b0000100001 MOV
          result_o <= reg1_i + reg2_i;                  // PSW_o will not changed
        destination_o <= destination_EX_i;
        destination2_o <= 'b0;
        end else begin    // 10'b0000100000
          if(destination_EX_i == 5'b00000)begin
//★Bcond            PC <= reg2_i + reg1_i;

          end else begin
            {PSW_o[3], result_o} <= {1'b0, reg2_i} + {1'b0, reg1_i} + increment_bit_i;
          end
          if(circuit_sel_i[1] == 1)begin
            PSW_o[2] <= 1'b0;                                      // OV flag <- 0
          end else begin
            PSW_o[2] <= (reg1_i[31] & reg2_i[31] & !((reg1_i + reg2_i + increment_bit_i) >> 31)) | (!reg1_i[31] & !reg2_i[31] & ((reg1_i + reg2_i + increment_bit_i) >> 31));  // OF = A・B・_C + _A・_B・C
          end
          PSW_o[1] <= (reg2_i + reg1_i + increment_bit_i) >> 31;
          PSW_o[0] <= (reg2_i + reg1_i + increment_bit_i)==0?1:0;  // zero flag
        end
    end else if(circuit_sel_i == 10'b00000)begin                 // CMP,SUB
        PSW_o[3] <= ({1'b0, reg2_i} + {1'b0, reg1_i}) >> 32;    // borrow flag(carry flag)
        PSW_o[2] <= (reg1_i[31] & reg2_i[31] & !((reg1_i + reg2_i) >> 31)) | (!reg1_i[31] & !reg2_i[31] & ((reg1_i + reg2_i) >> 31));  // OF = A・B・_C + _A・_B・C
        PSW_o[1] <= (reg2_i + reg1_i + increment_bit_i) >> 31;
        PSW_o[0] <= (reg2_i + reg1_i + increment_bit_i)==0?1:0;    // zero flag
    end else if(circuit_sel_i == 10'b00010)begin                 // AND,ANDI
        result_o <= reg2_i & reg1_i;
        destination_o <= destination_EX_i;
        destination2_o <= 'b0;
        PSW_o[2] <= 1'b0;                                          // OV flag
        PSW_o[1] <= (reg2_i & reg1_i) >> 31;
        PSW_o[0] <= (reg2_i + reg1_i)==0?1:0;                      // zero flag
    end else if(circuit_sel_i == 10'b00011)begin                 // OR
        result_o <= reg2_i | reg1_i;
        destination_o <= destination_EX_i;
        destination2_o <= 'b0;
        PSW_o[2] <= 1'b0;                                          // OV flag
        PSW_o[1] <= (reg2_i & reg1_i) >> 31;
        PSW_o[0] <= (reg2_i + reg1_i)==0?1:0;                      // zero flag
    end else if(circuit_sel_i[4:1] == 4'b0011)begin              // BSH,BSW
        result_o <= reg2_i;
        destination_o <= destination_EX_i;
        destination2_o <= 'b0;
        PSW_o[2] <= 1'b0;
        PSW_o[1] <= reg2_i[31];
        if(circuit_sel_i[0])begin
            PSW_o[3] <= (reg2_i[31:24]==8'b0 || reg2_i[23:16]==8'b0 || reg2_i[15:8]==8'b0 || reg2_i[7:0]==8'b0);
            PSW_o[0] <= (reg2_i==32'b0);
        end else begin
            PSW_o[3] <= (reg2_i[15:8]==8'b0 || reg2_i[7:0]==8'b0);
            PSW_o[0] <= (reg2_i[15:0]==16'b0);
        end

    end else if(circuit_sel_i == 10'b01000)begin                  // DIV
        result_o <= $signed(reg2_i) / $signed(reg1_i);
        result2_o <= $signed(reg2_i) % $signed(reg1_i);
        destination_o <= destination_EX_i;
        destination2_o <= reg3_i;                                                         // reg3_i is register number
        PSW_o[2] <= ((reg2_i == 32'h80000000 && reg1_i == 32'hFFFFFFFF) || reg1_i == 0)?1:0;    // OV flag
        PSW_o[1] <= ($signed(reg2_i) / $signed(reg1_i)) >> 31;                                                    // sign flag
        PSW_o[0] <= ($signed(reg2_i) / $signed(reg1_i)) == 1'b0;                                                  // zero flag

    end else if(circuit_sel_i == 10'b10000)begin                  // HSH,HSW
        result_o <= reg2_i;
        destination_o <= destination_EX_i;
        destination2_o <= 'b0;
        if(circuit_sel_i[0] ==1'b1)begin                          // HSW
          PSW_o[3] <= (reg2_i[15:0] == 0 || reg2_i[31:16] == 0)?1:0;
          PSW_o[0] <= reg2_i == 0?1:0;
        end else begin                                            // HSH
          PSW_o[3] <= reg2_i[15:0] == 0?1:0;
          PSW_o[0] <= reg2_i[15:0] == 0?1:0;
        end
        PSW_o[2] <= 1'b0;
        PSW_o[1] <= reg2_i[31];

    end else if(circuit_sel_i == 10'b00_0100_0000)begin            // SAR
//★シフター回路構成検討
        //GR[destination] <= { {reg1_i[4:0]{reg2_i[31]}}, reg2_i >> reg1[4:0]};    // arithmetic right shift
        PSW_o[3] <= reg1_i[4:0] == 0?0:
                  reg2_i[reg1_i - 5'b1];
        PSW_o[2] <= 1'b0;                                            // OV <- 0
        PSW_o[1] <= reg2_i[31];                                      // S
        //PSW_o[0] <= ({{reg1_i[4:0]{reg2_i[31]}}, reg2_i >> reg1_i[4:0]} == 0)?1:0;     // Z

    end else if(circuit_sel_i == 10'b00_1000_0000)begin            // MUL, MULH
        {result2_o, result_o} <= $signed(reg2_i) * $signed(reg1_i);
        destination_o <= destination_EX_i;
        destination2_o <= destination2_EX_i;
    end
end


endmodule