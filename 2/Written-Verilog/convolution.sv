module convolution (	
                oGray,
				oDVAL,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
                horz_en, 
                gray_en
				);

    input	[11:0]	    iDATA;
    input			    iDVAL;
    input			    iCLK;
    input			    iRST;
    input               horz_en;
    input               gray_en;

    output          oDVAL;
    output	[17:0]	oGray;

    // Hold three elements from three rows at a time to perform convolution with a 3x3 filter 
    wire [11:0]	mDATA_0;
    wire [11:0]	mDATA_1;
    wire [11:0]	mDATA_2;
    reg  [11:0]	mDATAd_0;
    reg	 [11:0]	mDATAd_1;
    reg	 [11:0]	mDATAd_2;
    reg	 [11:0]	mDATAdd_0;
    reg	 [11:0]	mDATAdd_1;
    reg	 [11:0]	mDATAdd_2;

    reg	 [17:0]	mGray;
    reg			mDVAL;

    assign	oDVAL	=	mDVAL;
    assign  oGray   =   mGray;

    // Available filters for convolution, chosen by switch inputs //
    logic signed [2:0] filt1[0:2][0:2]; // Vertical edge detector 
    logic signed [2:0] filt2[0:2][0:2]; // Horizontal edge detector 
    logic signed [2:0] filt3[0:2][0:2]; // Pass-through filter (to show grayscale)

    logic signed [2:0] filt[0:2][0:2];

    // Output is grayscale if SW[1] is high, otherwise the edge detector filter is selected by SW[2]
    assign filt = gray_en ?  filt3
                          : (horz_en ? filt2 
                                     : filt1);
    
    assign filt1 = '{
        '{-3'sd1, 3'sd0, 3'sd1},
        '{-3'sd2, 3'sd0, 3'sd2},
        '{-3'sd1, 3'sd0, 3'sd1}
    };

    assign filt2 = '{
        '{-3'sd1, -3'sd2, -3'sd1},
        '{3'sd0, 3'sd0, 3'sd0},
        '{3'sd1, 3'sd2, 3'sd1}
    };

    assign filt3 = '{
        '{3'sd0, 3'sd0, 3'sd0},
        '{3'sd0, 3'sd1, 3'sd0},
        '{3'sd0, 3'sd0, 3'sd0}
    };

    Line_Buffer2 	u0	(	.clken(iDVAL),
                            .clock(iCLK),
                            .shiftin(iDATA),
                            .taps0x(mDATA_2),
                            .taps1x(mDATA_1),
                            .taps2x(mDATA_0)	);

    always@(posedge iCLK or negedge iRST)
    begin
        if(!iRST)
        begin
            mGray	  <=	0;
            mDATAd_0  <=	0;
            mDATAd_1  <=	0;
            mDATAd_2  <=    0;
            mDATAdd_0 <=    0;
            mDATAdd_1 <=    0;
            mDATAdd_2 <=    0;

            mDVAL	<=	0;
        end
        else
        begin
            // Data is valid everytime we shift in new data because we want overlap with convolution
            mDVAL		<=	iDVAL;

            if (iDVAL) begin
                mDATAd_0	<=	mDATA_0;
                mDATAd_1	<=	mDATA_1;
                mDATAd_2	<=	mDATA_2;
                mDATAdd_0	<=	mDATAd_0;
                mDATAdd_1	<=	mDATAd_1;
                mDATAdd_2	<=	mDATAd_2;

                // Current output pixel is a weighted sum (based on filter) of 9 neighboring pixels (in square shape)
                mGray       <= ($signed({1'b0, mDATA_0}) * filt[0][2]) + 
                                        ($signed({1'b0, mDATAd_0}) * filt[0][1]) + 
                                                ($signed({1'b0, mDATAdd_0}) * filt[0][0]) +

                            ($signed({1'b0, mDATA_1}) * filt[1][2]) + 
                                        ($signed({1'b0, mDATAd_1}) * filt[1][1]) + 
                                                    ($signed({1'b0, mDATAdd_1}) * filt[1][0]) +

                            ($signed({1'b0, mDATA_2}) * filt[2][2]) + 
                                        ($signed({1'b0, mDATAd_2}) * filt[2][1]) + 
                                                    ($signed({1'b0, mDATAdd_2}) * filt[2][0]); 
            end
        end
    end 

endmodule