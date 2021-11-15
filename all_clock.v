module all_clock(imem_clock, dmem_clock, processor_clock, regfile_clock, clock, reset);
	output imem_clock, dmem_clock, processor_clock, regfile_clock;
	input clock, reset;
	
	wire clock_25, clock_12_5, clock_6_25;
	clock_divider clk0(clock_25, clock, reset);
	clock_divider clk1(clock_12_5, clock_25, reset);
	clock_divider clk2(clock_6_25, clock_12_5, reset);
	
	assign imem_clock = ~clock_25;              // 25Mhz
	assign dmem_clock = ~clock_25;              // 25Mhz
	assign regfile_clock = clock_12_5;          // 12.5Mhz
	assign processor_clock = clock_6_25;        // 6.25Mhz
	
//	wire clock_25;
//	
//	assign imem_clock = ~clock;  //  50MHZ
//	assign dmem_clock = ~clock;  //  50MHZ
//	clock_divider clk_reg(clock_25, clock, reset);	//  25MHz
//	assign regfile_clock = clock_25;
//	clock_divider clk_proc(processor_clock, clock_25, reset);	//  12.5MHz
	
endmodule