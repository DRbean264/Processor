module regfile(
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA,
	data_readRegB,
	
	/* debugging */
	register0, register1, register2, register3, register4, register5, register6, register30
//	register14, register15,
//	register16, register17, register18, register19, register20, register21, register22, register23,
//	register24, register25,
//	register26, register27, register28, register29, 
	//register31
);
	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	output [31:0] data_readRegA, data_readRegB;

	/* debugging */
	output [31:0] register0, register1, register2, register3, register4, register5, register6, register30;
//	register5, register6, register7,
//	register8, register9, register10, register11, register12, register13, register14, register15,
//	register16, register17, register18, register19, register20, register21, register22, register23,
//	register24, 
//	register26, register27, register28, register29, 
//	register31;
	
	
	reg[31:0] registers[31:0];
	
	/* debugging */
	assign register0 = registers[0];
	assign register1 = registers[1];
	assign register2 = registers[2];
	assign register3 = registers[3];
	assign register4 = registers[4];
	assign register5 = registers[5];
	assign register6 = registers[6];
//	assign register7 = registers[7];
//	assign register8 = registers[8];
//	assign register9 = registers[9];
//	assign register10 = registers[10];
//	assign register11 = registers[11];
//	assign register12 = registers[12];
//	assign register13 = registers[13];
//	assign register14 = registers[14];
//	assign register15 = registers[15];
//	assign register16 = registers[16];
//	assign register17 = registers[17];
//	assign register18 = registers[18];
//	assign register19 = registers[19];
//	assign register20 = registers[20];
//	assign register21 = registers[21];
//	assign register22 = registers[22];
//	assign register23 = registers[23];
//	assign register24 = registers[24];
//	assign register25 = registers[25];
//	assign register26 = registers[26];
//	assign register27 = registers[27];
//	assign register28 = registers[28];
//	assign register29 = registers[29];
	assign register30 = registers[30];
//	assign register31 = registers[31];
	
	
	always @(posedge clock or posedge ctrl_reset)
	begin
		if(ctrl_reset)
			begin
				integer i;
				for(i = 0; i < 32; i = i + 1)
					begin
						registers[i] = 32'd0;
					end
			end
		else
			if(ctrl_writeEnable && ctrl_writeReg != 5'd0)
				registers[ctrl_writeReg] = data_writeReg;
	end
	
//	assign data_readRegA = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegA) ? 32'bz : registers[ctrl_readRegA];
//	assign data_readRegB = ctrl_writeEnable && (ctrl_writeReg == ctrl_readRegB) ? 32'bz : registers[ctrl_readRegB];
	assign data_readRegA = registers[ctrl_readRegA];
	assign data_readRegB = registers[ctrl_readRegB];
	
endmodule