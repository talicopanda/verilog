// Animates a 4x4 square with given colour on the screen

//inputs//inputs 
//KEY[0]:		reset (active low)
//KET[1]:		draw (active low)
//SW[9:7]:		specify the color
//SW[6:0]:		input coordinates (X,Y)

//To set a value for X, set SW[6:0] to that value and then press KEY[3] to load the register with the X value. 
//Then change switches so that they represent the value of Y and the colour desired.
//The filled square should be drawn when KEY[1] is pressed.

//outputs
// on the VGA monitor
module square_animation
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire colour_reset;
	wire [2:0] colour;
		
	wire [7:0] x;
	wire [6:0] y;
	
	wire ld_x;
	
	wire go;
	assign go = ~KEY[3];
	
	wire draw;
	assign draw = ~KEY[1];
	
	wire writeEn;
	
	wire clk;
	assign clk = CLOCK_50;
	
	wire increment;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    datapath d0(clk, resetn, increment, colour_reset, SW[9:0], ld_x, ld_y, writeEn, x, y, colour);
	 
	FSM_controller c0(clk, go, draw, writeEn, resetn, ld_x, ld_y, colour_reset, increment);

    
endmodule


module datapath(clk, resetn, increment, colour_reset, data_in, ld_x, ld_y, enable, x_out, y_out, colour_out);
    input clk;
    input resetn;
	input increment;
	input colour_reset;
    input [9:0] data_in;
    input ld_x;
	input ld_y;
	input enable;
    output reg [7:0] x_out;
	output reg [6:0] y_out;
	output reg [2:0] colour_out;
	
	reg [3:0] counter;
	reg [7:0] x;
	reg [6:0] y;
	reg [2:0] colour_internal;
	reg direction;

    // Input logic
    always @ (posedge clk) begin
        if (!resetn) begin
			x <= 8'd0;
			y <= 8'd0;
            x_out <= 8'd0; 
			y_out <= 7'd0;
			counter <= 4'b0;
        end
        else begin
			if (increment) begin
				if (x == 8'b01111011)
					direction = 1'b0;
				if (x == 8'b00000000)
					direction = 1'b1;
			
				counter <= 4'b0000;
				colour_out <= colour_internal;
				if (direction) begin
					x <= x + 1;
					y <= y + 1;
				end
				else begin
					x <= x - 1;
					y <= y - 1;
				end
			end
			if (colour_reset)
				colour_out <= 3'b000;
            if (ld_x) begin
                x <= {1'b0, data_in[6:0]};
				x_out <= {1'b0, data_in[6:0]};
			end
			else if (ld_y) begin
                y <= data_in[6:0];
				y_out <= data_in[6:0];
				colour_out <= data_in[9:7];
				colour_internal <= data_in[9:7];
			end
			if (enable) begin
				x_out <= {1'b0, x + counter[1:0]};
				y_out <= y + counter[3:2];
				counter <= counter + 1;
			end
        end
    end
    
endmodule


module FSM_controller(clk, go, draw, enable, resetn, ld_x, ld_y, colour_reset, increment);
	input clk, go, draw, resetn;
	output reg ld_x, ld_y, colour_reset, increment, enable;
	
	reg [24:0] counter;
	reg [4:0] current_state, next_state; 
	
	localparam  S_LOAD_X        = 5'd0,
                S_LOAD_X_WAIT   = 5'd1,
				S_LOAD_Y        = 5'd2,
                S_CYCLE_0       = 5'd3,
                S_CYCLE_1       = 5'd4,
                S_CYCLE_2       = 5'd6,
				S_CYCLE_3       = 5'd7,
                S_CYCLE_4       = 5'd8,
                S_CYCLE_5       = 5'd9,
				S_CYCLE_6       = 5'd10,
                S_CYCLE_7       = 5'd11,
                S_CYCLE_8       = 5'd12,
				S_CYCLE_9       = 5'd13,
                S_CYCLE_10      = 5'd14,
                S_CYCLE_11      = 5'd15,
				S_CYCLE_12      = 5'd16,
                S_CYCLE_13      = 5'd17,
                S_CYCLE_14      = 5'd18,
				S_CYCLE_15      = 5'd19,
				S_CYCLE_16		= 5'd20,
				S_CLEAR			= 5'd21,
				S_NEXT_DRAW     = 5'd22;
	
	// current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
		  begin
            current_state <= S_LOAD_X;
			counter <= 25'b0;
		  end
        else
		  begin
            current_state <= next_state;
			if (current_state == S_CLEAR)
				counter <= counter + 1'b1;
			if (current_state == S_CYCLE_0)
				counter <= 25'b0;
		  end
    end // state_FFS
	
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y; // Loop in current state until go signal goes low
				S_LOAD_Y: next_state = draw ? S_CYCLE_0 : S_LOAD_Y;
                S_CYCLE_0: next_state = S_CYCLE_1; 
				S_CYCLE_1: next_state = S_CYCLE_2; 
				S_CYCLE_2: next_state = S_CYCLE_3; 
				S_CYCLE_3: next_state = S_CYCLE_4; 
				S_CYCLE_4: next_state = S_CYCLE_5; 
				S_CYCLE_5: next_state = S_CYCLE_6; 
				S_CYCLE_6: next_state = S_CYCLE_7; 
				S_CYCLE_7: next_state = S_CYCLE_8; 
				S_CYCLE_8: next_state = S_CYCLE_9; 
				S_CYCLE_9: next_state = S_CYCLE_10; 
				S_CYCLE_10: next_state = S_CYCLE_11; 
				S_CYCLE_11: next_state = S_CYCLE_12;
				S_CYCLE_12: next_state = S_CYCLE_13; 
				S_CYCLE_13: next_state = S_CYCLE_14; 
				S_CYCLE_14: next_state = S_CYCLE_15;
				S_CYCLE_15: next_state = S_CYCLE_16;
                S_CYCLE_16: next_state = colour_reset ? S_NEXT_DRAW : S_CLEAR;
				S_CLEAR: begin
					if (counter == 25'b0101111101011110000011111)
						next_state = S_CYCLE_0;
					else
						next_state = S_CLEAR;
					end
					S_NEXT_DRAW: next_state = S_CYCLE_0;
            default: next_state = S_LOAD_X;
        endcase
    end 
	
	always@(*)
	begin: enable_signals
		ld_x = 1'b0;
        ld_y = 1'b0;
		enable = 1'b0;
		increment = 1'b0;		
		case(current_state)
			S_LOAD_X: begin
                ld_x = 1'b1;
				colour_reset = 1'b0;
			end
            S_LOAD_Y: ld_y = 1'b1;
            S_CYCLE_0: enable = 1'b1;
            S_CYCLE_1: enable = 1'b1;
			S_CYCLE_2: enable = 1'b1;
			S_CYCLE_3: enable = 1'b1;
			S_CYCLE_4: enable = 1'b1;
			S_CYCLE_5: enable = 1'b1;
			S_CYCLE_6: enable = 1'b1;
			S_CYCLE_7: enable = 1'b1;
			S_CYCLE_8: enable = 1'b1;
			S_CYCLE_9: enable = 1'b1;
			S_CYCLE_10: enable = 1'b1;
			S_CYCLE_11: enable = 1'b1;
			S_CYCLE_12: enable = 1'b1;
			S_CYCLE_13: enable = 1'b1;
			S_CYCLE_14: enable = 1'b1;
			S_CYCLE_15: enable = 1'b1;
			S_CYCLE_15: enable = 1'b1;
			S_CYCLE_16: enable = 1'b1;
			S_CLEAR:
			begin
				colour_reset = 1'b1;
				increment = 1'b0;
			end
			S_NEXT_DRAW: 
			begin
				colour_reset = 1'b0;
				increment = 1'b1;
			end
		// default: (don't need default since we already made sure all of our outputs were assigned a value at the start of the always block)
		endcase
	end
endmodule
	
	
	

	
	
	

