`timescale 1ns/1ns
module bus_mux_tb;

// internal signals
logic select;
logic [8:0] a;
logic [8:0] b;
logic [8:0] q;

// connections
bus_mux dut (

    //inputs
    .select(select),
    .a(a),
    .b(b),

    //outputs
    .q(q)

);

// testing block
initial begin

    select <= 0; // selects input a
    a <= 'd20;
    b <= 'd40;
    #10;

    assert(q == 'd20) $display("Passed test 1"); else $error("Failed test 1: output should match input 'a' (d20)");

    select <= 1; // selects input b
    #10;

    assert(q == 'd40) $display("Passed test 2"); else $error("Failed test 2: output should match input 'b' (d40)");

end


endmodule
