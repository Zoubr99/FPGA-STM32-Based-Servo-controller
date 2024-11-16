module motor_pulse (
    output logic e,
    input logic sense,  //this will be the thing that we are monitoring
    input logic clk,
    input logic rst
);

logic prev_sense; //this will store the prev state

always @(posedge clk) begin
    if (rst) begin
        prev_sense <= '0;
        e <= 0;
        end 
    else begin
        if (sense !== prev_sense) begin
            e <= 1;
        end else begin
            e <= 0;
        end
        prev_sense <= sense;
    end
end

endmodule