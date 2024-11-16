module LCD_ROM (output logic [8:0] q, output logic RDY, input logic [2:0] address);

// ROM 4x9-bit memory locations //
// NOT A CLOCKED COMPONENT // 
 
// RDY is the ready bit
// goes high when address = 100


// initialisation as follows:
// address 00 -> 0x3C -- 8-bit, 2 line, 5x11
// address 01 -> 0x06 -- move cursor to right after each char.
// address 10 -> 0x01 -- clear; move cursor to home
// address 11 -> 0x0F -- turn on, cursor blinking
// these are the required boot-up commands

logic [8:0] memory [3:0] = '{ // the ' is needed to synthesise (why??)

	9'h0F, 9'h01,
	9'h06, 9'h3C
};


// output logic

always_comb begin

	q = memory[address];

	if (address == 3'b100) begin

		RDY = 1;

	end

	else begin

		RDY = 0;

	end


end

endmodule

