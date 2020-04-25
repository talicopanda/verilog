//mux2to1

//inputs
//SW[2:0]:		data inputs
//SW[9]:		select signal

//outputs
//LEDR[0]:		output display

module mux2to1(LEDR, SW);
    input [9:0] SW;
    output [9:0] LEDR;

    mux u0(
        .x(SW[0]),
        .y(SW[1]),
        .s(SW[9]),
        .m(LEDR[0])
        );
endmodule

module mux(x, y, s, m);
    input x; //selected when s is 0
    input y; //selected when s is 1
    input s; //select signal
    output m; //output
  
    assign m = s & y | ~s & x;
    // OR
    // assign m = s ? y : x;

endmodule
