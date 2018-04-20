`timescale 1ns / 1ps
//=======================================================================================
// Author : Shruti Wigh
// Company: US Medical Innovations
/* Description: This Verilog module is used to read the temperature data by the FPGA from the Temperature sensor on the PFC*/
//Dependencies: Clock Divider.v
//=======================================================================================

module I2C_TC74_Read(
		input CLK,		
      input [7:0] add1,                    //Address of the register to be read from TC74, use the default address specified in the datasheet
		output reg [7:0] data_read,
		input enable,                        //This is turned high in order to activate the communication between FPGA & TC74                   
		input reset,
		inout I2C_SDA_Output,                  
		output reg busy, 		//The O/P for this is high when the I2C bus is in use
		output reg I2C_SCLK);                //SCLK from the master
		
//========================================================================================
// REG/WIRE declarations
//========================================================================================
      parameter clock_ratio=333;
		wire divided_clock;
		reg [8:0] state;
		reg [7:0] count;
		reg [6:0] add2=7'b0001001;
		//reg [7:0] cmd_RTR=8'b11111111;       //This command is for reading from the temperature register
		reg [7:0] cmd_RTR=8'b00000000;
		reg [7:0] data_buffer;
      reg I2C_SDA_Direction /* synthesis noprune */;              // When writing make this 1, when reading 0
		reg I2C_SDA /* synthesis noprune */;                        //Bidirectional Data line
		
//========================================================================================
// Instantiation
//========================================================================================		
		
	 ClockDivider #(clock_ratio) clock_divider2(	.Clock_in(CLK),
																.reset(1'b0),
																.Clock_out(divided_clock));
//========================================================================================
//  Structural coding
//========================================================================================

always @(posedge divided_clock)
	if(~reset)begin
		state <= 0;
	end else begin
		begin
			case (state)
			0:	begin
			      	I2C_SDA_Direction<=1'b1;
						I2C_SCLK<=1'b1;
						I2C_SDA<=1'b1;
						if(enable==1'b1)
						begin
						   busy<=1;
							state<=state+1;
						end
						else
						begin
						   busy<=0;
							state<=0;
						end
				end	
								
			1: begin 	
						I2C_SDA_Direction<=1'b1;
						I2C_SCLK<=1'b1;               // Initiate the START condition here. SCLK-High, SDA-High to low
						I2C_SDA<=1'b0;
						busy<=1;
						state<=state+1;
						count=0;
				end
				
			2:	begin  		                       // Initiate sending of Slave Address, use default 7-bit address 1001 101b,				      				
					I2C_SDA_Direction<=1'b1;
					I2C_SCLK<=1'b0;                 //First falling SCLK edge for initiating data transfer
					state<=state+1;
					count=count+1;
				end
				
			3:	begin  		              				      
					I2C_SDA_Direction<=1'b1;
					I2C_SCLK<=1'b0;                //SCLK low
					I2C_SDA<=add2[count-1];        //1st bit of address put on bus     
					state<=state+1;
					
				end
				
			4:	begin  		              				      
					I2C_SDA_Direction<=1'b1;
					                               //First Rising edge-Address bit latched			 
					if(count>=7)
					begin
						state<=state+1;
						count=0;                   //Reset count
						I2C_SCLK<=1'b1;
					end
					else
					begin
						state<=2;
						I2C_SCLK<=1'b1;
					end
				end
				
			5: begin
			     I2C_SDA_Direction<=1'b1;
				  I2C_SCLK<=1'b0;                
			     I2C_SDA<=1'b0;                 
				  state<=state+1;                  
		      end
			
			6: begin
			     I2C_SDA_Direction<=1'b1;
				  I2C_SCLK<=1'b0;                //SCLK low
			     I2C_SDA<=1'b0;                 //R/W bit put on bus, Read Op=1, Write Op=0 first phase R/W=0
				  state<=state+1;                  
		      end
				
			7: begin
			     I2C_SDA_Direction<=1'b1;
				  I2C_SCLK<=1'b1;               //SCLK rising edge
			     I2C_SDA<=1'b0;                //R/W bit latched
				  state<=state+1;
		      end
			
			8: begin
			     I2C_SDA_Direction<=1'b0;
				  I2C_SCLK<=1'b0;               //SCLK falling edge  
		        state<=state+2;
				end
				
//			//9: begin
//			     I2C_SDA_Direction<=1'b0;
//				  I2C_SCLK<=1'b1;               //SCLK low 
//				  state<=state+1;
//		      end
				
			10: begin	
			     
				  I2C_SDA_Direction<=1'b0;
				  I2C_SCLK<=1'b1; 
				  if (I2C_SDA_Output==1'b0)            //ACK bit
				  begin
					state<=state+1;
				  end
				  else
				  begin
					I2C_SCLK<=1'b1;
					state<=0;
				  end
		      end
				
			11: begin
			     I2C_SDA_Direction<=1'b1; 
			     I2C_SCLK<=1'b0;               //SCLK stays low
			     state<=state+1;               
		        count=count+1;                //Add Count
				end	
				
			12: begin
			     I2C_SDA_Direction<=1'b1;
				  I2C_SCLK<=1'b0;               //SCLK stays low
			     I2C_SDA<=cmd_RTR[count-1];    //1st bit of the command is put on the bus
				  state<=state+1;
		      end
				
			13: begin  		              				      
					I2C_SDA_Direction<=1'b1;
					I2C_SCLK<=1'b1;              //First Rising edge-Command bit latched			 
					if(count>7)
					begin
						state<=state+1;
						count=0;                   //Reset count
					end
					else
					begin
						state<=11;
					end
				end
				
			14: begin
			     I2C_SDA_Direction<=1'b0;
				  I2C_SCLK<=1'b0;               //SCLK falling edge  
		        state<=state+2;
				end
				
//			//15: begin
//			     I2C_SDA_Direction<=1'b0;
//				  I2C_SCLK<=1'b1;               //SCLK low                
//				  state<=state+1;
//				  end
				
			16: begin
			     I2C_SDA_Direction<=1'b0;
				  I2C_SCLK<=1'b1;
				  if (I2C_SDA_Output==1'b0)            //ACK bit
				  state<=state+1;
				  
				  else
				  begin
				  //I2C_SCLK<=1'b0;
				  state<=0;
				  end
		      end
				
				
		17: begin
			         I2C_SDA_Direction<=1'b1;
         			I2C_SCLK<=1'b0;          // Bring SCLK low
						                         //Doesnt Matter, direction is read
						state<=state+1;
				 end
				 
		  18: begin
			         I2C_SDA_Direction<=1'b1;
         			I2C_SCLK<=1'b0;          // Prepare for START condition here. Make SCLK-Low, SDA-High
						I2C_SDA<=1'b1;
						state<=state+1;
				 end
				 
			19: begin
         			I2C_SDA_Direction<=1'b1;
						I2C_SCLK<=1'b1;          // Initiate the START condition here. SCLK-High, SDA-High to low
						I2C_SDA<=1'b1;           //Data Stays the same
						state<=state+1;
				 end
				 
			20: begin
			         I2C_SDA_Direction<=1'b1;
         			I2C_SCLK<=1'b1;         // Make SCLK high        
						I2C_SDA<=1'b0;          //START condition
						state<=state+1;
				 end	
			
			21: begin
			         I2C_SDA_Direction<=1'b1;
         			I2C_SCLK<=1'b0;         // Make SCLK low        
						state<=state+1;
			         count<=count+1;
				 end
				
			22: begin  		              				      
					I2C_SDA_Direction<=1'b1;
					I2C_SCLK<=1'b0;                //SCLK low
					I2C_SDA<=add2[count-1];        //1st bit of address put on bus     
					state<=state+1;
				 end
				
			23:	begin  		              				      
					I2C_SDA_Direction<=1'b1;
					I2C_SCLK<=1'b1;               //First Rising edge-Address bit latched			 
					if(count>=7)
					begin
						state<=state+1;
						count=0;                   //Reset count
					end
					else
					begin
						state<=21;
					end
				end
				
			24: begin
			     I2C_SDA_Direction<=1'b1;
			     I2C_SCLK<=1'b0;                //SCLK low
			     I2C_SDA<=1'b0;                 
				  state<=state+1;                  
		      end
				
			25: begin
			     I2C_SDA_Direction<=1'b1;
			     I2C_SCLK<=1'b0;                //SCLK low
			     I2C_SDA<=1'b1;                 //R/W bit put on bus, Read Op=1, Write Op=0
				  state<=state+1;                  
		      end
			
			26: begin
			     I2C_SDA_Direction<=1'b1;
				  I2C_SCLK<=1'b1;               //SCLK rising edge
			     I2C_SDA<=1'b1;                //R/W bit latched
				  state<=state+1;
		      end
			
			27: begin
			     I2C_SDA_Direction<=1'b0;
			     I2C_SCLK<=1'b0;               //SCLK falling edge  
		        state<=state+1;
				end
				  
			28: begin
			     I2C_SDA_Direction<=1'b0;
			     if (I2C_SDA_Output==1'b0)    //ACK bit check
				  begin
				  state<=state+1;
				  I2C_SCLK<=1'b1;
				  end
				  else
				  begin
					I2C_SCLK<=1'b0;
					state<=0;
				  end
		      end
				
				
			29: begin
         	 I2C_SDA_Direction<=1'b0;
				 I2C_SCLK<=1'b0;              // Make SCLK low        
				 state<=state+1;
			    count<=8;                     //Set Counter
				 end
				 
			30: begin
         	 I2C_SDA_Direction<=1'b0;
				 I2C_SCLK<=1'b0;                        // Keeping SCLK low
			                                           //Slave puts Data on the Bus                   
				 state<=state+1;
				 end
			
			31: begin
         	 I2C_SDA_Direction<=1'b0;
				 I2C_SCLK<=1'b1;                        // Keeping SCLK low
			    data_buffer[count-1]<=I2C_SDA_Output;  //FPGA reads the Data                   
				 count<=count-1;
				 state<=state+1;
				 end
				
			32: begin
         	 I2C_SDA_Direction<=1'b0;
				 I2C_SCLK<=1'b0;                        // Keeping SCLK low
					if(count!=0)
					begin
					 state<=30;	                        //Reset count
					end
					else
					begin
						state<=state+1;
						count=0;
					end
				end
			
		 	33: begin
         	 I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b0;                    //Clock remains low
				 I2C_SDA<=1'b1;                     //Change Data-FPGA NACK bit
				 state=state+1;
				 end
				
			34: begin
			    I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b1;                  //Change Clock-Make Clock High
				 I2C_SDA<=1'b1;                   //Keep Data same
				 state=state+1;
				 end
				 
			35: begin
			    I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b0;                 //Change clock-Make Clock low
				 I2C_SDA<=1'b1;                  //Keep Data the same
				 state=state+1;
				 end
				 
			36: begin
			    I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b0;                 //Keep Clock the same-Clock low
				 I2C_SDA<=1'b0;                  //Change Data
				 state=state+1;
				 end
				 
			37: begin
			    I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b1;                 //Change clock-clock becomes high
				 I2C_SDA<=1'b0;                  //Keep data same-Data low
				 state=state+1;
				 end

			38: begin
			    I2C_SDA_Direction<=1'b1;
				 I2C_SCLK<=1'b1;                 //Keep clock the same-clock remains high
				 I2C_SDA<=1'b1;                  //Change Data-Data becomes high_StOP bit
				 state=state+1;
				 data_read<=data_buffer;
				 end
				 			 
	   default: begin
			         I2C_SCLK<=1'b1;
						I2C_SDA<=1'b1;
						I2C_SDA_Direction<=1'b1;
						busy<=0;
						count=0;
						state<=0;
					end
		
	    endcase
	end
end
	  
assign I2C_SDA_Output =I2C_SDA_Direction?I2C_SDA:1'bz;

endmodule
			
//module simulation();
//
//reg clock;
//wire Status_Clock;
//wire Data;
//wire busy;
//
//I2C_TC74_Read TC74_Timing_Check(
//		.CLK(clock),		
//                       //Address of the register to be read from TC74, use the default address specified in the datasheet
//		
//		.enable(1'b1),                        //This is turned high in order to activate the communication between FPGA & TC74                   
//		.I2C_SDA(Data),                       //Bidirectional Data line
//		.busy(busy),                     //The O/P for this is high when the I2C bus is in use
//		.I2C_SCLK(Status_Clock));
//
//		initial
//		begin
//		 clock<=0;
//		end
//		
//		always
//		begin
//		#5 clock<=~clock;
//		end
//endmodule		