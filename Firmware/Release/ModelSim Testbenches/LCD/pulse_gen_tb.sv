`timescale 1ns/1ns
module pulse_gen_tb;

// internal signals
logic clk;
logic rst;
logic [8:0] sense;
logic e;

// connections
pulse_gen dut(

    // inputs
    .clk(clk),
    .rst(rst),
    .sense(sense),

    // outputs
    .e(e)

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
// "output high" and "output low" represent a pulse!
initial begin

    rst <= 1; // asserting reset
    sense <= 'd0;
    #10;

    assert(e == 'd0) $display("Passed reset condition"); else $error("Failed reset condition: output should be 0");

    rst <= 0; // de-asserting reset
    sense <= 'd0;
    #10;

    assert(e == 'd0) $display("Passed test 1"); else $error("Failed test 1: output should be 0");

    rst <= 0;
    sense <= 'd1;
    #10;

    assert(e == 'd1) $display("Passed output high"); else $error("Failed output high: output should be 1");

    rst <= 0;
    sense <= 'd1;
    #10;

    assert(e == 'd0) $display("Passed output low"); else $error("Failed output low: output should be 0");

    rst <= 0;
    sense <= 'd1;
    #10;

    assert(e == 'd0) $display("Passed test 2"); else $error("Failed test 2: output should be 0");

    rst <= 0;
    sense <= 'd2;
    #10;

    assert(e == 'd1) $display("Passed output high"); else $error("Failed output high: output should be 1");

    rst <= 0;
    sense <= 'd2;
    #10;

    assert(e == 'd0) $display("Passed output low"); else $error("Failed output low: output should be 0");

    rst <= 0;
    sense <= 'd2;
    #10;

    assert(e == 'd0) $display("Passed test 3"); else $error("Failed test 3: output should be 0");

    #10;
    $stop;



end




endmodule
