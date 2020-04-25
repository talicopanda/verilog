//Shifter circuit with arithmetic shift and parallel assignment options

//inputs
//SW[7:0]:		input value
//SW[9]:		reset (active low)
//KEY[0]:		clock (active low)
//KEY[1]:		parallel load (active low)
//KEY[2]:		shift right (active low)
//KEY[3]:		ASR (arithmetic shift) (active low)

//LEDR[7:0]:	shifted output


module shifter(SW, KEY, LEDR);
	input [9:0] SW;
	input [3:0] KEY;
	output [7:0] LEDR;
	
	shift s0(
			.load_val(SW[7:0]),
			.asr(KEY[3]),
			.ShiftRight(KEY[2]),
			.load_n(KEY[1]),
			.clk(KEY[0]),
			.reset_n(SW[9]),
			.Q(LEDR[7:0])
			);
			
endmodule

module shift(load_val, asr, ShiftRight, load_n, clk, reset_n, Q);
	input [7:0] load_val;
	input load_n, ShiftRight, asr, clk, reset_n;
	output [7:0] Q;
	
	first_shifter_bit s1( 					//necessary for the ASR option
					.load_val(load_val[7]),
					.asr(asr),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[7])
					);
					
	shifter_bit s2(
					.load_val(load_val[6]),
					.in(Q[7]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[6])
					);
					
	shifter_bit s3(
					.load_val(load_val[5]),
					.in(Q[6]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[5])
					);
					
	shifter_bit s4(
					.load_val(load_val[4]),
					.in(Q[5]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[4])
					);
					
	shifter_bit s5(
					.load_val(load_val[3]),
					.in(Q[4]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[3])
					);
					
	shifter_bit s6(
					.load_val(load_val[2]),
					.in(Q[3]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[2])
					);
					
	shifter_bit s7(
					.load_val(load_val[1]),
					.in(Q[2]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[1])
					);
					
	shifter_bit s8(
					.load_val(load_val[0]),
					.in(Q[1]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[0])
					);

endmodule	

module first_shifter_bit(load_val, asr, shift, load_n, clk, reset_n, out);
	input load_val, asr, shift, load_n, clk, reset_n;
	output out;
	
	wire data_from_other_mux;
	wire data_to_dff;
	
	mux2to1 M1(
				.x(out), //parallel load value
				.y(out & asr),
				.s(shift),
				.m(data_from_other_mux) //outputs to flipflop
				);
				
	mux2to1 M2(
				.x(load_val), //parallel load value
				.y(data_from_other_mux),
				.s(load_n),
				.m(data_to_dff) //outputs to flipflop
				);
				
	flipflop F0(
				.d(data_to_dff), //input to flipflop
				.clk(clk),
				.reset_n(reset_n), //synchronous active low reset
				.Q(out) //output from flipflop
				);
	
endmodule	

module shifter_bit(load_val, in, shift, load_n, clk, reset_n, out);
	input load_val, in, shift, load_n, clk, reset_n;
	output out;
	
	wire data_from_other_mux;
	wire data_to_dff;
	
	mux2to1 M1(
				.x(out), //parallel load value
				.y(in),
				.s(shift),
				.m(data_from_other_mux) //outputs to flipflop
				);
				
	mux2to1 M2(
				.x(load_val), //parallel load value
				.y(data_from_other_mux),
				.s(load_n),
				.m(data_to_dff) //outputs to flipflop
				);
				
	flipflop F0(
				.d(data_to_dff), //input to flipflop
				.clk(clk),
				.reset_n(reset_n), //synchronous active low reset
				.Q(out) //output from flipflop
				);
	
endmodule	
	
module flipflop(d, clk, reset_n, Q);
	input d, clk, reset_n;
	output Q;
	reg Q;
	
	always @(posedge clk)
	
	begin
		if (reset_n == 1'b0)
			Q <= 0;
		else
			Q <= d;
	end
endmodule
	

module mux2to1(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule
