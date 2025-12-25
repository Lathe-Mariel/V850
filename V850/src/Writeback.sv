module Writeback(
input logic clk,
input logic[31:0] result_i,
input logic[31:0] result2_i,
input logic[4:0] destination_i,
input logic[4:0] destination2_i,
input logic[31:0] PSW_i,
output logic[31:0] GR[32],
output logic[31:0] PSW_o
);

//logic[31:0] result;
//logic[31:0] result2;
//logic[4:0] destination;
//logic[4:0] destination2;

always_ff @(posedge clk)begin
//    result <= result_i;
//    result2 <= result2_i;
//    destination <= destination_i;
//    destination <= destination2_i;
    PSW_o <= PSW_i;
    GR[destination_i] <= result_i;
    GR[destination2_i] <= result2_i;
end

endmodule