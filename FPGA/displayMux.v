module displayMux(digit0, digit1, digit2, digit3, sel, out);
	
	input [3:0] digit0;
	input [3:0] digit1;
	input [3:0] digit2;
	input [3:0] digit3;
	
	input [1:0] sel;
	
	output [3:0] out;
	
	reg [3:0] out;
	
	always @ (sel)
	begin
		case(sel)
			0: out = digit0;
			1: out = digit1;
			2: out = digit2;
			3: out = digit3;
		endcase
	end

endmodule