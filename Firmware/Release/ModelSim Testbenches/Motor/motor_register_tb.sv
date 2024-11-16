module motor_register_tb;

logic direction, change, reset, clk; 
logic [10:0] data_out;  
logic [12:0] data_in; //data that needs seperating


// Instantiate module under test
Motor_register u1 (.clk(clk), .data_in(data_in), .change(change), .direction(direction), .data_out(data_out) );


//reset device
initial begin
reset = '1;
#10 reset = '0;
end

//generate clock
initial begin

  clk=0;
  repeat(20) 
  #10 clk = ~clk;  

end


initial begin
  
  data_in = 13'b1110101000101;

  @(posedge clk);
  //this ensures that the output doesn't change as soon as there is a change
  #10 assert(change == '1) $display("PASS test 1"); else $error("FAIL test 1: 'change' should be 1");

  @(posedge clk);
  //this will ensure that the data for the pulses are being sent
  #10 assert(data_out == 11'b10101000101) $display("PASS test 2"); else $error("FAIL test 2: 'data_out' should be 11'b10101000101");
  assert(direction == '1) $display("PASS test 3"); else $error("FAIL test 3: 'direction' should be 1");	

  @(negedge clk);
  data_in = 13'b0010101000101;

  @(posedge clk);
  //this ensures that the output doesn't change as soon as there is a change
  #10 assert(change == '0) $display("PASS test 4"); else $error("FAIL test 4: 'change' should be 0");

  @(posedge clk);
  //this will ensure that the data for the pulses are being sent
  #10 assert(data_out == 11'b10101000101) $display("PASS test 5"); else $error("FAIL test 5: 'data_out' should be 11'b10101000101");
  assert(direction == '0) $display("PASS test 6"); else $error("FAIL test 6: 'direction' should be 0");

end

endmodule
