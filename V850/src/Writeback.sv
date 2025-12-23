module Writeback(
input logic clk,
input logic[31:0] result_i,
input logic[31:0] result2_i,
input logic[4:0] destination_i,
input logic[4:0] destination2_i,
output logic[31:0] GR[32]
);

logic[31:0] result;
logic[31:0] result2;
logic[4:0] destination;
logic[4:0] destination2;

always_ff @(posedge clk)begin
    result <= result_i;
    result2 <= result2_i;
    destination <= destination_i;
    destination <= destination2_i;

    GR[destination_i] <= result;
    GR[destination2_i] <= result2;
end

endmodule