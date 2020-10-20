module display(sys_clk, reset, digit0, digit1, digit2, digit3, digits, seg);
	
	// basic inputs
	//input currentDigitID;
	input reset;
	input sys_clk;
	// each digit on the display's value.
	input [3:0] digit0;
	input [3:0] digit1;
	input [3:0] digit2;
	input [3:0] digit3;
	
	// actual outputs to the display
	output [3:0] digits;
	output [6:0] seg;
	
	// display clock value (passed through the flip flop)
	wire clk;
	wire disp_clk;
	
	// for swapping between digits on the 7 segment display
	wire [3:0] currentDigitValue;
	wire [1:0] currentDigitID;
	
	//clk divider to create display refresh clk
	clkdivider(.clk_in(sys_clk), .clk_out(clk));
	
	// flip flop that holds the current clk value
	simple_DFF(.clk(sys_clk), .in_1(clk), .reset(!reset), .out_1(disp_clk)); 
	// sequencer that is used to iteratre through the different digits on the display (as only one can be changed at a time)
	sequencerTwoBit(.clk(disp_clk), .out(currentDigitID));
	// uses the sequence created by the sequencer to select the correct digit to display at this time
	displayMux(.digit0(digit0), .digit1(digit1), .digit2(digit2), .digit3(digit3), .sel(currentDigitID), .out(currentDigitValue));
	
	// generate the 7 segment output, and send it to the 7 segment display
	sevenseg(.bcd(currentDigitValue), .seg(seg));
	// actually tell the 7 segment display which segment we are editing/to turn on this clock cycle
	decoderTwoBit(.s(currentDigitID), .out(digits));
	
	

endmodule
