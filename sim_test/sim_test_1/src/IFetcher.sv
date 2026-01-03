module IFetcher(
//input logic rst_n,
//input logic clk,
output logic[24:0] PC_o
);

logic rst_n;
logic clk;
logic[2:0] reset_counter;
logic test;

always_ff @(posedge clk)begin
    if(reset_counter < 3'd4)begin
        reset_counter <= reset_counter + 3'd1;
        PC_o <= 25'd0;
        test <= 1'b0;
    end else begin
        PC_o <= PC_o + 25'd1;
        test <= 1'b1;
    end
end

always @(posedge clk)begin
    if(~rst_n)begin
        reset_counter <= 0;
        PC_o <= 25'd0;
        test <= 1'b0;
    end
end

initial begin

rst_n = 1'b0;
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
rst_n = 1'b1; #5;
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