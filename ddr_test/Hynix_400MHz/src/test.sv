`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2016/07/27 10:58:47
// Design Name:
// Module Name: user_test
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////

module test #(
    parameter ADDR_WIDTH = 28,
    parameter APP_DATA_WIDTH = 256,
    parameter APP_MASK_WIDTH = 32,
    parameter USER_REFRESH = "OFF"
    )
    (
    //input
    clk, 
    rst, 
    app_rdy, 
    app_rd_data_valid, 
    app_rd_data, 
    init_calib_complete,
    wr_data_rdy,
    //output
    app_en,
    app_cmd, 
    app_addr, 
    app_wdf_data, 
    app_wdf_wren,
    app_wdf_end, 
    app_wdf_mask, 
    app_burst,
    sr_req, 
    ref_req,
    
    );

    input clk;
    input rst;
    input app_rdy;
    input app_rd_data_valid;
    input wr_data_rdy;
    input [APP_DATA_WIDTH-1:0] app_rd_data;        // <- DDRR3 IP 読み出しデータ
    input init_calib_complete;

    output reg           app_en;
    output reg     [2:0] app_cmd;
    output reg     [ADDR_WIDTH-1:0] app_addr ;    // -> DDR3 IP
    output reg     [APP_DATA_WIDTH-1:0] app_wdf_data ;
    output reg     app_wdf_wren;                  // -> DDR3 IP 書き込みイネーブル
    output     app_wdf_end;
    output [APP_MASK_WIDTH-1:0] app_wdf_mask ;
    output app_burst;
    output sr_req;
    output ref_req; 
    
    reg app_rd_data_valid_r;
    reg [APP_DATA_WIDTH-1:0] app_rd_data_r/* synthesis syn_preserve = 1 */;
    reg app_rd_data_valid_rr;
    reg [APP_DATA_WIDTH-1:0] app_rd_data_rr/* synthesis syn_preserve = 1 */;

/* 読み出しデータ FF 2段で受ける */
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

    assign app_wdf_mask = 0;
    assign sr_req = 0;
    assign ref_req = 0;
    assign app_burst = 0;
	
	wire [63:0] EYE_MEM [0:7];
/* 書き込みデータ群 */	
	assign	EYE_MEM[0] = 64'h5883adb4c88ad596;
	assign	EYE_MEM[1] = 64'h1122334455667788;
	assign	EYE_MEM[2] = 64'h99aabbccddeeff00;
	assign	EYE_MEM[3] = 64'h0000ffff0000ffff;
	assign  EYE_MEM[4] = 64'hffff0000ffff0000;
	assign  EYE_MEM[5] = 64'h00000000ffff0000;
	assign  EYE_MEM[6] = 64'haf5d632fc8b91658;
	assign  EYE_MEM[7] = 64'hffffffff0000ffff;

	wire [63:0] EYE_MEM_C [0:7];

/* 検証 比較用データ群 */	
	assign	EYE_MEM_C[0] = 64'h5883adb4c88ad596;
//	assign	EYE_MEM_C[0] = 64'h4883adb4c88ad596;
	assign	EYE_MEM_C[1] = 64'h1122334455667788;
	assign	EYE_MEM_C[2] = 64'h99aabbccddeeff00;
	assign	EYE_MEM_C[3] = 64'h0000ffff0000ffff;
	assign  EYE_MEM_C[4] = 64'hffff0000ffff0000;
	assign  EYE_MEM_C[5] = 64'h00000000ffff0000;
	assign  EYE_MEM_C[6] = 64'haf5d632fc8b91658;
	assign  EYE_MEM_C[7] = 64'hffffffff0000ffff;

    reg[1:0] state;
    localparam IDLE  = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ  = 2'b10;

    reg [2:0] bank;
    reg [13:0] row;
    reg [9:0] col;

    always@(posedge clk or posedge rst)begin
        if(rst)
            state <= IDLE;
        else
            state <= WRITE;
    end

/* app enable signal */
    always@(posedge clk or posedge rst)
        if(rst)
            app_en <= 1'b0;
        else if( state == WRITE & app_rdy & wr_data_rdy)
            app_en <= 1'b1;
        else if( state == READ & app_rdy)
            app_en <= 1'b1;
        else
            app_en <= 1'b0;

/* 読み書き信号切り替え */
    always@(posedge clk or posedge rst)
        if(rst)
            app_cmd <= 3'b000;
        else if(state == WRITE)
            app_cmd <= 3'b000;
        else
            app_cmd <= 3'b001;
	
/* 書き込みイネーブル信号 */
    always@(posedge clk or posedge rst)
        if(rst)
            app_wdf_wren <= 1'b0;
        else if(state == WRITE & app_rdy & wr_data_rdy)
            app_wdf_wren <= 1'b1;
        else
            app_wdf_wren <= 1'b0;
	assign app_wdf_end = app_wdf_wren;
	

/* 書き込みアドレス選択 */
	//assign app_addr = {1'b0,bank,row,col};
    always@(posedge clk or posedge rst)
        if(rst)
            app_addr <= 'd0;
        else
            app_addr <= {1'b0,bank,row,col};


/* 書き込みデータ 組み立て */
    always@(posedge clk or posedge rst)
        if(rst)
            app_wdf_data <= 'd0;
        else
            app_wdf_data <= 'd0;

endmodule