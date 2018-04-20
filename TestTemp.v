
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module TestTemp(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Arduino //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// GPIO, GPIO connect to GPIO Default //////////
	inout 		    [35:0]		GPIO
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

I2C_TC74_Read Temperature(
		.CLK(MAX10_CLK1_50),		
      //.[7:0] add1,                    //Address of the register to be read from TC74, use the default address specified in the datasheet
		//output reg [7:0] data_read,
		.enable(1'b1),                        //This is turned high in order to activate the communication between FPGA & TC74                   
		.reset(SW[1]),
		.I2C_SDA_Output(GPIO[5]),                  
		//output reg busy, 		//The O/P for this is high when the I2C bus is in use
		.I2C_SCLK(GPIO[7]));


//=======================================================
//  Structural coding
//=======================================================



endmodule
