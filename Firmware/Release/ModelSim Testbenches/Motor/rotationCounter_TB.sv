module rotationCounter_TB;

logic flag, hallIn, RESET, change; 
logic [5:0] cin; //this is going to change in the future as we need more inputs for this data

//we shall treat the hallIn as a clock. this would usually turn off if the flag is high


// instantiating the sytem
rotationCount u1 ( .hallIn(hallIn), .RESET(RESET), .change(change), .flag(flag), .cin(cin) );

//reset device
initial begin
RESET = '1;
#10 RESET = '0;
end

//generate clock
initial begin

  hallIn=0;
  repeat(40) 
  #10 hallIn = ~hallIn; 
    
end


initial begin

  cin = 6'b000010; //this is what the device has to count up to 


  @(negedge hallIn);	
  change = '1; //this indicates that there has been a change at the input 
  @(posedge hallIn)
  #10 assert(flag == '1) $display("PASS test 1"); else $error("FAIL test 1: 'flag' should be 1");	//this ensure that the ouput doesnt change as soon as there is a change

  @(negedge hallIn);	
  change = '0; //the counter can now begin 
  @(posedge hallIn)  //count once     
  #10 assert(flag == '1) $display("PASS test 2"); else $error("FAIL test 2: 'flag' should be 1");	//this ensure that the ouput doesnt change as soon as there is a change

  @(posedge hallIn)   //count twice   
  #10 assert(flag == '1) $display("PASS test 3"); else $error("FAIL test 3: 'flag' should be 1");	//this ensure that the ouput doesnt change as soon as there is a change

  @(posedge hallIn)   //the output should go high    
  #10 assert(flag == '0) $display("PASS test 4"); else $error("FAIL test 4: 'flag' should be 0");	//this will check if the flag has gone up

  @(posedge hallIn)      
  #10 assert(flag == '0) $display("PASS test 5"); else $error("FAIL test 5: 'flag' should be 0");	//check the flag stays up 




  //test a different input
  cin = 6'b000011; //this is what the device has to count uo to 
  @(negedge hallIn);	
  change = '1; //this indicates that there has been a change at the input 
  @(posedge hallIn)
  #10 assert(flag == '1) $display("PASS test 6"); else $error("FAIL test 6: 'flag' should be 1");	//this ensure that the ouput doesnt change as soon as there is a change

  @(negedge hallIn);	
  change = '0; //the counter can now begin 
  @(posedge hallIn)  //count once     
  #10 assert(flag == '1) $display("PASS test 7"); else $error("FAIL test 7: 'flag' should be 1");	//this ensure that the ouput doesnt change as soon as there is a change


  //clock 5 times to count
  for (int i=0; i<5; i=i+1) begin
  @(posedge hallIn);  //count once  
  end
  @(negedge hallIn)
  #10 assert(flag == '0) $display("PASS test 8"); else $error("FAIL test 8: 'flag' should be 0");	//this ensure that the ouput doesnt change as soon as there is a change


end //end of test




endmodule
