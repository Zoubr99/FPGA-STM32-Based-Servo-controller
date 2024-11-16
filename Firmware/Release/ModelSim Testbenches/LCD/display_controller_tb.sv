`timescale 1ns/1ns
module display_controller_tb;

// internal signals

// inputs
logic clk;
logic rst;
logic write;
logic [7:0] ascii_data;

// outputs
logic [7:0] data;
logic rs;
logic rw;


// connections
display_controller dut (

    // inputs
    .clk(clk),
    .rst(rst),
    .write(write),
    .ascii_data(ascii_data),

    // outputs
    .data(data),
    .rs(rs),
    .rw(rw)


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
// recall: if write = 1 -> data (rw,rs = 0,1), write = 0 -> command (rw,rs = 0,0)
initial begin

    rst <= 1; // asserting reset (state S0)
    write <= 0; // will pass a command of...
    ascii_data <= 'h1; // ... clearing the display
    #10;

    assert (data == 'd0 && rw == 0 && rs == 0) $display("Passed reset condition"); else $error("Failed reset condition: 
    'data', 'rs' and 'rw' should all be 0");

    rst <= 0; // de-asserting reset
    #20; // waiting 2 clock cycles for states S1 or S2

    assert (data == 'h1 && rw == 0 && rs == 0) $display("Passed clear command"); else $error("Failed clear command: 
    'data' should be h01, 'rs' and 'rw' should be 0");
    #20; // waiting 2 more clock cycles for final state

    write <= 1; // will send data of value...
    ascii_data <= 'h20; // ... 20 in hex
    #21; // waiting 2 clock cycles for states S1 or S2

    assert (data == 'h20 && rw == 0 && rs == 1) $display("Passed sending data"); else $error("Failed sending data: 
    'data' should be h20, 'rs' should be 1 and 'rw' should be 0");

    #10;
    $stop;
    

end



endmodule
