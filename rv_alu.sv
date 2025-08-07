`ifndef __RV_ALU___
`define __RV_ALU__

module rv_alu (
input clk,
input reset,
//FDU IF
input alu_op_valid,
input [3:0] alu_op,
input [31:0] alu_in1,
input [31:0] alu_in2,
input [4:0]  alu_addr,
input alu_reg_mem_n,
output alu_rdy,
//RF interface
output [31:0] alu_result,
output alu_result_valid,
output [31:0] alu_result_addr,
output alu_result_reg_memn );

reg [31:0] in1;
reg [31:0] in2;
reg [3:0]  op;
reg [31:0] addr;
reg reg_memn;
reg alu_op_valid_d1;
reg alu_op_valid_d2;
reg [31:0] _result_addr;
reg _result_valid;
reg _result_reg_memn;
logic [31:0] result;
reg _rdy;
assign alu_rdy = reset? 1'b0 : _rdy;
always @(posedge clk) begin
	if (reset) begin
		in1      <= 32'd0;
		in2      <= 32'd0;  
		op       <= 4'd0;
		addr     <= 32'd0;
		reg_memn <= 1'b0;
      
	end
	else begin
		if (alu_op_valid == 1'b1) begin
			in1      <= alu_in1;
			in2      <= alu_in2;
			op       <= alu_op;
			addr     <= alu_addr;
			reg_memn <= alu_reg_mem_n;
		end
      else begin
		in1      <= 32'd0;
		in2      <= 32'd0;  
		op       <= 4'd0;
		addr     <= 32'd0;
		reg_memn <= 1'b0;
		end
	end//else
end//always
always @(posedge clk) begin
	if (reset) 
		result <= 0;
	else begin
		case (op)
			4'b0000: result <= in1 + in2; // ADD
			4'b0001: result <= in1 - in2; // SUB
			4'b0010: result <= in1 & in2; // AND
			4'b0011: result <= in1 | in2; // OR
			4'b0100: result <= in1 ^ in2; // XOR
			4'b0101: result <= in1 << in2[4:0]; //SHL
			//AddMore ALU operations 
			//signed/unsigned comparison, etc.)
			default: result <= 32'b0; // should never happen
		endcase
	end//else
end//always
//rdy logic: lowo on reset after reset hi
//low on valid goes high 2 clk later
always @(posedge clk) begin
	if (reset) 
		_rdy <= 1'b1;
	else 
	_rdy <= alu_op_valid_d1;
end
always @(posedge clk) alu_op_valid_d1  <= alu_op_valid;
always @(posedge clk) alu_op_valid_d2  <= alu_op_valid_d1;

  always @(posedge clk) _result_valid    <= reset ? 1'b0 : alu_op_valid_d1;
  always @(posedge clk) _result_addr     <= reset ? 32'd0 : addr;  
always @(posedge clk) _result_reg_memn <= reg_memn;

assign alu_result_reg_memn = _result_reg_memn;
assign alu_result_addr   = _result_addr;
assign alu_result_valid    = _result_valid;
assign alu_result = reset ? 32'd0 : result;  

endmodule
`endif
