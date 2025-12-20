module tb_Fetcher();

logic clk;
logic[63:0] tb_instruction;

IFetcher inst_IFetcher(
  .clk(clk),
  .PC_i(),
  .instruction_o(tb_instruction),
  .PC_o()
);

initial begin

end

    always begin
        clk <= 1'b1; #10;
        clk <= 1'b0; #10;
    end

endmodule