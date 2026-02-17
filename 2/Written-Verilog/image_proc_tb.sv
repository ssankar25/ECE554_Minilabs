`timescale 1 ps / 1 ps

module image_proc_tb();

    logic signed	[10:0]	iX_Cont;
    logic	[10:0]	iY_Cont;
    logic	[11:0]	iDATA;
    logic			iDVAL;
    logic			iCLK;
    logic			iRST;
    logic	[11:0]	oRed;
    logic	[11:0]	oGreen;
    logic	[11:0]	oBlue;
    logic			oDVAL;
    logic           gray_en;
    logic           horz_en;

    image_proc iDUT (.*);

    initial begin
        iCLK = 0;
        iRST = 0;
        iDVAL = 1'b0;
        gray_en = 1'b0;
        horz_en = 1'b0;

        @(negedge iCLK);
        @(negedge iCLK);

        iRST = 1;

        @(posedge iCLK);

        iDVAL = 1'b1;

        //// TEST VERTICAL FILTER ////

        /* Inputting:
        [5, 3, 9, 20, 76, 0, 0, ...]
        [0, 0, 0,  0,  0, 0, 0, ...] */
        iDATA = 5;
        @(posedge iCLK) iDATA = 3;
        @(posedge iCLK) iDATA = 9;
        @(posedge iCLK) iDATA = 20;
        @(posedge iCLK) iDATA = 76;
        @(posedge iCLK) iDATA = 0;

        /* After grayscale:
        [2, 7, 19, 0, 0, ...]
        [0, 0,  0, 0, 0, ...] */

        /* After convolution + abs with vertical filter:
        [2,  7, 17,  7, 19, 0, 0, ...]
        [4, 14, 34, 14, 38, 0, 0, ...]
        [2,  7, 17,  7, 19, 0, 0, ...]
        [0,  0,  0,  0,  0, 0, 0, ...] */

        // Check first row //
        @(oRed)
        if (oRed !== 2) begin
            $display("[0][0] should be 2, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 7) begin
            $display("[0][1] should be 7, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 17) begin
            $display("[0][2] should be 17, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 7) begin
            $display("[0][3] should be 7, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 19) begin
            $display("[0][4] should be 19, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 0) begin
            $display("[0][5] should be 0, instead its: %d", oRed);
            $stop();
        end


        // Check second row //
        @(oRed)
        if (oRed !== 4) begin
            $display("[1][0] should be 4, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 14) begin
            $display("[1][1] should be 14, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 34) begin
            $display("[1][2] should be 34, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 14) begin
            $display("[1][3] should be 14, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 38) begin
            $display("[1][4] should be 38, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 0) begin
            $display("[1][5] should be 0, instead its: %d", oRed);
            $stop();
        end

        

        //// TEST HORIZONTAL FILTER ////

        iRST = 0;
        iDVAL = 1'b0;
        horz_en = 1'b1;

        @(negedge iCLK);
        @(negedge iCLK);

        iRST = 1;

        @(posedge iCLK);

        iDVAL = 1'b1;

        /* Inputting:
        [5, 3, 9, 20, 76, 0, 0, ...]
        [0, 0, 0,  0,  0, 0, 0, ...] */
        iDATA = 5;
        @(posedge iCLK) iDATA = 3;
        @(posedge iCLK) iDATA = 9;
        @(posedge iCLK) iDATA = 20;
        @(posedge iCLK) iDATA = 76;
        @(posedge iCLK) iDATA = 0;

        /* After grayscale:
        [2, 7, 19, 0, 0, ...]
        [0, 0,  0, 0, 0, ...] */

        /* After convolution + abs with horizontal filter:
        [2, 11, 35, 45, 19, 0, 0, ...]
        [0,  0,  0,  0,  0, 0, 0, ...]
        [2, 11, 35, 45, 19, 0, 0, ...]
        [0,  0,  0,  0,  0, 0, 0, ...] */

        // Check first row //
        @(oRed)
        if (oRed !== 2) begin
            $display("[0][0] should be 2, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 11) begin
            $display("[0][1] should be 11, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 35) begin
            $display("[0][2] should be 35, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 45) begin
            $display("[0][3] should be 45, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 19) begin
            $display("[0][4] should be 19, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 0) begin
            $display("[0][5] should be 0, instead its: %d", oRed);
            $stop();
        end


        // Check third row //
        @(oRed)
        if (oRed !== 2) begin
            $display("[2][0] should be 2, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 11) begin
            $display("[2][1] should be 11, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 35) begin
            $display("[2][2] should be 35, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 45) begin
            $display("[3][3] should be 45, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 19) begin
            $display("[4][4] should be 19, instead its: %d", oRed);
            $stop();
        end

        @(oRed)
        if (oRed !== 0) begin
            $display("[5][5] should be 0, instead its: %d", oRed);
            $stop();
        end


        $display("All tests passed");
        $stop();
    end


    // Generate iX_Cont and iY_Cont //
    logic [1:0] startup_count;

    always @(posedge iCLK, negedge iRST) begin
        if (!iRST) begin
            iX_Cont <= 0;
            iY_Cont <= 0;
            startup_count <= 0;
        end
        else begin
            if (startup_count < 2) begin
                iX_Cont <= 0;
                startup_count <= startup_count + 1;
            end
        
            else begin
                if($unsigned(iX_Cont) < (1279))
                    iX_Cont	<=	iX_Cont + 1;
                else begin
                    iX_Cont	<=	0;
                    iY_Cont	<=	iY_Cont + 1;
                end 
            end
        end
    end

    always 
        #5 iCLK = ~iCLK;

endmodule