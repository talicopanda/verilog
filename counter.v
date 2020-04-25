//4-bit counter with t-flipflops

//inputs
//SW[0]:		clear the counter (active low)
//SW[1]:		toggles (increase) the counter
//KEY[0]: 		input clock

//HEX0:			least significant bits of counter (Q[3:0])
//HEX1: 		most significant bits of counter (Q[7:4])


module counter(SW, KEY, HEX0, HEX1);
	input [1:0] SW; 
	input [0:0] KEY;
	wire [7:0] Q;
	output [6:0] HEX0, HEX1;
	
	count c(.t(SW[1]), .clk(KEY[0]), .clear_b(SW[0]), .Q(Q));
			
	hex h0(.SW(Q[3:0]), .HEX(HEX0));
	hex h1(.SW(Q[7:4]), .HEX(HEX1));
	
endmodule

module count(t, clk, clear_b, Q);
	input t, clk, clear_b;
	output [7:0] Q;
	
	t_flipflop tff0(
					.t(t), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[0])
					);
	
	
	t_flipflop tff1(
					.t(t & Q[0]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[1])
					);
	
	t_flipflop tff2(
					.t(t & Q[0] & Q[1]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[2])
					);
	

	t_flipflop tff3(
					.t(t & Q[0] & Q[1] & Q[2]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[3])
					);
	
	t_flipflop tff4(
					.t(t & Q[0] & Q[1] & Q[2] & Q[3]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[4])
					);
	
	t_flipflop tff5(
					.t(t & Q[0] & Q[1] & Q[2] & Q[3] & Q[4]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[5])
					);
	
	t_flipflop tff6(
					.t(t & Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[6])
					);
	
	t_flipflop tff7(
					.t(t & Q[0] & Q[1] & Q[2] & Q[3] & Q[4]& Q[5] & Q[6]), 
					.clk(clk),
					.clear_b(clear_b),
					.Q(Q[7])
					);
					
endmodule
	


module t_flipflop(t, clk, clear_b, Q);
	input t, clk, clear_b;
	output Q;
	reg Q;
	
	always @(posedge clk, negedge clear_b)
	
	begin
		if (clear_b == 1'b0)
			Q <= 0;
		else
			Q <= Q^t; //TFF behaviour
			//or if(t) Q <= ~Q
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
