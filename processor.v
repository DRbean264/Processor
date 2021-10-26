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
	
	//  fetch code
	reg [11:0] address_imem;

	always @(posedge clock or posedge reset) begin
		if (reset == 1'b1) begin  //  reset
			address_imem <= 12'd0;
		end 
		else begin
			address_imem <= address_imem + 1'b1;
		end
	end

	//  decode instruction
	wire [4:0] opcode, rs, rt, rd, shamt;
	wire [16:0] immediate;
	wire [31:0] extended;

	assign opcode = q_imem[31:27];
	assign rd = q_imem[26:22];
	assign rs = q_imem[21:17];
	assign rt = q_imem[16:12];
	assign shamt = q_imem[11:7];
	assign immediate = q_imem[16:0];

	assign ctrl_readRegA = rs;
	assign ctrl_readRegB = (Rdst == 1) ? rt : rd;
	assign ctrl_writeReg = (except_sel == 1) ? 5'd30 : rd;

	sign_extension sx(extended, immediate);
	
	//  control bits
	wire [4:0] aluop;
	wire ctrl_writeEnable, ctrl_writeEnable_raw,  ctrl_writeEnable_and_clock;
	wire Rdst, ALUinB, wren_raw, wren, Rwd, JP, BR, EXP, except_sel;
	control_generator c_gen(ctrl_writeEnable_raw, Rdst, ALUinB, wren_raw, Rwd, JP, BR, aluop, EXP, 
	opcode, q_imem[6:2]);
	and write_dmem(wren, wren_raw, ~clock); // the write enable bit of Data Memory
	and write_regfile(ctrl_writeEnable_and_clock, ctrl_writeEnable_raw, clock); // the write enable bit of regfile
	//
	assign ctrl_writeEnable = (except_sel == 1) ? ctrl_writeEnable_raw : ctrl_writeEnable_and_clock;
	// only enable exception bit in the second half cycle and the op is add/sub/addi and overflow happens
	and except_regfile(except_sel, EXP, overflow, ~clock);
	
	//  exception bits
	wire [31:0] exception;
	exception_bits excep(exception, opcode, aluop);
	
	//  execute instruction
	wire [31:0] data_operandB, data_result;
	wire isNotEqual, isLessThan, overflow;

	assign data_operandB = (ALUinB == 1) ? extended : data_readRegB;

	alu alu0(data_readRegA, data_operandB, aluop,
			shamt, data_result, isNotEqual, isLessThan, overflow);

	//  interact with data memory
	assign address_dmem = data_result[11:0];
	assign data = data_readRegB;

	//  write regfile
	wire [31:0] data_writeReg_before_ovf;
	assign data_writeReg_before_ovf = (Rwd == 1) ? q_dmem : data_result;
	assign data_writeReg = (except_sel == 1) ? exception : data_writeReg_before_ovf;
	
	
endmodule