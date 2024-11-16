`timescale 1us/1us
module LCD_Logic_tb;

// Internal signals

logic Clock;
logic Clock_fast;
logic Reset;
logic [8:0] from_MCU;
logic [7:0] data;
logic rs;
logic rw;
logic e;

// Connections
LCD_Logic dut (

    // inputs
    .Clock(Clock),
    .Clock_fast(Clock_fast),
    .Reset(Reset),
    .from_MCU(from_MCU),
    // outputs
    .data(data),
    .rs(rs),
    .rw(rw),
    .e(e)

);

// 381Hz clock block
always begin

    Clock <= 1;
    #1312;
    Clock <= 0;
    #1312;

    // time period is 2624us = 2.624ms


end


// 22kHz clock block
always begin

    Clock_fast <= 1;
    #20;
    Clock_fast <= 0;
    #20;

    // time period is 40us (enable pulse)

end


// test block
// delays used will be approximate multiples of 2624us (1 clock cycle)
// slightly lower/higher just to get the timing of the enable pulse correct
initial begin

    Reset <= 1;
    from_MCU <= 9'b100000101; // write bit = 1 indicating data (not command); word is 101 (d5)
    #2624; // wait one clock cycle
    assert(data == 0 && rs == 0 && rw == 0 && e == 0) $display("Passed reset condition"); else $error("Failed reset condition: 
    all outputs should be low");

    Reset <= 0;
    #36; // short delay after reset is de-asserted
    assert(data == 'h3C && rs == 0 && rw == 0 && e == 1) $display("Passed test 1"); else $error("Failed test 1: 
    'data' should be h3C, 'rs' and 'rw' should be 0 and 'e' should be 1");

    #2640;
    assert(data == 'h06 && rs == 0 && rw == 0 && e == 1) $display("Passed test 2"); else $error("Failed test 2: 
    'data' should be h06, 'rs' and 'rw' should be 0 and 'e' should be 1");

    #2600;
    assert(data == 'h01 && rs == 0 && rw == 0 && e == 1) $display("Passed test 3"); else $error("Failed test 3: 
    'data' should be h01, 'rs' and 'rw' should be 0 and 'e' should be 1");
    
    #2640;
    assert(data == 'h0F && rs == 0 && rw == 0 && e == 1) $display("Passed test 4"); else $error("Failed test 4: 
    'data' should be h0F, 'rs' and 'rw' should be 0 and 'e' should be 1");

    #7880;
    assert(data == 'h05 && rs == 1 && rw == 0 && e == 1) $display("Passed test 5"); else $error("Failed test 5: 
    'data' should be h05, 'rs' should be 1, 'rw' should be 0 and 'e' should be 1");
    

    #5000;
    $stop; // stops simulation when done with all tests


end



endmodule

