module demux (output logic Y, Q, input logic D, input logic SEL);

    always_comb begin
        case (SEL)
            1'b0 : begin
                Y = D;
                Q = 0;
            end
            1'b1 : begin
                Y = 0;
                Q = D;
            end
            default: begin
                Y = 0;
                Q = 0;
            end
        endcase
    end

endmodule