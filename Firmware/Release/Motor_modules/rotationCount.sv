module rotationCount (
    output logic flag, 
    input logic hallIn, change, RESET,
    input logic[10:0]cin
   );


   logic [10:0]count;    //this is the register we want for the counter


//if there is a new input the device will begin and contine until the conditions in the ff are met
always_ff @(posedge hallIn, posedge RESET, posedge change) begin 
	
    if(change) begin
    flag <= 1; //this will put the flag up so that the motor can start moving
    count <= 0;
    end

    //incase it gets stuck. this isnt actaully needed
    else if (RESET == 1)begin
	 count <= 0;
    flag <= 0;//this will reset the flag to 0 so that the motor will not spin
    end
    
    //if the current is the same as the 
	else if (count < cin)  
    begin
    count <= count + 1;    
    end
	 
    else if (count == cin) flag <= 0;   //this will stop the motor one the motor has reach the desired value 



end



endmodule

