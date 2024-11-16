`timescale 1ns/1ns
module led_driver_tb;

// internal signals
logic a;
logic [7:0] q;

// connections
led_driver dut (

    .a(a),
    .q(q)

);

// testing block
initial begin

    a <= 0;
    #10;
    assert(q == 8'h00) $display("Passed test 1"); else $error("Failed test 1: output should be 0");

    a <= 1;
    #10;
    assert(q == 8'hFF) $display("Passed test 2"); else $error("Failed test 2: output should be 1");


end




endmodule