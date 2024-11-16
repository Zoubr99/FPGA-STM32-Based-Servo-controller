`timescale 1ns/1ns
module LCD_ROM_tb;

// internal signals
logic [2:0] address;
logic [8:0] q;
logic RDY;

// connections
LCD_ROM dut (

    // inputs
    .address(address),

    // outputs
    .q(q),
    .RDY(RDY)

);

// testing block
// testing that all 4 commands are being output by the ROM
initial begin

    address <= 'd0;
    #10;

    assert(q == 'h3C && RDY == 0) $display("Passed 8-bit, 2-line, 5x11 font"); else $error("Failed 8-bit, 2-line, 5x11 font: 
    'q' should be h3C and 'RDY' should be 0");

    address <= 'd1;
    #10;

    assert(q == 'h6 && RDY == 0) $display("Passed move cursor to right"); else $error("Failed move cursor to right: 
    'q' should be h6 and 'RDY' should be 0");

    address <= 'd2;
    #10;

    assert(q == 'h1 && RDY == 0) $display("Passed clear screen"); else $error("Failed clear screen: 
    'q' should be h1 and 'RDY' should be 0");

    address <= 'd3;
    #10;

    assert(q == 'hF && RDY == 0) $display("Passed turn on display, cursor blinking"); else $error("Failed turn on display, cursor blinking: 
    'q' should be hF and 'RDY' should be 0");

    address <= 'd4;
    #10;

    assert(RDY == 1) $display("Passed RDY HIGH"); else $error("Failed RDY HIGH: 'RDY' should be 1"); // test for output flag


end


endmodule
