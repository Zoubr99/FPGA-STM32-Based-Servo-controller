module pulse_gen (
    output logic e,
    input logic [7:0] sense,
    input logic clk,
    input logic rst
);

logic [7:0] prev_sense;

always @(posedge clk) begin
    if (rst) begin
        prev_sense <= '0;
        e <= 0;
    end else begin
        if (sense !== prev_sense) begin
            e <= 1;
        end else begin
            e <= 0;
        end
        prev_sense <= sense;
    end
end

endmodule

