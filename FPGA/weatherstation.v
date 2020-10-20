module weatherstation(clk, reset, waterOut, digits, seg, secClk, out_1, out_2, waterDetected, rotation, btnpressed);
	
	input clk;
	input reset;
	input waterDetected;
	input rotation;
	
	output btnpressed;
	output waterOut;
	
	// DISPLAY
	wire clk_out;
	wire reset_L;
	wire [3:0] bcd;
	wire disp_clk;
	wire [1:0] dispCount;
	output secClk;
	
	wire [3:0] digit0;
	
	
	wire water;
	wire [3:0] muxOut;
	output out_1;
	output out_2;
	
	output [3:0] digits;
	output [6:0] seg;
	
	reg waterOut;
	reg btnpressed;
	// counter
	//clkdivider(.clk_in(clk), .clk_out(clk_out));
	//simple_DFF(.clk(clk), .in_1(clk_out), .reset(reset_L), .out_1(out_1));
	//counter(.clk_in(out_1), .cnt(bcd));
	
	// display refresh
	clkdivider(.clk_in(clk), .clk_out(clk_out));
	simple_DFF(.clk(clk), .in_1(clk_out), .reset(reset_L), .out_1(out_1));
	sequencerTwoBit(.clk(out_1), .out(dispCount));
	secondClk(.clk_in(clk), .clk_out(secClk));
	findWindSpeed(.clk(secClk), .rotation(rotation), .speed(digit0));
	displayMux(.digit0(digit0),.digit1(4'd0),.digit2(4'd0),.digit3(4'd0), .sel(dispCount), .out(muxOut));
	//dispmux(.clock(clk_out),.data0x(4'd1),.data1x(4'd2),.data2x(4'd3),.data3x(4'd4),.sel(dispCount),.result(muxOut));
	
	// actual display output
	sevenseg(.bcd(muxOut), .seg(seg));
	decoderTwoBit(.clk(out_1), .s(dispCount), .out(digits));
	watersensor(.clk(clk_out), .water(waterDetected));
	
	always @(posedge clk_out) begin
		waterOut = water;
		btnpressed = rotation;

	end
	
	

endmodule