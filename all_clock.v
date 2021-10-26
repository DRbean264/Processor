module all_clock(imem_clock, dmem_clock, processor_clock, regfile_clock, clock, reset);
	output imem_clock, dmem_clock, processor_clock, regfile_clock;
	input clock, reset;
	
	wire clock_25;
	
	assign dmem_clock = ~clock;
	clock_divider clk_reg(clock_25, clock, reset);	//  25MHz
	assign regfile_clock = clock_25;
	clock_divider clk_proc(processor_clock, clock_25, reset);	//  12.5MHz
	clock_divider clk_imem(imem_clock, clock_25, reset);	//  12.5MHz
	//clock_divider clk_test_reg(regfile_clock, clock_25, reset);  //  12.5MHz
	
endmodule