module counter #(parameter N=3) (output logic [N-1:0] q, input logic clk, rst);

// 3-bit up counter // 

// clk comes from clock_divider
// output feeds 'address' pin of ROM

logic [N-1:0] count_reg;

always_comb begin

	q = count_reg;

end


always_ff @(posedge clk) begin

	case(rst)

		// reset condition

		1'b1 : begin

			count_reg <= 3'b000;

		end

		// counting logic

		1'b0 : begin

			// this ensures it counts up to 2'b11 ONLY ONCE
			// since we need to cycle through all addresses only once
			// for the boot-up sequence of the LCD

			if (count_reg == 3'b100) begin

				count_reg <= 3'b100;

			end

			else begin

				count_reg <= count_reg + 1;

			end

		end

	endcase


	
end


endmodule
