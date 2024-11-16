module AND_TB;

// Add internal signals here
logic Y, A, B;


//device under test
ANDGate u1 (Y, A, B);

//Stimulus
initial begin


//test 000
A = '0;
B = '0;
#10 assert(Y == 0) $display("Pass test 1"); else $error("Fail test 1: output should be 0");

A = '1;
B = '0;
#10 assert(Y == 0) $display("Pass test 2"); else $error("Fail test 2: output should be 0");

A = '0;
B = '1;
#10 assert(Y == 0) $display("Pass test 3"); else $error("Fail test 3: output should be 0");

A = '1;
B = '1;
#10 assert(Y == 1) $display("Pass test 4"); else $error("Fail test 4: output should be 1");


end

endmodule