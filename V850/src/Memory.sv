module Memory(
input logic clk,
input logic[31:0] destination_i,
input logic[28:0] memory_address_i,
input logic[9:0] circuit_sel_i,
output logic[31:0] wb_data_o,
output logic[31:0] destination_o,

input logic         ddr_cmd_rdy_i,               // DDR3 command recieve ready
input logic[31:0]   ddr_read_data_o,             // read data output
input logic         ddr_read_data_valid_i,
input logic         ddr_read_data_end_i,
output logic         ddr_enable_o,                // -> DDR3 IP
output logic        ddr_cmd_o
);

logic[31:0] test_mem;

always_ff @(posedge clk)begin
    destination_o <= destination_i;

    if(circuit_sel_i[1:0] == 2'b00)begin  //LD
        //test_mem = 8'b1111_1111;
        ddr_cmd_o <= 1'b0;
        ddr_enable_o <= 1'b1;
        if(ddr_read_data_valid_i)begin
            wb_data_o <= {{24{ddr_read_data_o[7]}}, ddr_read_data_o[7:0]};    // 8bit with sign extended
        end
    end else begin
        ddr_enable_o <= 1'b0;
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