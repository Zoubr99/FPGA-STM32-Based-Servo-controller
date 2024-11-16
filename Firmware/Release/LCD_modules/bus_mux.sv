module bus_mux (output logic [8:0] q, input logic [8:0] a,b, input logic select);

// 9-bit 2x1 bux // 

// q[7:0] will be used as data
// q[8] will be used as the control for the 'write' pin of the LCD controller
// input a is from the ROM
// input b is from the MCU (SPI2)

always_comb begin

	case(select)

		1'b0 : begin
			q = a;
		end

		1'b1 : begin
			q = b;
		end

	endcase

end

endmodule

