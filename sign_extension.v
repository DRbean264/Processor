module sign_extension(extended, immediate);
	output reg [31:0] extended;
	input [16:0] immediate;
	
	wire sign_bit;
	integer i;
	
	assign sign_bit = immediate[16];
	
	always @(*) begin
		extended[16:0] <= immediate;
	
		for (i = 31; i >= 17; i = i - 1) begin : sign_series
			extended[i] <= sign_bit;
		end
	end
endmodule