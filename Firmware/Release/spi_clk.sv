module clock_divider_buffer (output logic q, input logic clk, rst);

// a clock divider // 

// 17-bit up counter
// we are only concerned with the the MSB q[16]
// this will take the 50MHz clock of the FPGA and slow it down to approx. 381Hz
// this equates to approx. 2.6ms
// slow enough for **ALL** LCD commands

logic [16:0] count_reg;

always_comb begin

	q = count_reg[16];

end



always_ff @(posedge clk) begin

	if (rst) begin

		count_reg <= 0;

	end

	else begin

		count_reg <= count_reg + 1;

	end
	
	
end



endmodule
