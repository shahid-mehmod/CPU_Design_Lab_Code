module rv_cpu (
input  logic  clk,             // Clock signal
input  logic  reset,           // Reset signal
output logic [31:0] pc, // PC out
output logic        ads, //addr valid
output logic rd_wr_n, //rd -1, wr -0
output logic i_dn, //instr -1, data -0
output logic  [31:0] addr,
output logic  [3:0]  be,
output logic  [31:0] wr_data,
input  logic  [31:0] rd_data,
input  ack, //data ack
input  intr //interrupt request 
);

logic fdu_bu_fetch_valid;
logic [31:0] fdu_bu_fetch_addr;
logic [31:0] fdu_bu_instruction_word;
 logic       fdu_bu_instr_word_valid;
logic [31:0] alu_bu_result;
logic        alu_bu_result_valid;
logic [31:0] alu_bu_result_addr;
logic alu_bu_result_reg_memn;
logic [31:0] sys_pc; 
logic        sys_ads; //addr valid
logic        sys_rd_wr_n; //rd - 1, wr-  0
logic        sys_i_dn; //instr- 1, data -0
logic [31:0] sys_addr;
logic [3:0]  sys_be;
logic [31:0] sys_wr_data;
logic [31:0] sys_rd_data;
logic        sys_ack; //data ack
logic        sys_intr; //interrupt request
logic        fdu_alu_op_valid;
logic [3:0]  fdu_alu_op;
logic [31:0] fdu_alu_in1;
logic [31:0] fdu_alu_in2;
logic [4:0] fdu_alu_addr;
logic        alu_fdu_rdy;
logic        fdu_alu_reg_mem_n;
logic [4:0]  fdu_rf_rd_addr1;
logic [4:0]  fdu_rf_rd_addr2;
logic [31:0] fdu_rf_rd_data1;
logic [31:0] fdu_rf_rd_data2;
logic        rf_we;
logic [4:0]  rf_wr_addr;

assign  pc = sys_pc;
assign ads = sys_ads;
assign rd_wr_n = sys_rd_wr_n;
assign addr = sys_addr;
assign i_dn = sys_i_dn;
assign be = sys_be;
assign wr_data = sys_wr_data;
assign sys_rd_data = rd_data;
assign sys_ack = ack;
assign intr = sys_intr;
  
assign rf_we      = alu_bu_result_valid & alu_bu_result_reg_memn;
assign rf_wr_addr = alu_bu_result_addr[4:0];
//BU
rv_bu bu (
 .clk(clk),
 .reset(reset),
.fetch_valid (fdu_bu_fetch_valid),
.fetch_addr (fdu_bu_fetch_addr),
.instruction_word(fdu_bu_instruction_word),
.instr_word_valid(fdu_bu_instr_word_valid),
.alu_result (alu_bu_result),
.alu_result_valid (alu_bu_result_valid),
.alu_result_addr (alu_bu_result_addr),
.alu_result_reg_memn (alu_bu_result_reg_memn),
.pc(sys_pc), .ads(sys_ads), //addr valid
 .rd_wr_n(sys_rd_wr_n), //rd -1, wr -0    // Corrected: sys_rd_wrn -> sys_rd_wr_n
 .i_dn (sys_i_dn), //instruction -1, data -0
 .addr(sys_addr),
 .be (sys_be),
 .wr_data(sys_wr_data),
 .rd_data(sys_rd_data),
 .ack(sys_ack), //data ack
 .intr(sys_intr) //interrupt request
);
rv_fdu fdu(
.clk(clk),
.reset(reset),
.fetch_valid (fdu_bu_fetch_valid),
.fetch_addr (fdu_bu_fetch_addr),
.instruction_word(fdu_bu_instruction_word),
.instr_word_valid(fdu_bu_instr_word_valid),
.alu_op_valid(fdu_alu_op_valid),
.alu_op(fdu_alu_op),
.alu_in1(fdu_alu_in1),
.alu_in2(fdu_alu_in2),
.alu_rdy(alu_fdu_rdy),
.rf_rd_addr1(fdu_rf_rd_addr1),
.rf_rd_data1(fdu_rf_rd_data1),
.rf_rd_addr2(fdu_rf_rd_addr2),
.rf_rd_data2(fdu_rf_rd_data2),
  .alu_reg_mem_n(fdu_alu_reg_mem_n),
  .alu_addr(fdu_alu_addr));

rv_alu alu(
.clk(clk),
.reset(reset),
.alu_op_valid (fdu_alu_op_valid) ,
.alu_op  (fdu_alu_op),
.alu_in1 (fdu_alu_in1),
.alu_in2 (fdu_alu_in2),
.alu_addr(fdu_alu_addr),
.alu_reg_mem_n (fdu_alu_reg_mem_n),
.alu_rdy (alu_fdu_rdy),
.alu_result (alu_bu_result),
.alu_result_valid (alu_bu_result_valid),
.alu_result_addr (alu_bu_result_addr),
.alu_result_reg_memn (alu_bu_result_reg_memn)); 

rv_rf rf (
.clk (clk),
.reset(reset),
.rd_addr1 (fdu_rf_rd_addr1 ),
.rd_addr2 (fdu_rf_rd_addr2),
.rd_data1 (fdu_rf_rd_data1),
.rd_data2 (fdu_rf_rd_data2),
.wr_data  (alu_bu_result),
.wr_addr  (rf_wr_addr),
.we       (rf_we),
.reg_sel  (alu_bu_result_reg_memn) );

endmodule


