//Arithmetic Logic Unit (ALU)

//Input		Output
//  0		A+1 with adder
//  1		A+B with adder
//  2		A+B
//  3		A XOR B in the four bits and A OR B in the upper four bits
//  4		Output 1 if any of the 8 bits in either A or B are high , and 0 if all the bits are low 
//  5		Ouput A in the most significant four bits and B in the least significant bits 

//inputs
//SW[7:4]:		A
//SW[3:0]:		B
//KEY[2:0]:		func (active low)

//outputs
//LEDR[7:0]:	ALU output
//HEX0:			B
//HEX2:			A
//HEX1, HEX3:	output 0
//HEX4:			ALU[3:0]
//HEX5:			ALU[7:4]


module arithmetic_logic_unit(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:0] SW;
	input [2:0] KEY;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire [7:0] alu_out;
	
	//outputs B on HEX0
	hex h0(SW[3:0], HEX0);
	
	//outputs A on HEX2
	hex h1(SW[7:4], HEX2);
		
	//set HEX1 and HEX3 to 0
	hex h2(4'b0000, HEX1);
	hex h3(4'b0000, HEX3);
	
	alu a0(
			.A(SW[7:4]),
			.B(SW[3:0]),
			.func(KEY[2:0]),
			.ALUout(alu_out[7:0])
			);
	
	assign LEDR[7:0] = alu_out[7:0];
	
	//set HEX4 to ALUout[3:0]
	hex h4(alu_out[3:0], HEX4);
			
	//set HEX5 to ALUout[7:4]
	hex h5(alu_out[7:4], HEX5);
	
endmodule

module alu(A,B,func,ALUout);
	input [3:0] A;
	input [7:4] B;
	input [2:0] func;
	output [7:0] ALUout;
	
	reg [7:0] ALUout;
	
	wire [3:0] case0;
	wire carry_case0;
	wire [3:0] case1;
	wire carry_case1;
	
	four_bit_adder fba0(
							.a(A),
							.b(4'b0001), 
							.ci(1'b0), 
							.co(carry_case0), 
							.s(case0)
							);
							
	four_bit_adder fba1(
							.a(A), 
							.b(B), 
							.ci(1'b0), 
							.co(carry_case1), 
							.s(case1)
							);
	
	always @(*)
	begin
		case (func)
			3'b000: ALUout = {carry_case0, 3'b0, case0};	//A+1 with adder
			3'b001: ALUout = {carry_case1, 3'b0, case1};	//A+B with adder
			3'b010: ALUout = {4'b0, A + B};					//A+B
			3'b011: ALUout = {A | B, A ^ B};				//A XOR B in the four bits and A OR B in the upper four bits
			3'b100: ALUout = (A | B != 4'b0) ? 8'b1 : 8'b0;	//Output 1 if any of the 8 bits in either A or B are high , and 0 if all the bits are low 
			3'b101: ALUout = {A, B};						//Ouput A in the most significant four bits and B in the least significant bits 
			default: ALUout = 8'b0;
		endcase
	end
endmodule
	

module hex(hex_digit, segments); //hex decoder
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule


module four_bit_adder(a, b, ci, co, s);
	input [3:0] a, b;
	input ci;
	output co;
	output [3:0] s;
	wire c1;
	wire c2;
	wire c3;
	
	fa u0(
		.a(a[0]),
		.b(b[0]),
		.ci(ci),
		.s(s[0]),
		.co(c1)
	);
	
	fa u1(
		.a(a[1]),
		.b(b[1]),
		.ci(c1),
		.s(s[1]),
		.co(c2)
	);
	
	fa u2(
		.a(a[2]),
		.b(b[2]),
		.ci(c2),
		.s(s[2]),
		.co(c3)
	);
	
	fa u3(
		.a(a[3]),
		.b(b[3]),
		.ci(c3),
		.s(s[3]),
		.co(co)
	);
endmodule

module fa(a,b,ci,co,s);
	input a;
	input b;
	input ci;
	output co;
	output s;
	
	wire c1;
	assign c1 = a ^ b;
	
	assign s = c1 ^ ci;
	mux2to1 m0(
		.x(b), 
		.y(ci),
		.s(c1),
		.m(co)
		);
endmodule

module mux2to1(x, y, s, m);
    input x;
    input y;
    input s; 
    output m;
  
    assign m = s & y | ~s & x;

endmodule
