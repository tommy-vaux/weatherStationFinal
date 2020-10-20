module watersensor (clk, pin, water);
	input pin;
	input clk;
	output water;
	
	reg water;

	always @(posedge clk)
		begin
			if(!pin)
				water <= 1'b1;
			else
				water <= 1'b0;
		end
endmodule