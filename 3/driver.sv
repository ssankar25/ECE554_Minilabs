//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
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
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output logic iocs,
    output logic iorw,
    input rda,
    input tbr,
    output logic [1:0] ioaddr,
    inout wire [7:0] databus
    );

    typedef enum logic [2:0] {IDLE, LOAD_LB, LOAD_HB, START_RECEIVE, RECEIVE, START_SEND, SEND} state_t;

    state_t state, nxt_state;

    logic [15:0] baud_cnt;
    logic [7:0] data;
    logic [1:0] databus_cntrl;

    assign databus = (databus_cntrl == 2'b11) ? data
                                             : ((databus_cntrl == 2'b10) ? baud_cnt[15:8]
                                                                        : ((databus_cntrl == 2'b01) ? baud_cnt[7:0]
                                                                                                   : 8'hzz));

    localparam FREQUENCY = 50000000;

    /// DECODE BAUD OPCODE ///
    always_comb begin : decoder
        case(br_cfg)
           2'b00: baud_cnt = int'((FREQUENCY/(16*4800)) - 1);
           2'b01: baud_cnt = int'((FREQUENCY/(16*9600)) - 1);
           2'b10: baud_cnt = int'((FREQUENCY/(16*19200)) - 1);
           2'b11: baud_cnt = int'((FREQUENCY/(16*38400)) - 1);
        endcase  
    end

    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            state <= IDLE;
        end
        else begin
            state <= nxt_state;
        end
    end

    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            data <= 8'h00;
        end
        else if (rda) begin
            data <= databus;
        end
    end

    always_comb begin: FSM
        nxt_state = state;
        iocs = 1'b0;
        iorw = 1'b0;
        ioaddr = 2'b10;
        databus_cntrl = 2'b00;

        case (state)
            IDLE: begin
                nxt_state = LOAD_LB;
            end
            LOAD_LB: begin
                nxt_state = LOAD_HB;
                ioaddr = 2'b10;
                databus_cntrl = 2'b01;
            end
            LOAD_HB: begin
                nxt_state = START_RECEIVE;
                ioaddr = 2'b11;
                databus_cntrl = 2'b10;
            end
            START_RECEIVE: begin
                iorw = 1'b1;
                ioaddr = 2'b00;
                nxt_state = RECEIVE;
            end
            RECEIVE: begin
                iorw = 1'b1;
                ioaddr = 2'b00;

                if (rda) 
                    nxt_state = START_SEND;
            end
            START_SEND: begin
                iorw = 1'b0;
                ioaddr = 2'b00;
                databus_cntrl = 2'b11;
                nxt_state = SEND;
            end
            SEND: begin
                iorw = 1'b0;
                ioaddr = 2'b00;

                if (tbr)
                    nxt_state = START_RECEIVE;
            end
        endcase
    end


endmodule
