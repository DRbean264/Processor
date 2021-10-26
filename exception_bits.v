module exception_bits(exception, opcode, aluop);
	input [4:0] opcode, aluop;
	output reg [31:0] exception;
	
	always @(*) begin
		exception <= 32'd0;
		
		if (opcode == 5'b00000) begin
			if (aluop == 5'b00000) begin
				exception <= 32'd1;
			end else if (aluop == 5'b00001) begin
				exception <= 32'd3;
			end
		end else if (opcode == 5'b00101) begin
			exception <= 32'd2;
		end
	end
endmodule