module motor_pulse_tb;


// inputs and outputs
logic clk, rst, sense, e;


// instantiating the system

motor_pulse u1 ( .clk(clk), .rst(rst), .sense(sense), .e(e));


//generate reset
initial begin

  rst = '1;
  #10ps rst = '0;
  //this will ensure there are no unknowns

end

//generate clock
initial begin

	clk=0;
  repeat(15) 
  #50ps clk = ~clk;  

end

//Test vectors
initial begin


  @(negedge clk);
  sense = 1; 

  @(posedge clk);	//Wait for + edge of clock
  #10 assert(e == '1) $display("PASS test 1"); else $error("FAIL test 1: output should be 1");
  @(posedge clk);
  //this will ensure that the pulse goes down at the next clock cycle
  #10 assert(e == '0) $display("PASS test 2"); else $error("FAIL test 2: output should be 0");

  @(negedge clk);
  sense = 0;  //there is a change in input

  @(posedge clk);	//Wait for + edge of clock
  #10 assert(e == '1) $display("PASS test 3"); else $error("FAIL test 3: output should be 1");
  @(posedge clk);
  //this will ensure that the pulse goes down at the next clock cycle
  #10 assert(e == '0) $display("PASS test 4"); else $error("FAIL test 4: output should be 0");
  @(posedge clk);
  //this will ensure the device doesn't trigger again when the input hasn't changed
  #10 assert(e == '0) $display("PASS test 5"); else $error("FAIL test 5: output should be 0");
  @(posedge clk);
  //this will ensure the device doesn't trigger again when the input hasn't changed
  #10 assert(e == '0) $display("PASS test 6"); else $error("FAIL test 6: output should be 0");
  @(posedge clk);
  //this will ensure the device doesn't trigger again when the input hasn't changed
  #10 assert(e == '0) $display("PASS test 7"); else $error("FAIL test 7: output should be 0");

 
end

endmodule