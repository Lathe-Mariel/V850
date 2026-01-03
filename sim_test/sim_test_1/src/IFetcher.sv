module IFetcher(
input logic rst_n,
input logic clk,
output logic[24:0] PC_o
);

always_ff @(posedge clk)begin
    if(~rst_n)begin
        PC_o <= 25'd0;
    end else begin
        PC_o <= PC_o + 25'd1;
    end
end

endmodule