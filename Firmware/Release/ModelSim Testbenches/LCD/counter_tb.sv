`timescale 1ns/1ns
module counter_tb;

// internal signals
logic clk;
logic rst;
logic [2:0] q;

// connections
counter dut (

    // inputs
    .clk(clk),
    .rst(rst),

    // outputs
    .q(q)

);

// clock block
always begin

    clk <= 1;
    #5;
    clk <= 0;
    #5;

    // time period is 10ns


end

// testing block
initial begin

    rst <= 1; // assert reset 
    #10;

    assert(q == 'd0) $display("Passed reset condition"); else $error("Failed reset condition: output should be 0");

    rst <= 0; // de-assert reset
    #10;

    assert(q == 'd1) $display("Passed test 1"); else $error("Failed test 1: output should be d1");

    #10;

    assert(q == 'd2) $display("Passed test 2"); else $error("Failed test 2: output should be d2");

    #10;

    assert(q == 'd3) $display("Passed test 3"); else $error("Failed test 3: output should be d3");

    #10;

    assert(q == 'd4) $display("Passed test 4"); else $error("Failed test 4: output should be d4");


    #10;
    $stop;


end



endmodule
