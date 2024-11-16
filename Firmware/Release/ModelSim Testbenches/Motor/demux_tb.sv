`timescale 1ns/1ns

module demux_tb;

// internal signals
logic SEL;
logic D;
logic Y;
logic Q;



// connections
demux dut (

    // inputs
    .SEL(SEL),
    .D(D),

    // outputs
    .Y(Y),
    .Q(Q)

);

// testing block
initial begin

    SEL <= 0; // select bit
    D <= 1; // input
    #10;

    assert(Y == 1 && Q == 0) $display("Passed test 1"); else $error("Failed test 1: 
    'Y' should be 1 and 'Q' should be 0");

    SEL <= 1;
    #10;

    assert(Y == 0 && Q == 1) $display("Passed test 2"); else $error("Failed test 2: 
    'Y' should be 0 and 'Q' should be 1");



end

endmodule