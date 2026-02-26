//////////////////////////////////////////////////
// UART_tx.sv                                  //
// This design will infer a UART transmitter  //
// block.                                    //
//////////////////////////////////////////////
module UART_tx(
  input logic clk,   // 50MHz system clock.
  input logic rst_n, // Asynchronous active low reset.
  input logic trmt,	 // Asserted for 1 clock to initiate transmission.
  input logic [7:0] tx_data, // Byte to transmit.
  input logic baud_en,
  output logic tx_done,	// Asserted when byte is done transmitting. Stays high till next byte transmitted. 
  output logic TX		// Serial data output.
);

  ////////////////////////////////////////
  // Declare state types as enumerated //
  //////////////////////////////////////
  // We have 2 states in total, IDLE and TRM.
  typedef enum logic {IDLE, TRM} state_t;
    
  ///////////////////////////////////
	// Declare any internal signals //
	/////////////////////////////////
	logic [8:0] tx_shft_reg;    // The register holding the values to be shifted out.
  logic init; // Asserted to begin transmission of data.
	logic shift; // Asserted to begin shifting whenever baud count is reached.
  logic transmitting; // Asserted whenever we are still transmitting data along TX line.
  logic [3:0] bit_cnt; // Count to keep track of how many bits of data we shifted.
  logic set_done;     // Asserted whenever the transmission of a packet is finished (10-bits).
  logic trmt_set;     // Held high after trmt asserted to synch start of transmission with baud clk
  logic clr_trmt_set;  // Used to clear the trmt_set signal once transmission has started
  logic [7:0] tx_data_saved;  // Used to load the shift register on start of transmission
  state_t state;     // Holds the current state.
	state_t nxt_state; // Holds the next state.		
  ///////////////////////////////////////////////

  // Implement the shift register of the UART TX to transmit a byte of data.
  always_ff @(posedge clk, negedge rst_n) begin
      if(!rst_n)
        tx_shft_reg <= 9'h1FF; // Reset the register to all ones, indicating line is IDLE.
      else if (init)
        tx_shft_reg <= {tx_data_saved, 1'b0}; // If init is asserted, load the data in along with the start bit.
      else if (shift)          
        tx_shft_reg <= {1'b1, tx_shft_reg[8:1]}; // Begin shifting out the data 1-bit each, starting with LSB.
  end
  
  // Implement counter to count number of bits shifted out on the TX line.
  always_ff @(posedge clk) begin
      if (init)
        bit_cnt <= 4'h0; // Reset to 0 initially.
      else if (shift) 
         bit_cnt <= bit_cnt + 1'b1; // Increment the bit count whenever we shift a bit.
  end

  // Take the LSB of the shift register as the data shifted out, i.e., on the TX line.
  assign TX = (state == TRM) ? tx_shft_reg[0] : 1'b1;
    
  // We shift out data whenever we reach a baud count of 2604 clock cycles.
  assign shift = baud_en & (state == TRM);
  
  ////////////////////////////////////
	// Implement State Machine Logic //
	//////////////////////////////////

  // Implements state machine register, holding current state or next state, accordingly.
  always_ff @(posedge clk, negedge rst_n) begin
      if(!rst_n)
        state <= IDLE; // Reset into the idle state if machine is reset.
      else
        state <= nxt_state; // Store the next state as the current state by default.
  end

  // Implements the SR flop to hold the tx_done signal until trmt is asserted, after transmission is complete. 
  always_ff @(posedge clk, negedge rst_n) begin
      if(!rst_n)
        tx_done <= 1'b0; // Asynchronously reset the flop.
      else if (init)
        tx_done <= 1'b0; // Clear the flop synchronously.
      else if (set_done)
        tx_done <= 1'b1; // Synchronously preset the flop to 1, if transmission is done.
      else 
        tx_done <= 1'b0;
  end

  always_ff @(posedge clk, negedge rst_n) begin
      if(!rst_n)
        trmt_set <= 1'b0; 
      else if (clr_trmt_set)
        trmt_set <= 1'b0;
      else if (trmt)          
        trmt_set <= 1'b1;
  end

  always_ff @(posedge clk, negedge rst_n) begin
      if(!rst_n)
        tx_data_saved <= 8'h00; 
      else if (trmt)          
        tx_data_saved <= tx_data;
  end


  /////////////////////////////////////////
	// Default all SM outputs & nxt_state //
	///////////////////////////////////////
	always_comb begin
    // Implements the combinational state transition and output logic of the state machine.
		nxt_state = state; // By default, assume we are in the current state.
    init = 1'b0; // By defualt, init is low.
    transmitting = 1'b0; // By default, assume data is not being transmitted. 
    set_done = 1'b0; // By default, rdy is not asserted.
    clr_trmt_set = 1'b0;
        		
		case (state)
		  TRM : begin // Transmit the data.
		    if(bit_cnt >= 4'hA) begin
          set_done = 1'b1; // We are done transmitting, and assert done.
          nxt_state = IDLE; // Head back to the IDLE state to transmit a new byte of data.
        end else begin
          transmitting = 1'b1; // If the bit count is not 10, in decimal, we continue transmitting and stay in this state.
        end
      end

      default : begin // Used as the IDLE state. Checks if trmt is asserted, else stay in the current state.
        if(trmt_set && baud_en) begin
			      nxt_state = TRM; // If go is asserted, next state is TRM, and shifting data begins.
            init = 1'b1; // Assert init, to initialize the operands and begin the shifting.
            clr_trmt_set = 1'b1;
        end
      end
		endcase
  end
			
endmodule