module buffer_tb;

logic clk;
logic clkk;
logic rst_n;
logic [8:0] buffer_input; 
logic [8:0] buffer_output;

spi_buffer u1 (
  .clk(clk),
  .clkk(clkk),
  .reset(rst_n),
  .spi_in(buffer_input),
  .buffer_out(buffer_output)
);

initial begin

  rst_n = 1;
  #5ns
  rst_n = 0;

end

initial begin

  clk = 0;
  repeat(100000000) #5ns clk=~clk;

end

initial begin

  clkk = 0;
  repeat(200) #5ms clkk=~clkk;

end


initial begin
  buffer_output = 0; // Initialize buffer output

  @(posedge clk)
  buffer_input   = 9'b001001110; // entering "N", but there would be no output at this moment
  @(negedge clk) // Provide enough clock cycles for buffer to process input and produce output
  assert(buffer_output == 9'b000000000) $display("pass test 1"); else $error("failed test 1: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001101001; //entering "I" , no output at the moment
  @(negedge clk)
  assert(buffer_output == 9'b000000000) $display("pass test 2"); else $error("failed test 2: 'buffer_output' should be 0");
  
  @(posedge clk)     
  buffer_input   = 9'b001000011; // entering "C", no output at the moment
  @(negedge clk)
  assert(buffer_output == 9'b000000000) $display("pass test 3"); else $error("failed test 3: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001001011; // entering "K" , no output at the moment
  @(negedge clk)
  assert(buffer_output == 9'b000000000) $display("pass test 4"); else $error("failed test 4: 'buffer_output' should be 0");


  // after writting the needed lettters , ie writing the sentence we want to display on LCD we will send a command to indicate 
  // the end of the writing process by sending a 256 char followed by a 0
  @(posedge clk)
  buffer_input   = 9'b100000000; // entering "256" , no output at the moment, as it will wait untill the stop writting goes high
  @(posedge clk)
  buffer_input   = 9'b000000000;
  @(negedge clk)
  assert(buffer_output == 9'b000000000) $display("pass test 5"); else $error("failed test 5: 'buffer_output' should be 0");

  @(negedge clkk) // @ negative edge of the clock clkk check that the buffer output is the first letter stored which is "N"
		  // note this is a slower clock than clk, so now after the special char has been recieved it will start outputting what have been stored every posedge of the clkk clock
                  // However, the checking will be done on the negedge after the output appears so we can see the output clearly with no issues
  assert(buffer_output == 9'b001001110) $display("pass test 6"); else $error("failed test 6: 'buffer_output' should be 001001110"); // the output will be working like a FIFO stacking "first input first output, 1 letter every clkk posedge"

  @(negedge clkk) // now keep checking at every negedge of the clock "clkk" , second letter "I"
  assert(buffer_output == 9'b001101001) $display("pass test 7"); else $error("failed test 7: 'buffer_output' should be 001101001");

  @(negedge clkk) // third letter "C"
  assert(buffer_output == 9'b001000011) $display("pass test 8"); else $error("failed test 8: 'buffer_output' should be 001000011");

  @(negedge clkk) // third letter "K"
  assert(buffer_output == 9'b001001011) $display("pass test 9"); else $error("failed test 9: 'buffer_output' should be 001001011");



  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




  // now after the first sentence lets try and write a new sentence as if we are trying to delete the old sentence displayed on the LCD and want to display a new one
  @(posedge clkk) 
  @(posedge clkk) // wait for 2 pos edges of clkk so read would be 0 an then start writing again (ie : waiting for LCD to finish displaying)
  @(posedge clk)
  buffer_input   = 9'b001001111; // entering "O", output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk) 
  assert(buffer_output == 9'b001001011) $display("pass test 1"); else $error("failed test 1: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001010101; //entering "U" , output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 2"); else $error("failed test 2: 'buffer_output' should be 0");
  
  @(posedge clk)     
  buffer_input   = 9'b001010100; // entering "T", output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 3"); else $error("failed test 3: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001010010; // entering "R" , output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 4"); else $error("failed test 4: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001000001; // entering "A" , output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 5"); else $error("failed test 5: 'buffer_output' should be 0");

  @(posedge clk)
  buffer_input   = 9'b001001101; // entering "M" , output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 6"); else $error("failed test 6: 'buffer_output' should be 0");


  // after writting the needed lettters , ie writing the sentence we want to display on LCD we will send a command to indicate 
  // the end of the writing process by sending a 256 char followed by a 0
  @(posedge clk)
  buffer_input   = 9'b100000000; // entering "256" , output should be the last letter set the output to in this case "K", the LCD will ignore the repetetive entries as it was made to do so, as it will wait untill the stop_writting goes high
  // so the output changes
  @(posedge clk)
  buffer_input   = 9'b000000000;
  @(negedge clk)
  assert(buffer_output == 9'b001001011) $display("pass test 7"); else $error("failed test 7: 'buffer_output' should be 0");

  @(negedge clkk) // @ negative edge of the clock clkk check that the buffer output is the first letter stored which is "O"
		  // note this is a slower clock than clk, so now after the special char has been recieved it will start outputting what have been stored every posedge of the clkk clock
                  // However, the checking will be done on the negedge after the output appears so we can see the output clearly with no issues
  //#1ns // delay for the output to take place. or instead wait for 1 extra neg edge
  @(negedge clkk)
  assert(buffer_output == 9'b001001111) $display("pass test 8"); else $error("failed test 8: 'buffer_output' should be 001001111"); // the output will be working like a FIFO stacking "first input first output, 1 letter every clkk posedge"

  @(negedge clkk) // now keep checking at every negedge of the clock "clkk" , second letter "U"
  assert(buffer_output == 9'b001010101) $display("pass test 9"); else $error("failed test 9: 'buffer_output' should be 001010101");

  @(negedge clkk) // third letter "T"
  assert(buffer_output == 9'b001010100) $display("pass test 10"); else $error("failed test 10: 'buffer_output' should be 001010100");
				
  @(negedge clkk) // Fourth letter "R"
  assert(buffer_output == 9'b001010010) $display("pass test 11"); else $error("failed test 11: 'buffer_output' should be 001010010");

  @(negedge clkk) // Fifth letter "A"
  assert(buffer_output == 9'b001000001) $display("pass test 12"); else $error("failed test 12: 'buffer_output' should be 001000001");

  @(negedge clkk) // Sixth letter "M"
  assert(buffer_output == 9'b001001101) $display("pass test 13"); else $error("failed test 13: 'buffer_output' should be 001001101");

  
  
end

endmodule
