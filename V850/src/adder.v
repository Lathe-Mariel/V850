module ALU(
wire clk,
inout logic[31:0] GR[31:0],
output logic[31:0] PSW,
input logic[31:0] reg1,
inout logic[32:0] reg2,    // {PSW, reg2}
input logic[4:0] imm5
);

always_ff @(posedge clk)begin
        {PSW[3], GR[reg2]} <= {1'b0, GR[reg2]} + {1'b0, GR[reg1]};
 
end

endmodule