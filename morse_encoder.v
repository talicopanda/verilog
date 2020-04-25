//Morse encoder with rate divider

//inputs
//SW[2:0]:		letter from s to z (000 = s ... 111 = z)
//KEY[0]:		reset (active low)
//KEY[1]:	 	process input (go)

//output
//LEDR[0]		output morse code


module morse_encoder(SW, KEY, CLOCK_50, LEDR);
	input [2:0] SW; 
	input [1:0] KEY;
	input CLOCK_50;
	output [0:0] LEDR;
	
	morse m(SW[2:0], KEY[1], CLOCK_50, KEY[0], LEDR[0]);
endmodule

module morse(letter, key, clk, clear, flash);
	input [2:0] letter;
	input key, clk, clear;
	
	wire [13:0] morse_code;
	
	output flash;
	
	wire [27:0] result;
	
	lut l(letter, morse_code);
	
	//2 Hz (d = 24,999,999)
	rate_divider rd(28'b0001011111010111100000111111, clk, clear, result);
	
	assign enable = (result == 28'b0000000000000000000000000000 ? 1 : 0);

	shifter s(morse_code, 1'b1, key, enable, clear, flash);
	
endmodule


module lut(letter,LUTout);
	input [2:0] letter;
	output [13:0] LUTout;
	
	reg [13:0] LUTout;
	
	always @(*)
	begin
		case (letter)
			3'b000: LUTout = 14'b00000000010101;
			3'b001: LUTout = 14'b00000000000111;
			3'b010: LUTout = 14'b00000001110101;
			3'b011: LUTout = 14'b00000111010101;
			3'b100: LUTout = 14'b00000111011101;
			3'b101: LUTout = 14'b00011101010111;
			3'b110: LUTout = 14'b01110111010111;
			3'b111: LUTout = 14'b00010101110111;
			default: LUTout = 14'b00000000000000;
		endcase
	end
endmodule

module rate_divider(d, clk, clear, q);
	input [27:0] d;
	input clk, clear;
	output [27:0] q;
	reg [27:0] q;
	
	always @(posedge clk)
	begin
		if (clear == 1'b0)
			q <= 28'b0000000000000000000000000000;
		else if (q == 28'b0000000000000000000000000000)
			q <= d;
		else if (d == 28'b0000000000000000000000000000)
			q <= d;
		else
			q <= q - 1'b1;
	end
endmodule

module shifter(load_val, ShiftRight, load_n, clk, reset_n, shift_out);
	input [13:0] load_val;
	input load_n, ShiftRight, clk, reset_n;
	wire [13:0] Q;
	
	output shift_out;
	
	//Q[0] to LEDR[0]
	assign shift_out = Q[0];

	shifter_bit s1(
					.load_val(load_val[13]),
					.in(1'b0),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[13])
					);
	
	shifter_bit s2(
					.load_val(load_val[12]),
					.in(Q[13]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[12])
					);
					
	shifter_bit s3(
					.load_val(load_val[11]),
					.in(Q[12]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[11])
					);
	
	shifter_bit s4(
					.load_val(load_val[10]),
					.in(Q[11]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[10])
					);
	
	shifter_bit s5(
					.load_val(load_val[9]),
					.in(Q[10]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[9])
					);
					
	shifter_bit s6(
					.load_val(load_val[8]),
					.in(Q[9]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[8])
					);
					
	shifter_bit s7(
					.load_val(load_val[7]),
					.in(Q[8]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[7])
					);
					
	shifter_bit s8(
					.load_val(load_val[6]),
					.in(Q[7]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[6])
					);
					
	shifter_bit s9(
					.load_val(load_val[5]),
					.in(Q[6]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[5])
					);
					
	shifter_bit s10(
					.load_val(load_val[4]),
					.in(Q[5]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[4])
					);
					
	shifter_bit s11(
					.load_val(load_val[3]),
					.in(Q[4]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[3])
					);
					
	shifter_bit s12(
					.load_val(load_val[2]),
					.in(Q[3]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[2])
					);
					
	shifter_bit s13(
					.load_val(load_val[1]),
					.in(Q[2]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[1])
					);
					
	shifter_bit s14(
					.load_val(load_val[0]),
					.in(Q[1]),
					.shift(ShiftRight),
					.load_n(load_n),
					.clk(clk),
					.reset_n(reset_n),
					.out(Q[0])
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



