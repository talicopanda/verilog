//4-bit ripple carry adder 

//inputs
//SW[8]:		 carry in
//SW[7:4]:		 A
//SW[3:0]:		 B

//output
//LEDR[3:0]:	 A+B


module four_bit_ripple_carry_adder(LEDR, SW);
	input [9:0] SW;
	output [9:0] LEDR;
	
	four_bit_adder fba0(
				.a(SW[7:4]),
				.b(SW[3:0]),
				.ci(SW[8]),
				.co(LEDR[4]),
				.s(LEDR[3:0])
				);
	
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

module fa(a,b,ci,co,s); //full adder
	input a;
	input b;
	input ci;
	output co;
	output s;
	
	wire c1;
	assign c1 = a ^ b;
	assign s = c1 ^ ci;
	
	mux2to1 mux(
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