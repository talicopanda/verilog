//Rate Divider that slows down a counter from 50Hz to 1Hz, 0.5Hz and 0,25Hz

//inputs
//SW[1:0]:		chooses the rate desired (00 = Full (50Hz), 01 = 1Hz, 10 = 0.5Hz, 11 = 0.25Hz)
//SW[2]:		parallel load
//SW[9]:		clear the count (active low)
//CLOCK_50 		50Hz clock

//output
//HEX0			total count

module automatic_counter_rate_divider(SW, CLOCK_50, HEX0);
	input [9:0] SW; 
	input CLOCK_50;
	output [6:0] HEX0;
	wire [3:0] Q;
	
	flash_counter fc(SW[1:0], SW[2], CLOCK_50, SW[9], Q);
	
	hex h0(Q, HEX0);
	
endmodule

module flash_counter(SW, par_load, clk, clear, Q);
	input [1:0] SW;
	input par_load, clk, clear;
	
	output [3:0] Q;
	
	wire enable;

	choose_rate cr(SW[1:0], par_load, clk, clear, enable);
	
	counter c(enable, clk, clear, Q); //output
	
endmodule

module counter(enable, clk, clear, Q);
	input enable, clk, clear;
	output [3:0] Q;
	reg [3:0] Q;
	
	always @(posedge clk)
	begin
		if(clear == 1'b0)
			Q <= 4'b0;
		else if(enable == 1'b1)
			Q <= Q + 1'b1;
		else if(enable == 1'b0)
			Q <= Q;
	end
endmodule
	

module choose_rate(SW, par_load, clk, clear, Enable);
	input [1:0] SW;
	input par_load, clk, clear;
	output Enable;
	
	reg Enable;
	
	wire [27:0] result00, result01, result10, result11;
	
	//50 MHz
	rate_divider rd00(28'b0000000000000000000000000010, par_load, 1'b1, clk, clear, result00);
	
	//1 Hz (d = 49,999,999)
	rate_divider rd01(28'b0010111110101111000001111111, par_load, 1'b1, clk, clear, result01);
	
	//0.5 Hz (d = 99,999,999)
	rate_divider rd10(28'b0101111101011110000011111111, par_load, 1'b1, clk, clear, result10);
	
	//0.25 Hz (d = 199,999,999)
	rate_divider rd11(28'b1011111010111100000111111111, par_load, 1'b1, clk, clear, result11);
	
	always @(*)
	begin
		case(SW[1:0])
			2'b00: Enable = (result00 == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b01: Enable = (result01 == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b10: Enable = (result10 == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			2'b11: Enable = (result11 == 28'b0000000000000000000000000000) ? 1'b1 : 1'b0;
			default: Enable = 1'b0;
		endcase
	end
endmodule

module rate_divider(d, par_load, enable, clk, clear, q);
	input [27:0] d;
	input par_load, enable, clk, clear;
	output [27:0] q;
	reg [27:0] q;
	
	always @(posedge clk)
	begin
		if (clear == 1'b0)
			q <= 28'b0000000000000000000000000000;
		else if (q == 28'b0000000000000000000000000000)
			q <= d;
		else if (enable == 1'b1)
			begin
				if (d == 28'b0000000000000000000000000000)
					q <= d;
				else
					q <= q - 1'b1;
			end
		else if (par_load == 1'b1)
			q <= d;
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


