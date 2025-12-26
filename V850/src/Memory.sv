module Memory(
input logic clk,
input logic[31:0] destination_i,
input logic[31:0] memory_address_i,
input logic[9:0] circuit_sel_i,
output logic[31:0] wb_data_o,
output logic[31:0] destination_o
);

logic[31:0] test_mem;

always_ff @(posedge clk)begin
    destination_o <= destination_i;

    if(circuit_sel_i[1:0] == 2'b00)begin
        test_mem = 8'b1111_1111;
        wb_data_o <= {{24{test_mem[7]}}, test_mem[7:0]};    // 8bit with sign extended
    end
end

endmodule