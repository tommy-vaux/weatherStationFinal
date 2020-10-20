module sequencerTwoBit(clk, out);
	// basically a two bit counter
	input clk;
	output [1:0] out; // setup 2 bit output
	reg [1:0] out = 2'd0; // set cnt to 0 (decimal) and set it up as a register
	
	always @(posedge clk) // run when clk_in presents a rising edge input
		begin
			out <= out + 2'd1;
		end
	

endmodule