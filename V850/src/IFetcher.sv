module IFetcher(
input logic reset,
input logic clk,
input logic[24:0] PC_i,
input logic[63:0] mem_i,
output logic[63:0] instruction_o,
output logic[24:0] PC_o
);



logic[63:0] prefetch_buffer;    //
logic[2:0] buffer_pointer;             // index for ring buffer

logic reg2_en;       // reg2 number is not 0

assign reg2_en = |{prefetch_buffer[15:11]};    // when OP2(reg2 number) is 0

always_ff @(posedge clk)begin
    if(reset)begin
        PC_o <= 0;
    end else begin

    if(prefetch_buffer[10:9] == 2'b11)begin
        if(reg2_en && (prefetch_buffer[8] + prefetch_buffer[7] + prefetch_buffer[6]) == 1'b0)begin
            // 32bit inst
            PC_o <= PC_o + 25'd2;
            prefetch_buffer <= mem_i;
            instruction_o <= prefetch_buffer[31:0];
        end else begin
            // ★
            // 48 bit
            PC_o <= PC_o + 25'd3;

            //  64 bit
            PC_o <= PC_o + 25'd4;
        end

    end else begin
        if(!reg2_en & prefetch_buffer[7] & prefetch_buffer[9])begin
            // JR, JARL(32bit)
        end else begin
            // 16bit inst
            instruction_o <= prefetch_buffer[15:0];
            prefetch_buffer <= mem_i;
            PC_o <= PC_o + 25'd1;
        end
    end
    end
end

endmodule