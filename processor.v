/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB,                   // I: Data from port B of regfile
	 
	 /* debugging */
	 //,opcode, rs, rt, rd, shamt, aluop, immediate
);
	/* debugging */
	//output [4:0] opcode, rs, rt, rd, shamt, aluop;
	//output [16:0] immediate;
	

	// Control signals
	input clock, reset;

	// Imem
	output [11:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [11:0] address_dmem;
	output [31:0] data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */
	
	//  fetch code wire declaration
	reg [11:0] address_imem;
	reg [11:0] address_imem_next;
	
	//  decode instruction wire declaration
	wire [4:0] opcode, rs, rt, rd, shamt;
	wire [16:0] immediate;
	wire [31:0] extended;
	wire [26:0] T;
	wire [31:0] UX_T;
	wire [4:0] ctrl_writeReg0;
	
	//  control bits wire declaration
	wire [4:0] aluop;
	wire ctrl_writeEnable, ctrl_writeEnable_raw,  ctrl_writeEnable_and_clock;
	wire Rdst, ALUinB, wren_raw, wren, Rwd, JP, EXP, except_sel, BNE, JAL, JR, BLT, BEX, SETX;
	wire [31:0] exception;
	
	//  execution wire declaration
	wire [31:0] data_operandB, data_result;
	wire isNotEqual, isBiggerThan, overflow;
	
	//  write regfile wire declaration
	wire [31:0] data_writeReg_before_ovf;
	wire [31:0] data_writeReg_before_jal, data_writeReg_jal;
	wire [31:0] data_writeReg_before_setx;
	
	//  fetch code
	always @(*) begin
		address_imem_next <= address_imem + 12'd1;
		if (JP == 1'b1 || JAL == 1'b1)
			address_imem_next <= T[11:0];
		else if (BNE == 1'b1 && isNotEqual == 1'b1)
			address_imem_next <= address_imem + 12'd1 + extended[11:0];
		else if (JR == 1'b1)
			address_imem_next <= data_readRegB[11:0];
		else if (BLT == 1'b1 && isBiggerThan == 1'b1)
			address_imem_next <= address_imem + 12'd1 + extended[11:0];
		else if (BEX == 1'b1 && data_readRegA != 32'd0)
			address_imem_next <= T[11:0];
//		else
//			address_imem_next <= address_imem + 12'd1;
	end
	
	always @(posedge clock or posedge reset) begin
		if (reset == 1'b1) begin  //  reset
			address_imem <= 12'b111111111111;
		end 
		else begin
			address_imem <= address_imem_next;
		end
	end

	//  decode instruction
	assign opcode = q_imem[31:27];
	assign rd = q_imem[26:22];
	assign rs = q_imem[21:17];
	assign rt = q_imem[16:12];
	assign shamt = q_imem[11:7];
	assign immediate = q_imem[16:0];
	assign T = q_imem[26:0];
	assign UX_T[26:0] = T;
	assign UX_T[31:27] = 5'd0;

	assign ctrl_readRegA = (BEX == 1) ? 5'd30 : rs;
	assign ctrl_readRegB = (Rdst == 1) ? rt : rd;
	assign ctrl_writeReg0 = (JAL == 1) ? 5'd31 : rd;
	assign ctrl_writeReg = (except_sel == 1 || SETX == 1) ? 5'd30 : ctrl_writeReg0;

	sign_extension sx(extended, immediate);
	
	//  control bits
	control_generator c_gen(ctrl_writeEnable_raw, Rdst, ALUinB, wren_raw, Rwd, JP, aluop,
	EXP, opcode, q_imem[6:2], BNE, JAL, JR, BLT, BEX, SETX);
	
	and write_dmem(wren, wren_raw, ~clock); // the write enable bit of Data Memory
	and write_regfile(ctrl_writeEnable_and_clock, ctrl_writeEnable_raw, clock); // the write enable bit of regfile
	// only enable write to regfile in the second half cycle when an exception happens
	assign ctrl_writeEnable = (except_sel == 1) ? ctrl_writeEnable_raw : ctrl_writeEnable_and_clock;
	// only enable exception bit in the second half cycle and the op is add/sub/addi and overflow happens
	and except_regfile(except_sel, EXP, overflow, ~clock);
	
	//  exception bits
	exception_bits excep(exception, opcode, aluop);
	
	//  execute instruction
	assign data_operandB = (ALUinB == 1) ? extended : data_readRegB;

	alu alu0(data_readRegA, data_operandB, aluop,
			shamt, data_result, isNotEqual, isBiggerThan, overflow);

	//  interact with data memory
	assign address_dmem = data_result[11:0];
	assign data = data_readRegB;

	//  write regfile
	assign data_writeReg_jal[11:0] = address_imem + 12'd1;
	assign data_writeReg_jal[31:12] = 10'd0;
	assign data_writeReg_before_ovf = (Rwd == 1) ? q_dmem : data_result;
	assign data_writeReg_before_setx = (except_sel == 1) ? exception : data_writeReg_before_ovf;
	assign data_writeReg_before_jal = (SETX == 1) ? UX_T : data_writeReg_before_setx;
	assign data_writeReg = (JAL == 1) ? data_writeReg_jal : data_writeReg_before_jal;
	
endmodule