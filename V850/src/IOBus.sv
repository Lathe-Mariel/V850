module IOBus(
input logic clk,
inout logic[63:0] inst_data,
input logic[24:0] memory_address,
input logic n_rst,
input logic write_enable
);

logic [25:0] current_address;
logic [7:0] test_memory[64];    // for test_memory


assign current_address = {memory_address, 1'b0};
assign inst_data = {test_memory[current_address+7], test_memory[current_address+6], test_memory[current_address+5], test_memory[current_address+4], test_memory[current_address+3], test_memory[current_address+2], test_memory[current_address+1], test_memory[current_address]};


always @(posedge clk)begin

    if(write_enable)begin
        {test_memory[memory_address+7],test_memory[memory_address+6],test_memory[memory_address+5],test_memory[memory_address+4],test_memory[memory_address+3],test_memory[memory_address+2],test_memory[memory_address+1],test_memory[memory_address]} <= inst_data;
    end else begin
        current_address = {memory_address, 1'b0};
        inst_data <= {test_memory[current_address+7], test_memory[current_address+6], test_memory[current_address+5], test_memory[current_address+4], test_memory[current_address+3], test_memory[current_address+2], test_memory[current_address+1], test_memory[current_address]};
    end
end


endmodule