module Minilab3_tb();

   // DUT Signals
   logic clk, rst_n;
   logic [1:0] br_cfg;
   logic txd_dut, rxd_dut;

    Minilab3 iDUT(
      .CLOCK_50(clk),
      .CLOCK2_50(),
      .CLOCK3_50(),
      .CLOCK4_50(),
      .HEX0(),
      .HEX1(),
      .HEX2(),
      .HEX3(),
      .HEX4(),
      .HEX5(),
      .KEY({3'b000, rst_n}),
      .LEDR(),
      .SW({br_cfg, 8'h00}),
      .GPIO_TX(txd_dut),
      .GPIO_RX(rxd_dut)
);

   // Testbench Driver Signals 
    logic iorw_tb, rda_tb, tbr_tb, txd_tb, rxd_tb, iocs_tb;
    logic [1:0] ioaddr_tb;
    tri   [7:0] databus_tb;
    logic [15:0] baud_cnt_tb;
    logic [7:0] data_tb;
    logic [1:0] databus_cntrl_tb;

    assign rxd_dut = txd_tb;
    assign rxd_tb = txd_dut;

    spart spart1(.clk(clk),
                .rst(rst_n),
                .iocs(iocs_tb),
                .iorw(iorw_tb),
                .rda(rda_tb),
                .tbr(tbr_tb),
                .ioaddr(ioaddr_tb),
                .databus(databus_tb),
                .txd(txd_tb),
                .rxd(rxd_tb)
            );

    typedef enum logic [2:0] {IDLE, LOAD_LB, LOAD_HB, START_SEND, SEND, START_RECEIVE, RECEIVE} state_t;

    state_t state, nxt_state;

    assign databus_tb = (databus_cntrl_tb == 2'b11) ? data_tb
                                             : ((databus_cntrl_tb == 2'b10) ? baud_cnt_tb[15:8]
                                                                        : ((databus_cntrl_tb == 2'b01) ? baud_cnt_tb[7:0]
                                                                                                   : 8'hzz));

    localparam FREQUENCY = 50000000;

    /// DECODE BAUD OPCODE ///
    always_comb begin
        case(br_cfg)
           2'b00: baud_cnt_tb = int'((FREQUENCY/(16*4800)) - 1);
           2'b01: baud_cnt_tb = int'((FREQUENCY/(16*9600)) - 1);
           2'b10: baud_cnt_tb = int'((FREQUENCY/(16*19200)) - 1);
           2'b11: baud_cnt_tb = int'((FREQUENCY/(16*38400)) - 1);
        endcase  
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= nxt_state;
        end
    end

    // Create Driver SM for TB Spart
    always_comb begin: FSM
        nxt_state = state;
        iocs_tb = 1'b0;
        iorw_tb = 1'b0;
        ioaddr_tb = 2'b10;
        databus_cntrl_tb = 2'b00;

        case (state)
            IDLE: begin
                nxt_state = LOAD_LB;
            end
            LOAD_LB: begin
                nxt_state = LOAD_HB;
                ioaddr_tb = 2'b10;
                databus_cntrl_tb = 2'b01;
            end
            LOAD_HB: begin
                nxt_state = START_SEND;
                ioaddr_tb = 2'b11;
                databus_cntrl_tb = 2'b10;
            end
            START_SEND: begin
                iorw_tb = 1'b0;
                ioaddr_tb = 2'b00;
                databus_cntrl_tb = 2'b11;
                nxt_state = SEND;
            end
            SEND: begin
                iorw_tb = 1'b0;
                ioaddr_tb = 2'b00;

                if (tbr_tb)
                    nxt_state = START_RECEIVE;
            end
            START_RECEIVE: begin
                iorw_tb = 1'b1;
                ioaddr_tb = 2'b00;
                nxt_state = RECEIVE;
            end
            RECEIVE: begin
                iorw_tb = 1'b1;
                ioaddr_tb = 2'b00;

                if (rda_tb) 
                    nxt_state = START_SEND;
            end
        endcase
    end

   string str1 = "hello";
   string str2 = "hola";

    initial begin
        clk = 1'b0;
        rst_n = 1'b0; // RESET

        ///////////////////////
        ///// FIRST WORD //////
        ///////////////////////

        // SET BAUD RATE TO 4800
        br_cfg = 2'b00;

        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // SEND FIRST CHARACTER
        data_tb = str1[0];

        // RECEIVE FIRST CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND SECOND CHARACTER
        data_tb = str1[1];

        // RECEIVE SECOND CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND THIRD CHARACTER
        data_tb = str1[2];

        // RECEIVE THIRD CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND FOURTH CHARACTER
        data_tb = str1[3];

        // RECEIVE FOURTH CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND FIFTH CHARACTER
        data_tb = str1[4];

        // RECEIVE FIFTH CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);
        $write("\n");

        ///////////////////////
        ///// SECOND WORD /////
        ///////////////////////

        rst_n = 1'b0; // RESET

        // SET BAUD RATE TO 19200
        br_cfg = 2'b10;

        @(negedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // SEND FIRST CHARACTER
        data_tb = str2[0];

        // RECEIVE FIRST CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND SECOND CHARACTER
        data_tb = str2[1];

        // RECEIVE SECOND CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND THIRD CHARACTER
        data_tb = str2[2];

        // RECEIVE THIRD CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        // SEND FOURTH CHARACTER
        data_tb = str2[3];

        // RECEIVE FOURTH CHARACTER
        @(posedge rda_tb);
        $write("%c", databus_tb);

        $write("\n\n");
        $stop();

    end
    

    always 
        #5 clk = ~clk;

endmodule