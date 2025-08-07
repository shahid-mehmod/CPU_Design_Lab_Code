`ifndef __RV_BU___
`define __RV_BU__

typedef enum { IDLE, CMD, WAIT, DATA } state_t;

module rv_bu (
	input clk,
	input reset,
	input fetch_valid,
	input   [31:0] fetch_addr,
	output logic [31:0] instruction_word,
	output logic   instr_word_valid,
	input  [31:0] alu_result,
	input   alu_result_valid,
	input  [31:0] alu_result_addr,
	input alu_result_reg_memn,
	output logic [31:0] pc,       
	output logic        ads, //addr valid
	output logic        rd_wr_n, //rd -1, wr -0
	output logic        i_dn, //instr-1, data -0
	output logic [31:0] addr,
	output logic [3:0]  be,
	output logic [31:0] wr_data,
	input  logic [31:0] rd_data,
	input  logic        ack, //data ack
	input  logic        intr //interrupt req 
);
	
	state_t bus_state;
	logic ivalid;
	logic valid_req;
	logic alu_wr_req;
	logic [31:0] din;
	logic fetch_req  ;
	logic [31:0] faddr;
	logic [31:0] alu_wr_addr ;
	logic [31:0] alu_wr_data ;

	always @(posedge clk ) begin
		if (reset) begin
			bus_state <= IDLE;
			ads       <= 1'b0;
			rd_wr_n   <= 1'b1;
			i_dn      <= 1'b1;
			be        <= 4'b0;
			wr_data   <= 32'b0;
			addr      <= 32'b0;
			ivalid    <= 1'b0;
			din       <= 32'b0;
		end else begin
			case (bus_state)
				IDLE: begin
					ads       <= 1'b0;
					ivalid    <= 1'b0;
					if (valid_req) begin
						bus_state <= CMD;
						ads       <= 1'b1;
						// Determine request type
						if (fetch_req) begin
							addr    <= faddr;
							rd_wr_n <= 1'b1; // Read
							i_dn    <= 1'b1; // Instruction
							be      <= 4'b1111; // Full word write
						end else begin // alu_wr_req
							addr    <= alu_wr_addr;
							wr_data <= alu_wr_data;
							rd_wr_n <= 1'b0; // Write
							i_dn    <= 1'b0; // Data
							be      <= 4'b1111; // Full word write
						end
					end
				end

				CMD: begin
                  ads <= 0;
                  if(!ack)
					bus_state <= WAIT;
                  else begin
                    if (rd_wr_n) begin
                    din       <= rd_data;
                    bus_state <= DATA;
                    end
                    else 
                      bus_state <= IDLE;
                  end
					//ads <= 1'b0; // De-assert address valid
				end

				WAIT: begin
					if (ack) begin
						if (rd_wr_n) begin // Read request 
							bus_state <= DATA;
							din       <= rd_data;
						end else begin // Write request 
							bus_state <= IDLE;
						end
					end
				end

				DATA: begin 
					ivalid <= 1'b1;
					bus_state <= IDLE;
				end
			endcase
		end //else begin
	end //always begin
  
	assign pc = fetch_addr;
	assign valid_req = fetch_req | alu_wr_req;
	always @(posedge clk) begin
		fetch_req   <= reset ? 1'b0 : fetch_valid;
		faddr       <= reset ? 32'dx: fetch_addr;
		alu_wr_req  <= reset ? 1'b0 : alu_result_valid & ~alu_result_reg_memn;
		alu_wr_data <= reset ? 32'dx : alu_result;
		alu_wr_addr <= reset ? 32'dx : alu_result_addr;
	end

	always @(posedge clk) begin
		instr_word_valid <= reset ? 1'b0 : ivalid;
		instruction_word <= reset ? 32'dx : din;
	end
endmodule
`endif	

