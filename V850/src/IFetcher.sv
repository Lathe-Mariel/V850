module IFetcher(
input logic rst_n,
input logic clk,
input logic[24:0] PC_i,
input logic[63:0] memory_data_i,
output logic[24:0] memory_address,
output logic[63:0] instruction_o,
output logic[24:0] PC_o,
output logic[2:0] next_fetch    // 16bit or 32bit or 48bit or 64bit
//output logic[24:0] fetch_address
);


logic[127:0] prefetch_buffer;    //

logic reg2_en;       // reg2 number is not 0

logic[3:0] rst_counter;
// INIT, START1, START2, ACTIVE

typedef enum logic[1:0]{
  INIT = 2'b00,
  START1 = 2'b01,
  START2 = 2'b10,
  ACTIVE = 2'b11
} state_t;

state_t state;
assign reg2_en = |{prefetch_buffer[15:11]};    // when OP2(reg2 number) is 0

always_ff @(posedge clk)begin
    if(~rst_n)begin
        rst_counter <= 0;
        state <= INIT;
    end else begin
      case(state)
        INIT:begin
          rst_counter <= rst_counter + 4'b1;
          PC_o <= 25'd0;
          memory_address <= PC_o + next_fetch;
          next_fetch <= 0;
          instruction_o <= 0;
          prefetch_buffer[63:0] <= memory_data_i;
          if(rst_counter == 14)begin
            state <= START1;
          end else begin

          end
        end
        START1:begin
//          rst_counter <= rst_counter + 4'b1;
          PC_o <= 25'd4;
          memory_address <= 25'd4 + next_fetch;
          next_fetch <= 0;
          instruction_o <= 0;
          prefetch_buffer[63:0] <= memory_data_i;
          state <= START2;
        end
        START2:begin
//          rst_counter <= rst_counter + 4'b1;

          PC_o <= 25'd0;
          memory_address <= 25'd8 + next_fetch;
          next_fetch <= 0;
          instruction_o <= 0;
          prefetch_buffer[127:64] <= memory_data_i;
          state <= ACTIVE;
        end
        ACTIVE:begin
//        PC_o <= PC_o + next_fetch;
          if(prefetch_buffer[10:9] == 2'b11)begin
            if(reg2_en && (prefetch_buffer[8] + prefetch_buffer[7] + prefetch_buffer[6]) == 1'b0)begin
                 // 32bit inst
                instruction_o <= prefetch_buffer[31:0];

                next_fetch <= 3'd2;
                PC_o <= PC_o + next_fetch;
                memory_address <= PC_o + next_fetch + 25'd10;
                prefetch_buffer[95:0] <= prefetch_buffer[127:32];
                prefetch_buffer[127:96] <= memory_data_i[31:0];

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

                next_fetch <= 3'd2;
                PC_o <= PC_o + next_fetch;
                memory_address <= PC_o + next_fetch + 25'd10;
                prefetch_buffer <= memory_data_i;

            end else begin
                // 16bit inst
                instruction_o <= prefetch_buffer[15:0];
                next_fetch <= 3'd1;
                PC_o <= PC_o + next_fetch;
                memory_address <= PC_o + next_fetch + 25'd9;
                prefetch_buffer[111:0] <= prefetch_buffer[127:16];
                prefetch_buffer[127:112] <= memory_data_i[15:0];
            end
          end
        end
      endcase
    end
end

endmodule