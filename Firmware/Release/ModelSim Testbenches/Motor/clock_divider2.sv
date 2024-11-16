module clock_divider2 (output logic q, input logic clk, rst);

// a clock divider // 
// used for the enable pulse generator // 

// 11-bit up counter
// we are only concerned with the the MSB q[10]
// this will take the 50MHz clock of the FPGA and slow it down to approx. 24.4kHz
// this equates to approx. 40us
// enable pulse has to be atleast 480ns; so this is more than enough!

logic [10:0] count_reg;

always_comb begin

	q = count_reg[10];

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
