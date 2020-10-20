module decoderTwoBit(s, out);
	input [1:0] s;
	output [3:0] out;
	
	assign out[0] = !(!s[1] & !s[0]);
	assign out[1] = !(!s[1] & s[0]);
	assign out[2] = !(s[1] & !s[0]);
	assign out[3] = !(s[1] & s[0]);
	
endmodule