module display_controller (

   output logic [7:0] data,
   output logic rs,
   output logic rw,
   input logic [7:0] ascii_data,
   input logic write,
   input logic rst,
   input logic clk

);

// Main Display Controller (FSM) //


// STORAGE REGISTERS //

// main storage register connected to the output
logic [7:0] storage_main;

// comparison registers
// they each store a copy of the main storage register

// in state S3 (last state):
// storage_primary accepts input
// storage_secondary contents remain untouched 
logic [7:0] storage_primary;
logic [7:0] storage_secondary;


// connects output to main storage register
always_comb begin

	data = storage_main;

end

// 5 states, 3 FFs
// S4 is an empty state - important!!
// S5 is a comparison state - ULTRA IMPORTANT!!!
typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5} state_t;

// current state, next state
state_t cs, ns;


// overall behaviour

always_ff @(posedge clk) begin
	
	
	if (rst) begin

		cs <= S0;
		storage_main <= '0;
		storage_primary <= '0;
		storage_secondary <= '0;

	end

	else begin

		cs <= ns;

		case(cs)

			S4 : begin

				storage_main <= ascii_data; // accepts input
				storage_primary <= storage_main; // store
				storage_secondary <= storage_main; // store

			end

			S5 : begin

				storage_primary <= ascii_data; // accepts input

			end

			default : begin

				storage_main <= ascii_data; // accepts input
				storage_primary <= storage_primary; // unchanged
				storage_secondary <= storage_secondary; // unchanged

			end


		endcase
		
		
		

	end

	

end


// state transitions
// write = 1 represents data
// write = 0 represents command

always_comb begin

	case(cs)

		S0 : begin

			if (write) begin

				ns <= S1;

			end

			else begin

				ns <= S2;

			end

		end


		S1 : begin

			ns <= S3;

		end


		S2 : begin

			ns <= S3;

		end
		
		
		S3 : begin
		
			ns <= S4;

		end
		
		S4 : begin // empty state
		
			ns <= S5;

		end


		S5 : begin
		
			if (storage_primary != storage_secondary) begin

				ns <= S0;

			end

			else begin

				ns <= S5;

			end

		end


		

	endcase


end
	
	
// output logic // 

always_comb begin
	
	case(cs)

        S1: begin
            rw = 0;
            rs = 1;
            
        end

	default : begin

		rw = 0;
		rs = 0;

	end

        

    endcase

    

end


endmodule


