module led_driver (output logic [7:0] q, input logic a);

// the input of this device is the busy flag
// the output bus is fed to the 8 LEDs
// the leds are on when motor are spinning - just a cool little indicator!

always_comb begin

    if (a) begin
        q = 8'hFF;
    end

    else begin
        q = 8'h0;
    end

end


endmodule
