module Memory(
input logic clk,
input logic[4:0] destination_i,
input logic[28:0] memory_address_i,
output logic[28:0] memory_address_o,
input logic[9:0] circuit_sel_i,
output logic[31:0] wb_data_o,
output logic[4:0] destination_o,

input logic         memory_cmd_rdy_i,            // DDR3 command recieve ready
input logic[31:0]   memory_read_data_i,
input logic         memory_read_data_valid_i,
input logic         memory_read_data_end_i,
output logic        memory_enable_o,                // -> DDR3 IP
output logic        memory_cmd_o,

input logic[31:0]   store_data_i,                  // ST data
output logic        memory_write_enable_o,         // -> DDR3 IP
input logic         memory_write_rdy_i,            // DDR3 IP ->
output logic[31:0]  memory_write_data_o,
output logic        memory_write_data_end_o

);

//logic[31:0] test_mem;

always_ff @(posedge clk)begin
    memory_address_o <= memory_address_i;

    if(circuit_sel_i[1:0] == 2'b00)begin  //LD
        //test_mem = 8'b1111_1111;
        destination_o <= destination_i;
        memory_cmd_o <= 1'b0;
        memory_enable_o <= 1'b1;
        if(memory_cmd_rdy_i && memory_read_data_valid_i)begin
            wb_data_o <= {{24{memory_read_data_i[7]}}, memory_read_data_i[7:0]};    // 8bit with sign extended
        end
        
    end else if(circuit_sel_i[1:0] == 2'b01)begin  // ST
        destination_o <= 0;
        memory_cmd_o <= 1'b1;
        memory_enable_o <= 1'b1;
        memory_write_enable_o <= 1'b1;
        if(memory_cmd_rdy_i && memory_write_rdy_i)begin
            memory_write_data_o <= store_data_i;
        end

    end
end


/* 読み出しデータ FF 2段で受ける */
/*
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            app_rd_data_valid_r <= 1'b0;
            app_rd_data_r <= 'd0;
            app_rd_data_valid_rr <= 1'b0;
            app_rd_data_rr <= 'd0;
        end
        else begin
            app_rd_data_valid_r <= app_rd_data_valid;
            app_rd_data_r <= app_rd_data;
            app_rd_data_valid_rr <= app_rd_data_valid_r;
            app_rd_data_rr <= app_rd_data_r;
        end
    end
*/
endmodule