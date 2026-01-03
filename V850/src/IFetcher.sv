module IFetcher(
input logic rst_n,
input logic clk,
input logic[24:0] PC_i,
input logic[63:0] mem_i,
output logic[63:0] instruction_o,
output logic[24:0] PC_o,
output logic[2:0] next_fetch    // 16bit or 32bit or 48bit or 64bit
//output logic[24:0] fetch_address
);


logic[63:0] prefetch_buffer;    //

logic reg2_en;       // reg2 number is not 0

logic test1;
logic[1:0] test2;

assign reg2_en = |{prefetch_buffer[15:11]};    // when OP2(reg2 number) is 0

always_ff @(posedge clk)begin
    if(~rst_n)begin
        PC_o <= 25'd0;
        next_fetch = 0;
        instruction_o <= 0;
        prefetch_buffer <= mem_i;

        test1 <= 1'b1;
        test2 <= 0;
    end else begin
//        PC_o <= PC_o + next_fetch;
        if(prefetch_buffer[10:9] == 2'b11)begin
            if(reg2_en && (prefetch_buffer[8] + prefetch_buffer[7] + prefetch_buffer[6]) == 1'b0)begin
                 // 32bit inst
                instruction_o <= prefetch_buffer[31:0];
                PC_o <= PC_o + 25'd2;
                next_fetch = 3'd2;
                prefetch_buffer <= mem_i;

            end else begin
                next_fetch = 3'd3;
                // ★
                // 48 bit
                PC_o <= PC_o + 3'd3;

                //  64 bit
                PC_o <= PC_o + 3'd4;
            end

        end else begin
            if(!reg2_en && prefetch_buffer[7] && prefetch_buffer[9])begin
                // JR, JARL(32bit)
                instruction_o <= prefetch_buffer[31:0];
                PC_o <= PC_o + 25'd2;
                next_fetch = 3'd2;
                prefetch_buffer <= mem_i;

            end else begin
                // 16bit inst
                instruction_o <= prefetch_buffer[15:0];
                next_fetch = 3'd1;
                PC_o <= PC_o + 25'd1;
                prefetch_buffer <= mem_i;

                test1 <= 1'b0;
                test2 <= test2 + test1;

            end
        end
    end
end

endmodule