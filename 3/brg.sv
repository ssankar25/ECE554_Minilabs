module brg(
    input clk,
    input rst_n,
    input [7:0] data,
    input [1:0] ioaddr,
    output baud_trmt_en,
    output baud_receive_en
    );

    // Internal signals.
    logic load_db_low;
    logic load_db_high;
    logic load_db_done;
    logic load_db_done_ff;
    logic [15:0] divisor_buffer;
    logic [15:0] down_cntr;
    logic [3:0] down_cntr_wrapper;

    /// DIVISOR BUFFER ///
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            divisor_buffer <= 16'h0000;
            load_db_done <= 1'b0;
        end
        else if (load_db_low)
            divisor_buffer[7:0] <= data;
        else if (load_db_high) begin
            // Loading low byte first, then high byte
            divisor_buffer[15:8] <= data;
            load_db_done <= 1'b1;
        end
    end

    assign load_db_low = (ioaddr == 2'b10);
    assign load_db_high = (ioaddr == 2'b11);

    /// DOWN COUNTER ///
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            down_cntr <= 16'hFFFF;
        else if ((load_db_done && !load_db_done_ff) | (down_cntr == 16'h0000))
            down_cntr <= divisor_buffer;
        else
            down_cntr <= down_cntr - 1'b1;
    end

    /// DOWN COUNTER WRAPPER ///
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            down_cntr_wrapper <= 4'hF;
        else if (down_cntr == 16'h0000)
            down_cntr_wrapper <= down_cntr_wrapper - 1'b1;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
          load_db_done_ff <= 1'b0;
        else 
          load_db_done_ff <= load_db_done;
    end

    assign baud_trmt_en = (down_cntr_wrapper == 4'h0 && down_cntr == 16'h0000);
    assign baud_receive_en = (down_cntr_wrapper == 4'h8 && down_cntr == 16'h0000);
    

endmodule