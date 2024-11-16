module spi_clock_divider (
  output logic q,
  input logic clk,
  input logic rst
);

  logic [6:0] counter;
  
  

  always @(negedge clk or posedge rst) begin
  
    if (rst) begin
      counter <= 0;
      q <= 0;
    end
	 
	 
    else begin
      counter <= counter + 1;
		
      if (counter == 7'b1111011) begin
        counter <= 0;
        q <= ~q;
      end
		
    end
	 
  end

  
  
  
endmodule
