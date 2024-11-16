module motor_Logic_tb;

  //internal signals
  logic Reset;
  logic CLK_50;
  logic D;
  logic hallIn; // we will clock this to simulate a spinning motor
  // [10..0] is the number the counter will count up to
  // [11] is direction
  // [12] is change
  logic [15:0] data_in; 
  logic motorCW;
  logic motorACW;


  integer i;


  // connections
  motor_Logic dut (
    //inputs
    .Reset(Reset),
    .CLK_50(CLK_50),
    .D(D),
    .hallIn(hallIn),
    .data_in(data_in),
    //outputs
    .motorCW(motorCW),
    .motorACW(motorACW),
	.busy(busy)
  );

	
	// clock generator
	always begin

		CLK_50 <= 1;
		#10ns;
		CLK_50 <= 0;
		#10ns;

		// time period is 20ns = 50MHz

	end

	// clocking 'hallin' to simualate motor rotation
	always begin

		hallIn <= 1;
		#2.5ms;
		hallIn <= 0;
		#2.5ms;

		// time period for a pulse from the hall effect sensor is approx. 5ms (see OneNote > Evidences > Motor Rotation)

	end

	// IMPORTANT // 

	// the simulation time is 157,000,000ns = 157ms, so it will take time (≈10-15 seconds)!
	// you can view the current simulation time in the bottom left corner of ModelSim

	// test vectors
	// 15 pulses (5 degrees)
	// this should take approx. 76ms (see OneNote > Evidences > Motor Rotation)
	initial begin

		// Signal intialisation
		D = 1'b1; // should always be VCC
		data_in = 16'b0000000000000000;

		// Test 0: Reset condition
		Reset = 1'b1;
		#500ns; // short delay
		assert (motorACW == 0 && motorCW == 0) $display("Passed reset condition"); else $error("Failed reset condition: 
		'motorACW' and 'motorCW' should both be 0");

		// Test 1: Motor ACW - 5 degrees in one direction
		Reset = 1'b0;		
		data_in = 16'b0001100000001111; // direction bit is 1; change bit is 1
		#76ms; // 76ms wait
		assert (motorACW == 1 && motorCW == 0) $display("Passed 5 degrees anticlockwise"); else $error("Failed 5 degrees anticlockwise: 
		'motorACW' should be 1 and 'motorCW' should be 0");

		#4ms; // 4ms wait (80ms total wait to be safe)

		 
		 
		// Test 2: Motor CW - 5 degrees in the other direction
		data_in = 16'b0000000000000011; // direction bit is 0; change bit is 0 (needed for pulse gen)
		#1ms; // 1ms wait
		assert (motorACW == 0 && motorCW == 1) $display("Passed 5 degrees clockwise"); else $error("Failed 5 degrees clockwise: 
		'motorACW' should be 0 and 'motorCW' should be 1");
		assert(busy == 1) $display("The busy flag went up when the motor is spinning"); else $error("The busy flag didnt go up");
		


		for (i = 0; i < 5; i = i + 1) begin
		@(posedge hallIn);	//Wait for + edge of clock
		end
		
		
		assert(busy == '0) $display("the busy flag went down when the motor stopped moving"); else $error("The motor is still moving");


		#1000000ns;
		$stop; // stops simulation after tests have been concluded

		
	end

endmodule
