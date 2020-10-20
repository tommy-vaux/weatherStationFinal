 module findWindSpeed(clk, rotation, speed);
	
	input rotation;
	input clk;
	
	reg [3:0] count;
	
	output [6:0] speed;
	
	reg [6:0] speed;
	
	reg reset;
	reg alreadyReset;
	
	// pi * D = 130 * pi = 408mm
	parameter CIRCUMFRENCE = 408;
	
	
	always @(posedge clk or posedge rotation) begin // run when clk_in presents a rising edge input
			if(clk) begin
				speed = (count * CIRCUMFRENCE) / 278; // speed in km/h (approx, to the cutoff, not nearest, km/h).
				count = 0;
			end else if(rotation) begin
				count = count + 1;
				alreadyReset = 0;
			end
	end
endmodule
