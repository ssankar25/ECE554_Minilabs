//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );

    // Internal signals
    wire spart_rd_status_en;
    wire spart_rd_receive_buf_en;
    wire [7:0] receive_buf;
    wire spart_trmt_en;
    wire baud_trmt_en;
    wire baud_receive_en;  
    wire transmitting;
    reg transmitting_ff;

    // BUS INTERFACE //
    assign spart_rd_status_en = (ioaddr == 2'b01) & iorw;
    assign spart_rd_receive_buf_en = (ioaddr == 2'b00) & iorw;

    assign databus = iocs ? 8'hzz 
                            : (spart_rd_status_en ? {6'h00, tbr, rda}
                                                    : (spart_rd_receive_buf_en ? receive_buf
                                                                                : 8'hzz));
    
    assign transmitting = (ioaddr == 2'b00) & ~iorw;

    // assert UART trmt signal on rising edge of transmitting
    assign spart_trmt_en = transmitting & ~transmitting_ff; 

    always @(posedge clk, negedge rst) begin
        if (!rst) 
            transmitting_ff <= 1'b0;
        else begin
            transmitting_ff <= transmitting;
        end
    end

    // BAUD RATE GENERATOR //
    brg iBRG (
        .clk(clk),
        .rst_n(rst),
        .data(databus),
        .ioaddr(ioaddr),
        .baud_trmt_en(baud_trmt_en),
        .baud_receive_en(baud_receive_en)
    );

    UART_tx iTRANSMIT(
        .clk(clk),      // system clock.
        .rst_n(rst),    // Asynchronous active low reset.
        .trmt(spart_trmt_en),	    // Asserted for 1 clock to initiate transmission.
        .tx_data(databus),     // Byte to transmit
        .tx_done(tbr),     // Asserted when byte is done transmitting. Stays high till next byte transmitted. 
        .TX(txd),		    // Serial data output.
        .baud_en(baud_trmt_en)
    );

    UART_rx iRECEIVE(
        .clk(clk),      // system clock.
        .rst_n(rst),    // Asynchronous active low reset.
        .RX(rxd),	        // Serial data input.
        .clr_rdy(),	    // Knocks down rdy when asserted.
        .rx_data(receive_buf),     // Byte received.
        .rdy(rda),	    // Asserted when byte received. Stays high till start bit of next byte starts, or until clr_rdy asserted.
        .baud_en(baud_receive_en)
    );


endmodule
