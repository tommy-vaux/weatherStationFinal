module fourInputMux(in, sel, out);

	input [3:0] in;
	input [1:0] sel;
	
	output out;
	
	wire inUp;
	wire inDown;
	wire [1:0] out1;
	
	assign inUp = in >> 2;
	assign inDown = in & 4'b0011;
	
	mux(.in(inUp), .sel(sel[0]), .out(out1[1]));
	mux(.in(inDown), .sel(sel[0]), .out(out1[0]));
	
	mux(.in(out1), .sel(sel[1]), .out(out));
endmodule
	