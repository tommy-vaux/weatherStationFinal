module weatherstation_SM(clk, reset, windsensor, watersensor, led1, led2, led3, led4, digits, seg, sclk, miso, mosi, cs);
	
	// INPUTS
	input clk; // actual 50MHz system clock
	// SPI
	input sclk;
	input mosi;
	input cs; // otherwise known as ss (slave select)
	input reset; // the reset button
	input windsensor; // direct input from the wind sensor (on/off once per circumfrence)
	input watersensor; // direct input from water sensor (on/off for yes/no there is/is not water)
	
	// OUTPUTS
	output led1; // displays 1sec clk pulse
	output led2; // displays direct value from wind sensor
	output led3; // displays direct value from water sensor
	output led4; // undecided atm; use for debugging
	
	// SPI
	output miso;
	wire [7:0] commandRecieved;
	wire done;
	
	// new basic flag-based comms system
	reg tooWindy;
	
	// 7 segment display
	output [3:0] digits; // multiplexor to control which digit is being modified on the 7 segment display
	output [6:0] seg; // the actual 7 segment display output value
	reg [1:0] currentDigit;
	
	// State Machine Parameters (names of states)
	parameter idle = 2'b00;
	parameter calcWind = 2'b01; // runs when a new reading is detected
	parameter processAndOutput = 2'b10; // used every 1 second
	parameter resetting = 2'b11; // runs while reset button is pressed, jumps back to calc wind when released.
	
	// state machine variables
	reg [1:0] currentState; // current state of the SM
	
	// wind sensor variables
	// the one rotation speed is a pre-calculated constant which is the wind speed if the sensor makes a full rotation once in a second.
	// it is also the rotation speed multipled by 1024 so that it can be stored as an integer, then reduced to the correct value with bit shifting.
	parameter ONE_ROTATION_SPEED = 1563; //408; // circumfrence of wind sensor - needed to calculate wind speed
	reg [7:0] rotationCount;
	reg [7:0] windSpeed;
	reg gotWindSpeed = 1'b0;
	
	// Clock connections
	wire ms_clk;
	wire s_clk;
	wire disp_clk;
	
	// display connections
	wire [3:0] digit0;
	wire [3:0] digit1;
	wire [3:0] digit2;
	
	// setup both clocks
	ms_clk(.clk_in(clk), .clk_out(ms_clk)); // ms clock for main process
	// second clock, which is run based on the ms_clk
	parameter S_DIVISOR = 12'd2000; // reset point
	reg[11:0] s_counter = 12'd0; // variable which stores number of ms since last run
	assign s_clk = (s_counter<S_DIVISOR/2) ? 1'b0 : 1'b1; // convert 1ms pulse to clock output (for the led to use)
	
	// SPI Communication
	SPI_Module(.clk(clk), .sck(sck), .mosi(mosi), .miso(miso), .windsensor(windSpeed), .watersensor(watersensor), .cs(cs), .done(done), .data_recieved(commandRecieved));
	
	//secondClk(.clk_in(clk), .clk_out(s_clk)); // s clock for swapping states at the right time
	// update the display
	binaryToBCD(.number(windSpeed), .digit0(digit0), .digit1(digit1), .digit2(digit2));
	display(.sys_clk(clk), .reset(reset), .digit0(digit0), .digit1(digit1), .digit2(digit2), .digit3(commandRecieved), .digits(digits), .seg(seg));	

	
	// BASIC OUTPUT (so we can see what the FPGA can see
	assign led1 = s_clk;
	assign led2 = !windsensor; // invert because FPGA is active low
	assign led3 = !watersensor;
	assign led4 = tooWindy;
	//assign led4 = 1; // active low, so 1 = off (we aren't using this LED atm)
	
	// State Machine
	always @(posedge ms_clk or negedge reset)
	begin
		if(!reset) begin
			currentState <= resetting;
		end else
			begin
				case(currentState)
					//idle:
						// do nothing; idle (and maybe iterate thru display)
						//
					calcWind:
						begin
							rotationCount <= rotationCount + 1;
							currentState <= idle;
						end
					processAndOutput:
						begin
							windSpeed <= ((rotationCount * ONE_ROTATION_SPEED) >> 10);// calc wind speed
							// send to Arduino
							rotationCount <= 0; 	// reset the count
							currentState <= idle; // go back to idle
							if(windSpeed > 3)
								tooWindy = 0; // active low so inversed
							else
								tooWindy = 1; // active low so inversed
						end
					resetting:
						begin
							rotationCount <= 0;
							windSpeed <= 0;
							currentState <= idle;
						end
					//default:
						//currentState <= idle;
				endcase		
				currentDigit <= currentDigit + 2'd1;
				s_counter <= s_counter + 12'd1;
				
				// CONTROLLERS THAT WERE SECONDARY ALWAYS BLOCKS
				// increment second clk
				if(s_counter >= (S_DIVISOR - 1))
				begin
					s_counter <= 12'd0;
					currentState <= processAndOutput;
				end
				// get wind sensor output (which we don't want to run unless we are NOT resetting the speed (aka it's not at 1 second).
				else if(windsensor && (!gotWindSpeed))
				begin
					currentState <= calcWind;
					gotWindSpeed <= 1'b1;
				end
				else if(!windsensor)
					gotWindSpeed <= 1'b0;
			end
	end
	
	
	// ERROR is basically that I am writing to current state from multiple always blocks - I can read from many, but I can only write in one. (I am currently writing in many, reading in one)
	
	// Second Counter (controls SM states)
	/*always @(posedge s_clk)
	begin
		currentState <= processAndOutput;
	end*/
	
	// wind sensor (needs positive edge so done here)
	/*always @(posedge windsensor)
	begin
		currentState <= calcWind;
	end*/
	
	
endmodule
