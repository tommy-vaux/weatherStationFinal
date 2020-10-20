module binaryToBCD(number, digit0, digit1, digit2, digit3); 
	// no need for digit 3 as we won't get to 1000s anyway, and this leaves it available for debugging purposes.
	// used this as reference https://my.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
	input [12:0] number;
	
	output reg [3:0] digit0;
	output reg [3:0] digit1;
	output reg [3:0] digit2;
	output reg [3:0] digit3;
	
	
	integer increment;
	always @(number)
	begin
		// set 100s, 10s and 1s to 0
		digit3 = 4'd0;
		digit2 = 4'd0;
		digit1 = 4'd0;
		digit0 = 4'd0;
		
		for (increment = 7; increment >= 0; increment = increment - 1)
		begin
			// at 3 to each column if they are greater than 5
			if(digit3 >= 5)
				digit3 = digit3 + 3;
			if(digit2 >= 5)
				digit2 = digit2 + 3;
			if(digit1 >= 5)
				digit1 = digit1 + 3;
			if(digit0 >= 5)
				digit0 = digit0 + 3;
				
			// shift each left one
			digit3 = digit3 << 1;
			digit3[0] = digit2[3];
			digit2 = digit2 << 1;
			digit2[0] = digit1[3];
			digit1 = digit1 << 1;
			digit1[0] = digit0[3];
			digit0 = digit0 << 1;
			digit0[0] = number[increment];
		end
	end

endmodule
