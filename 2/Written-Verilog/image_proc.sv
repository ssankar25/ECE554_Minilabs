module image_proc(	oRed,
				oGreen,
				oBlue,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				gray_en,
				horz_en
				);

    input	[10:0]	iX_Cont;
    input	[10:0]	iY_Cont;
    input	[11:0]	iDATA;
    input			iDVAL;
    input			iCLK;
    input			iRST;
	input			gray_en;
	input			horz_en;
    output	[11:0]	oRed;
    output	[11:0]	oGreen;
    output	[11:0]	oBlue;
    output			oDVAL;

	////////////////////////////////////////////////////
	
	logic [11:0] grayscale_conv_out;
    logic grayscale_conv_dval;
    logic signed [17:0] oGray;
	logic [17:0] oGray_abs;
	logic [11:0] oGray_abs_trunc;
	logic conv_dval;

	/// ABSOLUTE VALUE ///
    assign oGray_abs = ((oGray[17]) ? -oGray[17:0] : oGray[17:0]);
	assign oGray_abs_trunc = oGray_abs[11:0];

	assign oRed = oGray_abs_trunc;
	assign oGreen = oGray_abs_trunc;
	assign oBlue = oGray_abs_trunc;
	assign oDVAL = conv_dval;

	/// GRAYSCALE CONVERSION ///
    grayscale_conv iGRAY (	
                .oGray(grayscale_conv_out),
				.oDVAL(grayscale_conv_dval),
				.iX_Cont(iX_Cont),
				.iY_Cont(iY_Cont),
				.iDATA(iDATA),
				.iDVAL(iDVAL),
				.iCLK(iCLK),
				.iRST(iRST)
				);


	/// CONVOLUTION ///
    convolution iCONV (	
                .oGray(oGray),
				.oDVAL(conv_dval),
				.iDATA(grayscale_conv_out),
				.iDVAL(grayscale_conv_dval),
				.iCLK(iCLK),
				.iRST(iRST),
				.horz_en(horz_en),
				.gray_en(gray_en)
				);
    

endmodule