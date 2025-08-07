 module rv_rf (
input clk,
input reset,
//FDU IF
input [4:0] rd_addr1,
input [4:0] rd_addr2,
output [31:0] rd_data1,
output [31:0] rd_data2,
//ALU WB IF
input [31:0] wr_data,
   input [4:0] wr_addr,   
input we,
input reg_sel );
 
//reg declarations
logic [31:0] regfile [32];
 
assign rd_data1 = (rd_addr1 == 5'd0) ? 32'd0 : regfile[rd_addr1]; // Read from register x0 always returns 0
assign rd_data2 = (rd_addr2 == 5'd0) ? 32'd0 : regfile[rd_addr2]; // Read from register x0 always returns 0
integer i;
always @(posedge clk) begin
	if (reset) begin
		for (i = 0; i < 32; i = i + 1) begin   //  Loop through all 32 registers
          regfile[i] <= 32'd0;
		end
	end else begin
        // Combined write-enable conditions and added a check to prevent writing to register x0
		if (we && reg_sel &&  (wr_addr != 5'd0))  
			regfile[wr_addr] <= wr_data;
	  end // else: !if(reset)
  end
endmodule


