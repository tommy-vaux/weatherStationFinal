module counter(clk_in, cnt);
	input clk_in;
	output [3:0] cnt; // setup 4 bit output
	reg [3:0] cnt = 4'd0; // set cnt to 0 (decimal) and set it up as a register
	
	parameter LAST = 4'd9; // set LAST to 9 (4 bits)
	
	always @(posedge clk_in) // run when clk_in presents a rising edge input
		begin
			cnt <= cnt + 4'd1;
			if(cnt >= (LAST))
				cnt <= 4'd0; // reset counter to 0
		end
	endmodule
	
	
	
	
	