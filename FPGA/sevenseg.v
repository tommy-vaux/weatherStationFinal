// 7 segment display in verilog, based on system outlined in modules

module sevenseg(bcd, seg);
	//setup inputs and outputs
	input [3:0] bcd; // 4 bit input
	output [6:0] seg; // 7 segment output value
	
	reg [6:0] seg; // set up the seg register (variable)
	
	always @(bcd) // always runs
	begin
		case (bcd)
			0 : seg = 7'b0000001;
			1 : seg = 7'b1001111;
			2 : seg = 7'b0010010;
			3 : seg = 7'b0000110;
			4 : seg = 7'b1001100;
			5 : seg = 7'b0100100;
			6 : seg = 7'b0100000;
			7 : seg = 7'b0001111;
			8 : seg = 7'b0000000;
			9 : seg = 7'b0000100;
			// turn off the 7 seg char if invalid input
			default : seg = 7'b1111111;
		endcase
	end
	
	//assign en_L = 1'b0; // turn on the 7 seg display digit (this is the digit)
	
endmodule
			
	