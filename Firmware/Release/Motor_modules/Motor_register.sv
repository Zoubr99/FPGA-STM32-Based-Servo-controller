module Motor_register (

    output logic [10:0] data_out,
    output logic direction,
    output logic change,
    input logic [15:0] data_in, //data that needs seperating
    input logic clk,
    input logic reset   
);

logic [15:0] reg_data;

assign data_out = reg_data[10:0];   //Data bits
assign direction = reg_data[11];    //Determines the direction the motor spins
assign change = reg_data[12];       //A change in this bit activates the pulse generator

always_ff @(posedge clk) begin

    if (reset) begin
        reg_data <= 'b0;          //clears bits
    end 
    
    else begin
        reg_data <= data_in;
    end

end


endmodule