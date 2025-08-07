`ifndef __RV_FND___
`define __RV_FND__
`define PCRST_VAL 32'h_10000
module rv_fdu (
	input clk,
	input reset,
	//ALU IF
	output logic alu_op_valid,
	output logic [3:0] alu_op,
	output [31:0] alu_in1,
	output [31:0] alu_in2,
	output logic alu_reg_mem_n,
	output [4:0] rf_rd_addr1,
	input [31:0] rf_rd_data1,
	output [4:0] rf_rd_addr2,
	input [31:0] rf_rd_data2,
	input alu_rdy, //1- alu rdy to accept new op
	output fetch_valid,
	output [31:0] fetch_addr,
	input [31:0] instruction_word,
	input instr_word_valid,
    output logic [4:0] alu_addr);

	reg [31:0] pc_reg; // Program counter
	reg [31:0] instruction;
	wire [4:0] rs1, rs2, alu_rdest;
	wire [6:0] opcode;
	wire [2:0] funct3;
	wire [6:0] funct7;
	logic reg_write;
	logic mem_read;
	logic mem_write;
	logic branch;
	logic jump;
	logic [3:0] alu_ctrl;
	logic [31:0] operand1;
	logic [31:0] operand2;
	logic fetch_valid;
    logic alu_decode;

	//fetch instruction
	assign fetch_addr = pc_reg;
	//assign alu_reg_mem_n = reg_write;
  
  always@(posedge clk) begin  
    if (reset)
     alu_reg_mem_n <= 1'b0;
     else
    alu_reg_mem_n <= reg_write;
  end

	  
  assign alu_op = reset ? 4'b0000 : alu_ctrl;               
  always@(posedge clk) alu_decode <= instr_word_valid;
  always@(posedge clk) begin
    if(reset)
     alu_op_valid <= 1'b0;
    else
    alu_op_valid <= alu_decode;
  end
  
	always @(posedge clk) begin
		if (reset)
			fetch_valid <= 1'b0;
		else if (alu_rdy)
			fetch_valid <= 1'b1;
        else 
			fetch_valid <= 1'b0;
	end

	//get instruction word
	always @(posedge clk) begin
		instruction <= instr_word_valid ?
			instruction_word : 32'd0;
	end

	// --- Register File ---
	assign rf_rd_addr1 = rs1;
	assign rf_rd_addr2 = rs2;
	always @(posedge clk) begin
		if (reset) begin
			operand1 <= 32'd0;
			operand2 <= 32'd0;
            alu_addr <= 5'd0;
		end
		else begin
			operand1 <= rf_rd_data1;
			operand2 <= rf_rd_data2;
            alu_addr <= alu_rdest;
		end
	end
	assign alu_in1 = operand1;
	assign alu_in2 = operand2;

	//PC updates
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			pc_reg <= `PCRST_VAL; //32'h1_0000
		end
	  else begin
		if (jump) begin
			pc_reg <= pc_reg + (instruction[31:0]);
		end
		else if (branch) begin
			pc_reg <= pc_reg + (instruction[31:0]);
		end
        else if (alu_rdy)begin
			pc_reg <= pc_reg + 4; // Increment PC by 4
		end
        else
          pc_reg <= pc_reg;
	  end
	end

	//decode
	always @(*) begin
		// Default Values
		reg_write = 1'b0;
		mem_read = 1'b0;
		mem_write = 1'b0;
		branch = 1'b0;
		jump = 1'b0;
		alu_ctrl = 1'b0;
		case (opcode)
			7'b0110011: begin // R-type instructions
				reg_write = 1;
				case (funct3)
					3'b000: alu_ctrl = (funct7[5]) ? 4'b0001 : 4'b0000;
					3'b111: alu_ctrl = 4'b0011;
					3'b110: alu_ctrl = 4'b0010;
					default: alu_ctrl = 4'b0000;
				endcase
			end
		endcase
	end

	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];
	assign alu_rdest = instruction[11:7];
	assign opcode = instruction[6:0];
	assign funct3 = instruction[14:12];
	assign funct7 = instruction[31:25];

endmodule
`endif
