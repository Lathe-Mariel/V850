module tb_Fetcher();

logic clk;
logic[24:0] PC;
logic reset;

IFetcher inst_IFetcher(
  .clk(clk),
  .rst_n(~reset),
  .PC_o(PC)
);

initial begin

reset = 1'b1;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #5;
reset = 1'b0; #5;
clk = 1'b1; #10
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;

clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;
clk = 1'b0; #10;
clk = 1'b1; #10;

$finish;

end


endmodule