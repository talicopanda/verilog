//A mux4to1 made from mux2to1s

//inputs
//SW[7:0]:		data inputs
//SW[9:7]:	 	select signal

//LEDR[0]:		output signal

module mux4to1(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;
	 
	 wire u_v_mux2to1;
	 wire w_x_mux2to1;
	 

    mux2to1 u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[8]),
        .m(u_v_mux2to1)
        );
		  
	mux2to1 u1(
        .x(SW[2]),
        .y(SW[3]),
        .s(SW[8]),
        .m(w_x_mux2to1)
        );
		  
	mux2to1 u2(
        .x(u_v_mux2to1),
        .y(w_x_mux2to1),
        .s(SW[9]),
        .m(LEDR[0])
        );
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
