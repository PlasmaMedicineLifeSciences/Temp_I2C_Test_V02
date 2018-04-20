`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Author : Buddika Sumanasena
// Company: US Medical Innovations
// Description: Clock divider to obtain different clock frequencies.
// The clock diveider also includes a reset input which would reset the counter and
//	stop the output clock. The duty cycle is approximately 50%.
//
// Dependencies: None
//////////////////////////////////////////////////////////////////////////////////


module ClockDivider(
    input Clock_in,			// Clock to be divided
    input reset,  			// Active HIGH reset. Output clock is LOW when reset is HIGH
    output reg Clock_out 	// Divided Clock
    );
    
    parameter clock_ratio=100000;
    parameter clock_ratio_two=clock_ratio/2;
    parameter reg_width=logarithm(clock_ratio);
    
    reg [reg_width:0] clock_counter;
	 
// This function computes the width of the counter required for clock counting.   
    function integer logarithm;
    input integer input_value;       
        integer i;
        begin
            logarithm = 0;
            for(i = 0; 2**i < input_value; i = i + 1)
            begin
                logarithm = i + 1;
            end
        end     
    endfunction
    
    always @(posedge Clock_in)
       begin
           if(reset==1'b1)
               begin
                   clock_counter<=0;
						 Clock_out<=1'b0;
               end
           else 
               begin
                    if(clock_counter<clock_ratio) 
                    begin
                        clock_counter<=clock_counter+1;  
                        if(clock_counter==clock_ratio_two)
                        begin
                            Clock_out<=~Clock_out;
                        end
                    end
                    else
                    begin 
                        clock_counter<=0;
                        Clock_out<=~Clock_out;
                    end                      
               end
       end
		 //assign Clock_out1=Clock_out;
endmodule
