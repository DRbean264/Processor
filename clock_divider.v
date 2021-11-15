module clock_divider(slower_clock, clock, reset);
	input clock, reset;
	output reg slower_clock;
	
	always @(posedge clock or posedge reset) begin
		if (reset == 1'b1) begin
			slower_clock <= 1'b0;
		end else begin
			slower_clock <= ~slower_clock;
		end
	end
endmodule