//Description: This file contains the implementation of FSM and SPI interface
// 				The FPGA is configured as a slave to receive the command from the master.
//					The FSM instance then will handle the received command.
//					The current state of the FSM will then be saved to the buffer to send back to the master via SPI interface.
//					Master command to get state is: 11111111
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module SpiLab
	(
	input[35:0] GPIO_0, //MOSI, CS, CLK
	output[35:0] GPIO_1, //MIsO
	input CLOCK_50,
	input[9:0] SW // i_Data, RESET_N
	);

	localparam Spi_Mode = 0;
	
	//Slave specific
	reg       w_Slave_RX_DV, r_Slave_TX_DV;
	reg [7:0] w_Slave_RX_Byte, r_Slave_TX_Byte;
	reg r_Rst_L = 1'b0; //init with default value
	
	//FSM
	reg[1:0] fsm_state;
	
	//Clock divider variables
	wire clock_out_spi;
	
	//Clock divider to output the clock at 25MHz
	Des_Devide_Clock clockDiv(.clock_in(CLOCK_50), .clock_out(clock_out_spi));

	// Instantiate FPGA board as a slave to receive the command from ESP32
	SPI_Slave #(.SPI_MODE(Spi_Mode)) spiSlaveHw
	(
	.i_Rst_L(r_Rst_L),
	.i_Clk(clock_out_spi),
	.o_RX_DV(w_Slave_RX_DV),
	.o_RX_Byte(w_Slave_RX_Byte),
	.i_TX_DV(r_Slave_TX_DV),
	.i_TX_Byte(r_Slave_TX_Byte),
	
	//SPI interface
	.i_SPI_Clk(GPIO_0[2]),
	.o_SPI_MISO(GPIO_1[0]),
	.i_SPI_MOSI(GPIO_0[0]),
	.i_SPI_CS_n(GPIO_0[1])
	);
	
	//FSM instance here
	fsm fsmLab
	(
	.i_Clk(clock_out_spi),
	.i_Rst(SW[1]),
	.i_Data(SW[0]),
	.o_State(fsm_state)
	);
	
	//Polling to wait for master's command
	always @(posedge clock_out_spi)
	
	if(w_Slave_RX_Byte == 8'b11111111)
		begin
			r_Slave_TX_Byte <= fsm_state; //update FSM state to slave tx buffer
		end
	
endmodule