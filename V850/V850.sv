`default_nettype none

module V850 (
input wire clk,
input wire sw0,
input wire sw1,
input wire rst_n,
output wire fan,
output logic [15-1:0]     ddr_addr,       //ROW_WIDTH=15
output logic [3-1:0]      ddr_bank,       //BANK_WIDTH=3
output logic ddr_cs,
output logic ddr_ras,
output logic ddr_cas,
output logic ddr_we,
output logic ddr_ck,
output logic ddr_ck_n,
output logic ddr_cke,
output logic ddr_odt,
output logic ddr_reset_n,
output logic[4-1:0]      ddr_dm,         //DM_WIDTH=2
inout  wire[32-1:0]     ddr_dq,         //DQ_WIDTH=32
inout  wire[4-1:0]      ddr_dqs,        //DQS_WIDTH=2
inout  wire[4-1:0]      ddr_dqs_n,      //DQS_WIDTH=2
output logic[5:0]        state_led
);


//logic[31:0][0] r0
logic[31:0] GR[31:0];
logic[31:0] PSW;

// CPU Function group system registers
logic[31:0] EIPC;   // status save register when EI level exception received
logic[31:0] EIPSW;  // status save register when EI level exception received
logic[31:0] FEPC;   // status save register when FE level exception received
logic[31:0] FEPSW;  // status save register when FE level exception received
logic[31:0] ECR;    // factor of exception

logic[31:0] SCCFG;  // action setting for SYSCALL
logic[31:0] SCBP;   //SYSCALL base pointer
logic[31:0] EIIC;   // factor of EI level exception
logic[31:0] FEIC;   //factor of FE level exception
logic[31:0] DBIC;   //factor of DB level exception
logic[31:0] CTPC;   // status save register when execute CALLT
logic[31:0] CTPSW;  //status save register when execute CALLT
logic[31:0] DBPC;   // status save register when DB level exception received
logic[31:0] DBPSW;  // status save register when DB level exception received
logic[31:0] CTBP;   //CALLT base pointer
logic[31:0] debug_register;  // debug function registers
logic[31:0] EIWR;   // working register for EI level exception
logic[31:0] FEWR;   // working register for FE level exception
logic[31:0] DBWR;   // working register for DB level exception
logic[31:0] BSEL;   // selection of register bank


assign fan = 1'b1;

/*
assign state_led[5] = ~app_wdf_rdy;
assign state_led[4] = ~led;
assign state_led[3] = ~error;
assign state_led[2] = ~pll_stop;
assign state_led[1] = ~pll_lock; 
assign state_led[0] = ~init_calib_complete; //DDR3_init_indicator
*/

//assign GR[0] = 32'b0;

logic[63:0] instruction_ifid;    //IF ID
logic[24:0] PC_ifid;    // virtually [25:1] ([31:26] is automatically filled by sign extension. value of PC[0] is always 0)

IFetcher inst_IFetcher(
    .clk(clk),
    .rst_n(rst_n),
    .PC_i(),        // when branch??
    .instruction_o(instruction_ifid),
    .PC_o(PC_ifid)  //IF -> ID
);

logic[31:0] reg1_idex, reg2_idex;    // ID EX
logic[31:0] reg3_idex;
logic[4:0] destination_idex;    // GR[0] is always 0, and then destination is set up 0, PC is pointed as a destination register.
logic[4:0] destination2_idex;
logic increment_bit_idex;
logic[9:0] circuit_sel_idex;

Decorder inst_Decorder(
    .instruction_ID_i(instruction_ifid),
    .reg1_o(reg1_idex),
    .reg2_o(reg2_idex),
    .reg3_o(reg3_idex),
    .increment_bit_o(increment_bit_idex),
    .destination_o(destination_idex),
    .destination2_o(destination2_idex),
    .clk(clk),
    .PC_ID_i(PC_ifid),
    .GR(GR),
    .PSW_i(PSW),
    .circuit_sel_o(circuit_sel_idex)
);

logic[24:0] PC_exmem;           // EX -> MEM
logic[31:0] result_exwb;        // EX -> WB
logic[31:0] result2_exwb;       // EX -> WB
logic[4:0] destination_exwb;    // EX -> MEM & WB
logic[4:0] destination2_exwb;   // EX -> MEM & WB
logic[31:0] PSW_exwb;           // EX -> WB
logic[9:0] circuit_sel_exmem;   // EX -> MEM
logic[31:0] memory_address;     // EX ->

Executer inst_Executer(
    .clk(clk),
    .destination_EX_i(destination_idex),
    .destination2_EX_i(destination2_idex),
    .reg1_i(reg1_idex),
    .reg2_i(reg2_idex),
    .reg3_i(reg3_idex),
    .increment_bit_i(increment_bit_idex),
    .result_o(result_exwb),
    .result2_o(result2_exwb),
    .destination_o(destination_exwb),
    .destination2_o(destination2_exwb),
    .PSW_o(PSW_exwb),
    .circuit_sel_i(circuit_sel_idex),
    .circuit_sel_o(circuit_sel_exmem),
    .PC_o(PC_exmem),
    .memory_address_o(memory_address)
);

logic[31:0] wb_data_memwb;           // MEM -> WB
logic[4:0] destination_memwb;        // MEM -> WB

Memory inst_Memory(
    .clk(clk),
    .destination_i(destination_exwb),
    .memory_address_i(memory_address[28:0]),
    .wb_data_o(wb_data_memwb),
    .destination_o(destination_memwb),
    .circuit_sel_i(circuit_sel_exmem),
    .ddr_cmd_rdy_i(ddr_cmd_rdy),
    .ddr_read_data_o(),
    .ddr_read_data_valid_i(ddr_read_data_valid),
    .ddr_read_data_end_i(ddr_read_data_end),
    .ddr_enable_o(ddr_en),
    .ddr_cmd_o(ddr_cmd)
    
);



Writeback inst_Writeback(
    .clk(clk),
    .result_i(result_exwb),
    .result2_i(result2_exwb),
    .destination_i(destination_exwb),
    .destination2_i(destination2_exwb),

    .wb_data_i(wb_data_memwb),
    .mem_destination_i(destination_memwb),    // destination register number for memory access data
    .PSW_i(),
    .GR(GR),
    .PSW_o()
);


wire                    ddr_write_en;
wire  [32-1:0]          app_wdf_mask;      //APP_MASK_WIDTH=16
wire                    ddr_write_data_end; 
wire [256-1:0]          ddr_write_data;    //APP_DATA_WIDTH=256
logic                   ddr_en;
wire [2:0]              ddr_cmd;           // read(1) or write(0)
wire [29-1:0]           memory_address;    //ADDR_WIDTH=29
//wire                    app_sre_req;
//wire                    app_ref_req;
wire                    app_burst;
wire                    ddr_sre_act;
wire                    ddr_ref_ack;
wire                    ddr_write_rdy;
wire                    ddr_cmd_rdy;
wire                    ddr_read_data_valid; 
wire                    ddr_read_data_end;
wire [256-1:0]          ddr_read_data;     //APP_DATA_WIDTH=256
logic pll_stop;
logic pll_lock;
logic memory_clk;
logic clk_x1;
//logic clk50m;
logic init_calib_complete;
logic ddr_rst;

//DDR3_Memory_Interface_Top u_ddr3 (
    D3_400 inst_ddr3 (
    .memory_clk      (memory_clk),              // メモリ用クロック（ -> DDR3 IP)
    .pll_stop        (pll_stop),
    .clk             (clk),                     // リファレンスクロック（ -> DDR3 IP）
    .rst_n           (rst_n),                   //rst_n システムリセット（ -> DDR3 IP）
    .cmd_ready       (ddr_cmd_rdy),             // コマンドおよびアドレスを受信可能（ DDR3 IP -> ）
    .cmd             (ddr_cmd),                 // コマンド 1:read  0:write ( -> DDR3 IP )
    .cmd_en          (ddr_en),                  // アドレスおよびコマンド・イネーブル    1:有効 ( -> DDR3 IP )
    .addr            (memory_address),          // アドレス入力  Rank + Bank + Row + Column
    .wr_data_rdy     (ddr_write_rdy),           // データ受信可能（ DDR3 IP -> ）
    .wr_data         (ddr_write_data),          // 書き込みデータ
    .wr_data_en      (ddr_write_en),            // 書き込みイネーブル( -> DDR3 IP )
    .wr_data_end     (ddr_write_data_end),             // バースト転送の最終サイクルを示す    1:最終サイクル
    .wr_data_mask    (app_wdf_mask),
    .rd_data         (ddr_read_data),           // 読み出しデータ( DDR3 IP -> ）
    .rd_data_valid   (ddr_read_data_valid),     // rd_data 有効（ DDR3 IP -> ）
    .rd_data_end     (ddr_read_data_end),       // 書き込みの最終サイクルであることを示す（ -> DDR3 IP ）
    .sr_req          (1'b0),                    // セルフリフレッシュ要求（ -> DDR3 IP ）
    .ref_req         (1'b0),                    // ユーザーリフレッシュ要求（ -> DDR3 IP ）
    //.zq_req          (1'b0),
    .sr_ack          (ddr_sre_act),             // セルフリフレッシュ応答（ DDR3 IP -> ）
    .ref_ack         (ddr_ref_ack),             // ユーザーリフレッシュ応答（ DDR3 IP -> ）
    .init_calib_complete(init_calib_complete),  // キャリブレーション完了（ DDR3 IP -> ）
    .clk_out         (clk_x1),                  // ユーザデザインのクロック（出力）
    .pll_lock        (pll_lock),                // PLLロック(入力) 使わない場合は1にする
    .burst           (app_burst),               // OTF制御ポート  1:BL8モード,  0:BC4モード. OTFモードでのみ有効 
    // mem interface
    .ddr_rst         (ddr_rst),                 // IP内で使われるグローバルリセット，ユーザ回路にも出力
    .O_ddr_addr      (ddr_addr),                // Rowアドレス(アクティブコマンド)、Columnアドレス(読み出し、書き込みコマンド) 
    .O_ddr_ba        (ddr_bank),                // Bankアドレス
    .O_ddr_cs_n      (ddr_cs),                  // チップセレクト信号，アクティブLow 
    .O_ddr_ras_n     (ddr_ras),
    .O_ddr_cas_n     (ddr_cas),
    .O_ddr_we_n      (ddr_we),
    .O_ddr_clk       (ddr_ck),
    .O_ddr_clk_n     (ddr_ck_n),
    .O_ddr_cke       (ddr_cke),
    .O_ddr_odt       (ddr_odt),
    .O_ddr_reset_n   (ddr_reset_n),             // _DDR3 SDRAMリセット信号
    .O_ddr_dqm       (ddr_dm),
    .IO_ddr_dq       (ddr_dq),
    .IO_ddr_dqs      (ddr_dqs),
    .IO_ddr_dqs_n    (ddr_dqs_n)
);

Gowin_PLL Gowin_PLL_inst(
.lock(pll_lock), 
.clkout0(), 
//.clkout1(clk50m), 
.clkout2(memory_clk),
.clkin(clk), 
.reset(1'b0),
.enclk0(1'b1), //input enclk0
.enclk1(1'b1), //input enclk1
.enclk2(pll_stop) //input enclk2
);

endmodule

`default_nettype wire