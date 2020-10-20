module SPI_Module(clk, sck, mosi, miso, windsensor, watersensor, cs, done, data_recieved);

	input clk; // system clock
	input sck; // SPI slave clock
	input mosi; // Data input
	input cs; // chip select/slave select
	input [7:0] windsensor; // the data we need to send to the arduino.
	input [7:0] watersensor;
	
	output reg [7:0] miso; // Data output
	output done; // finished send/recieve
	output data_recieved; // only made an output for debugging purposes.
	
	// syncronise the system clock with the SPI clock
	reg [2:0] sck_record; // store 3 previous states of SCK (SPI Slave clock)
	always @(posedge clk)
		sck_record <= { sck_record[1:0], sck };
	
	// synchronise chip select or slave select (SS) on Arduino with system clock.
	reg [2:0] cs_record; // store 3 previous states of CS (chip select)
	always @(posedge clk)
		cs_record <= { cs_record[1:0], cs };
	
	// controlling the SPI interface
	reg current_state; // are we running the interface atm?
	reg [3:0] bitcounter; // bit we are currently reading
	reg [7:0] data_recieved; // the actual data recieved from the Arduino (in this case it will be a 0 or 1 but in a byte). 
	
	
	// sample mosi at each sclk rising edge
	// handle start or message, sending a response back, and stop of message.
	always @(posedge clk) begin
		if(cs_record[2:1] == 2'b01) // rising edge (end)
		begin 
			current_state <= 0; // stop listening
			bitcounter <= 0; // reset bit counter
		end
		else if(cs_record[2:1] == 2'b10) // falling edge (start)
		begin
			bitcounter <= 0; // reset bit counter
			current_state <= 1; // start listening
		end
		else if(current_state == 1'b1 && sck_record[2:1] == 2'b01) // read data from master
		begin
			if(bitcounter < 8) begin
				data_recieved = data_recieved << 1; // move up the data already in the register up one bit
				data_recieved[0] = mosi; // read in this bit
				bitcounter <= bitcounter + 1; // get ready to read next bit
			end else begin
				if(data_recieved == 2) begin
					miso = windsensor[bitcounter - 8];
					bitcounter <= bitcounter + 1;
			end else if(data_recieved == 3) begin
					miso = watersensor[bitcounter - 8];
					bitcounter <= bitcounter + 1;
				end
			end
		end
	end
	
	wire done = (bitcounter == 16); // first 8 bits = recieve command, last 8 send command
	
	

endmodule
