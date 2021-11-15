module control_generator(ctrl_writeEnable, Rdst, ALUinB, wren, Rwd, JP, aluop,
 EXP, opcode, raw_aluop, BNE, JAL, JR, BLT, BEX, SETX);
	input [4:0] opcode, raw_aluop;
	output ctrl_writeEnable, Rdst, ALUinB, wren, Rwd, JP, EXP, BNE, JAL, JR, BLT, BEX, SETX;
	output reg [4:0] aluop;
	
	reg add_sub, addi, and_or, sll_sra, lw, sw, j, bne, jal, jr, blt, bex, setx;
	
	always @(*) begin
		add_sub <= 1'b0;
		addi <= 1'b0;
		and_or <= 1'b0;
		sll_sra <= 1'b0;
		lw <= 1'b0;
		sw <= 1'b0;
		j <= 1'b0;
		bne <= 1'b0;
		jal <= 1'b0;
		jr <= 1'b0;
		blt <= 1'b0;
		bex <= 1'b0;
		setx <= 1'b0;
		aluop <= 5'b00000;
		
		if (opcode == 5'b00000) begin  //  add/sub/and/or/sll/sra
			aluop <= raw_aluop;
			if (raw_aluop == 5'b00000 || raw_aluop == 5'b00001)  //  add/sub
				add_sub <= 1'b1;
			else if (raw_aluop == 5'b00010 || raw_aluop == 5'b00011)  //  and/or
				and_or <= 1'b1;
			else if (raw_aluop == 5'b00100 || raw_aluop == 5'b00101)  //  sll/sra
				sll_sra <= 1'b1;
		end
		else if (opcode == 5'b00101)  //  addi
			addi <= 1'b1;
		else if (opcode == 5'b01000)  //  lw
			lw <= 1'b1;
		else if (opcode == 5'b00111)  //  sw
			sw <= 1'b1;
		else if (opcode == 5'b00010)  //  bne
			bne <= 1'b1;
		else if (opcode == 5'b00001)  //  j
			j <= 1'b1;
		else if (opcode == 5'b00011)  //  jal
			jal <= 1'b1;
		else if (opcode == 5'b00100)  //  jr
			jr <= 1'b1;
		else if (opcode == 5'b00110)  //  blt
			blt <= 1'b1;
		else if (opcode == 5'b10110)  //  bex
			bex <= 1'b1;
		else if (opcode == 5'b10101)  //  setx
			setx <= 1'b1;
	end
	
	assign JP = j;
	assign wren = sw;
	or or_reg_wren(ctrl_writeEnable, add_sub, addi, lw, and_or, sll_sra, jal, setx);
	assign Rwd = lw;
	or or_rdst(Rdst, add_sub, and_or);
	or or_aluinB(ALUinB, sw, addi, lw);
	or or_exception(EXP, add_sub, addi);
	assign BNE = bne;
	assign JAL = jal;
	assign JR = jr;
	assign BLT = blt;
	assign BEX = bex;
	assign SETX = setx;
	
endmodule