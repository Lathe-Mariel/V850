module Memory(
input logic clk,
input logic[31:0] destination_i,
input logic[31:0] memory_address_i,
output logic[31:0] wb_data_o,
output logic[31:0] destination_o 
);

always_ff @(posedge clk)begin
    destination_o <= destination_i;

    wb_data_o <= 32'h1234_5678;

end

endmodule