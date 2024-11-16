module spi_buffer (

    // clk 1 and clk 2
    input logic clk,
    input logic clkk,

    // reset 
    input logic reset,

    //spi data in
    input logic [8:0] spi_in,

    // data read from buffer output
    output logic [8:0] buffer_out

);

    // this is the buffer the data to be stored in 257 elements of the size 9 bits
    reg [8:0] buffer_internal_storage [0:256];

    // this is a pointer to the bit position where it should be written
    reg [8:0] write;
    // this does the same but when reading, it indicates which bit to be read
    reg [8:0] read;

    // this to indicate that the buffer array is full and needs to be cleared
    reg buffer_full = 0;
    
    // this indicates whether read should be set to 0
    reg setting_read_zero = 0;
    // as the name implies it stops the reading   
	reg stop_reading;

    // helps to know how many bits were used when writing , and accordingly it will stop the reading at the position where the writing has stopped
	reg [8:0]writecount;
    // used so after the number = 256 is recieved it will go high and the writing will not happen untill this goes low, ie , after reading is done
	 reg stop_writing = 0;
	 
	 
	 
	 // while reading this will keep going on
	 
    always_ff @(posedge clk or posedge reset) begin
            if (reset == 1) begin // first thing checking reset 
				// resets everything , nothing is going to happen untill the reset is 0
				buffer_full <= 0;
				write <= 0;
				stop_reading <= 0;
				stop_writing <= 0;
				writecount <= 0;
				stop_reading <= 0;
				
            end
				
            else 
            begin
				      
						// ( writting busy flag linking ) // 
						if(setting_read_zero == 1)begin 			// after reset checking it will check if the condition	
								stop_reading <= 0;					// where the read is going to be set to 0 is is 1 it will go in and set everthing to 0
								writecount <= 0;						// otherwise it will move on to the next condition
								stop_writing <= 0;
						end
						

                   if (buffer_full == 1) begin // this sets the buffer to indicate that it is has (contents) stored and need to be read
															  // if buffer full was 1 it will not go 0 untill the writing has stopped
                      if (read != 0) begin     // as sson as the writing stops and read is no longer zero the buffer will go 0
                      buffer_full <= 0;     	  // indicating that the elements stored can now be overwritting , however this will not be done
                      end		 					  // untill the reading process has finished and the buffer is ready to store new data
							 
						 end	
						 

                    else begin 
						  
						  // these are the conditions which eaither : 1.1- writing to the buffer or 1.2- stopping the writing
						  // 1.2 means it is a sub condition as the reading will be 2.1 and the stop reading will be 2.2
							  if(read == 0 && buffer_full == 0)begin 
																										// it first checks the buffer is low and reading is 0
									if(spi_in != 256 && spi_in != 0)begin					// it can move on and check the sub conditions  
										if(stop_writing == 0)begin								// if neither 256 has been recievd "indicater transmission is finished", nor 
											buffer_internal_storage[write] <= spi_in;		// the spi in is 0 means that there is data to be stored, stop writing is an extra
											write <= write + 1;									// condtion to help the system to be more stable and vigilinat of what it is currently doing
											writecount <= writecount + 1;						// if all conditions were as expected , it will write according to the pointer "" write "
										end															// and increment it , and it will increment the write count so it could be used when reading
									end

						  
						 
									// ( reading busy flag ) // 
								  if(spi_in == 256)begin     // this is the last condition "works as a busy flag setter" for the reading process if non of the above were met it means that the 
									 buffer_full <= 1;		  // the buffer has the needed contents and now the the reading should start as will stting a virtual flag to 1 so no writing happens when reading
									 write <= 0;
									 stop_reading <= 1;
									 stop_writing <= 1;
									end 
									
								end
						  
						  
						  
						  
						  end
						  
            end

end 
	  
	 

    always_ff @(posedge clkk or posedge reset) begin
        if (reset == 1) begin  // first it checks the reset if high , it will set the read to 0 and the output to 0 zero as well
            read <= 0;
				buffer_out <= buffer_internal_storage[read];
        end

            else 
            begin
								// ( writting busy flag ) // 
                    if (setting_read_zero == 1) begin  // after the reset checking 
																			// although this coindition is set to be checked first after the reset checking it is not gonna 
									 if(stop_reading == 0)begin	// be met untill the reading is finsihed this 
										setting_read_zero <= 0;
										read <= 0;
									 end
									
                    end
								// ( the reading happens here) // 
                    if (write == 0 && stop_reading == 1 ) begin // as soon as these conditions are meet it means the writting has stopped


							  if (read == (writecount - 1)) begin // first it will check if read == write count it means all the elemnts inside the buffer were read
							  setting_read_zero <= 1;					// and it can start writting again by setting the appropriate conditions
							  end
								 
							  if (read != (writecount - 1)) begin // here as long as read has not reached write count it will keep reading the buffers elemnts untill it reaches writecount
							  read <= read + 1; // increments the read pointer each pos edge of clk
							  buffer_out <= buffer_internal_storage[read]; // sets the outpus to be what is being stored in where the read is pointing , works just like the write pointer
							  end
				   	


                    end		

			end
	end

endmodule
