module secondClk(clk_in, clk_out);
	parameter DIVISOR = 28'd50000000; 

	input clk_in;
	output clk_out;
	reg[25:0] counter = 26'd0; // 26 bit counter register, intiallised to 0
	
	always @(posedge clk_in)
	begin 
		counter <= counter + 28'd1;
		if(counter >= (DIVISOR-1))
			counter <= 28'd0;
	end
	
	assign clk_out = (counter<DIVISOR/2) ? 1'b0 : 1'b1;

endmodule
