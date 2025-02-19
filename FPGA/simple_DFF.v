module simple_DFF (clk, in_1, reset, out_1);
	input clk;
	input in_1;
	input reset;
	output out_1;
	
	reg out_1;
	
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				out_1 <= 1'b0;
			else
				out_1 <= in_1;
		end
endmodule 