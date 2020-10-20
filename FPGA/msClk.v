module ms_Clk(clk_in, clk_out);

	parameter DIVISOR = 16'd50000;
	
	input clk_in;
	output clk_out;
	reg[15:0] counter = 16'd0; // 16 bit counter, initialised to 0
	
	always @(posedge clk_in)
	begin
		counter <= counter + 16'd1;
		if(counter >= (DIVISOR-1))
			counter <= 16'd0;
	end
	
	assign clk_out = (counter<DIVISOR/2) ? 1'b0 : 1'b1;
	
endmodule
