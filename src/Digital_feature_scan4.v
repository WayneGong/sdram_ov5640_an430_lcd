module Digital_feature_scan4
(
	input                   rst_n,   
	input                   clk,
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de, 

	input		[11:0]		i_x,        // video position X
	input		[11:0]		i_y,         // video position y	
	input		[23:0]		i_data,
	input					i_th,
	
	input		[11:0]		char_up,
	input		[11:0]		char_down,	
	input		[11:0]		char_left,
	input		[11:0]		char_right,
	
	
	output		[8:0]		feature_code,
	output	reg	[3:0]		chepai_Digital,
	
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de

);

wire	[11:0] 	x_cnt	=	i_x;
wire	[11:0]	y_cnt	=	i_y;

reg	[11:0]	feature11_count_reg	,	feature11_count;
reg	[11:0]	feature12_count_reg	,	feature12_count;
reg	[11:0]	feature13_count_reg	,	feature13_count;
reg	[11:0]	feature21_count_reg	,	feature21_count;
reg	[11:0]	feature22_count_reg	,	feature22_count;
reg	[11:0]	feature23_count_reg	,	feature23_count;
reg	[11:0]	feature31_count_reg	,	feature31_count;
reg	[11:0]	feature32_count_reg	,	feature32_count;
reg	[11:0]	feature33_count_reg	,	feature33_count;

assign	feature_code[0]	=	(	feature11_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[1]	=	(	feature12_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[2]	=	(	feature13_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[3]	=	(	feature21_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[4]	=	(	feature22_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[5]	=	(	feature23_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[6]	=	(	feature31_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[7]	=	(	feature32_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[8]	=	(	feature33_count	>=	60	)	?	1'b1	:	1'b0	;

wire	[4:0]	feature_sum	=	feature_code[0]	+	feature_code[1]	+	feature_code[2]	+
                                feature_code[3]	+	feature_code[4]	+	feature_code[5]	+
                                feature_code[6]	+	feature_code[7]	+	feature_code[8]	;

wire	vaule_output	=	(	x_cnt	==	450	&&	y_cnt	==	250	);


wire	featuer_region11	=	(	(	( x_cnt >= char_left )	&&	( x_cnt <= char_left+18	)	)
								&&	(	( y_cnt >= char_up )	&&	( y_cnt <= char_up+25 	)	)	
							);


wire	featuer_region12	=	(	(	( x_cnt >= char_left+18 )	&&	( x_cnt <= char_left+18*2	)	)
								&&	(	( y_cnt >= char_up )	&&	( y_cnt <= char_up+25 	)	)	
							);							
	
wire	featuer_region13	=	(	(	( x_cnt >= char_left+18*2 )	&&	( x_cnt <= char_right	)	)
								&&	(	( y_cnt >= char_up )	&&	( y_cnt <= char_up+25 	)	)	
							);	
							
wire	featuer_region21	=	(	(	( x_cnt >= char_left )	&&	( x_cnt <= char_left+18	)	)
								&&	(	( y_cnt >= char_up+25 )	&&	( y_cnt <= char_up+25*2 	)	)	
							);
		
wire	featuer_region22	=	(	(	( x_cnt >= char_left+18 )	&&	( x_cnt <= char_left+18*2	)	)
								&&	(	( y_cnt >= char_up+25 )	&&	( y_cnt <= char_up+25*2  	)	)	
							);
	
wire	featuer_region23	=	(	(	( x_cnt >= char_left +18*2)	&&	( x_cnt <= char_right	)	)
								&&	(	( y_cnt >= char_up+25 )	&&	( y_cnt <= char_up+25*2  	)	)	
							);
							
wire	featuer_region31	=	(	(	( x_cnt >= char_left )	&&	( x_cnt <= char_left+18	)	)
								&&	(	( y_cnt >= char_up+25*2 )	&&	( y_cnt <= char_down 	)	)	
							);


wire	featuer_region32	=	(	(	( x_cnt >= char_left+18 )	&&	( x_cnt <= char_left+18*2	)	)
								&&	(	( y_cnt >= char_up+25*2 )	&&	( y_cnt <= char_down 	)	)	
							);


wire	featuer_region33	=	(	(	( x_cnt >= char_left+18*2 )	&&	( x_cnt <= char_right	)	)
								&&	(	( y_cnt >= char_up+25*2 )	&&	( y_cnt <= char_down 	)	)	
							);	
	
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature11_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature11_count_reg	<=	'b0;
	else if( featuer_region11 && i_th )  
		feature11_count_reg	<=	feature11_count_reg + 1'b1;
	else
		feature11_count_reg	<=	feature11_count_reg;
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature12_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature12_count_reg	<=	'b0;
	else if( featuer_region12 && i_th )  
		feature12_count_reg	<=	feature12_count_reg + 1'b1;
	else
		feature12_count_reg	<=	feature12_count_reg;
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature13_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature13_count_reg	<=	'b0;
	else if( featuer_region13 && i_th )  
		feature13_count_reg	<=	feature13_count_reg + 1'b1;
	else
		feature13_count_reg	<=	feature13_count_reg;
end

//21
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature21_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature21_count_reg	<=	'b0;
	else if( featuer_region21 && i_th )  
		feature21_count_reg	<=	feature21_count_reg + 1'b1;
	else
		feature21_count_reg	<=	feature21_count_reg;
end

//22
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature22_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature22_count_reg	<=	'b0;
	else if( featuer_region22 && i_th )  
		feature22_count_reg	<=	feature22_count_reg + 1'b1;
	else
		feature22_count_reg	<=	feature22_count_reg;
end


//23
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature23_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature23_count_reg	<=	'b0;
	else if( featuer_region23 && i_th )  
		feature23_count_reg	<=	feature23_count_reg + 1'b1;
	else
		feature23_count_reg	<=	feature23_count_reg;
end

//31
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature31_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature31_count_reg	<=	'b0;
	else if( featuer_region31 && i_th )  
		feature31_count_reg	<=	feature31_count_reg + 1'b1;
	else
		feature31_count_reg	<=	feature31_count_reg;
end

//32
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature32_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature32_count_reg	<=	'b0;
	else if( featuer_region32 && i_th )  
		feature32_count_reg	<=	feature32_count_reg + 1'b1;
	else
		feature32_count_reg	<=	feature32_count_reg;
end

//33
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature33_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature33_count_reg	<=	'b0;
	else if( featuer_region33 && i_th )  
		feature33_count_reg	<=	feature33_count_reg + 1'b1;
	else
		feature33_count_reg	<=	feature33_count_reg;
end
always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			feature11_count	<=	'b0;
		    feature12_count	<=	'b0;
		    feature13_count	<=	'b0;
		    feature21_count	<=	'b0;
		    feature22_count	<=	'b0;
		    feature23_count	<=	'b0;
		    feature31_count	<=	'b0;
		    feature32_count	<=	'b0;
	        feature33_count	<=	'b0;
		end
	else if(vaule_output)
		begin
			feature11_count	<=	feature11_count_reg	;
		    feature12_count	<=	feature12_count_reg	;
		    feature13_count	<=	feature13_count_reg	;
		    feature21_count	<=	feature21_count_reg	;
		    feature22_count	<=	feature22_count_reg	;
		    feature23_count	<=	feature23_count_reg	;
		    feature31_count	<=	feature31_count_reg	;
		    feature32_count	<=	feature32_count_reg	;
	        feature33_count	<=	feature33_count_reg	;
		end
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		chepai_Digital	<=	'b0;
	else if( feature_sum == 8 && feature_code[4]==0 )
		chepai_Digital	<=	4'h0;
	else if( feature_sum == 8 && feature_code[0]==0 )
		chepai_Digital	<=	4'h4;
	else if( feature_sum == 7 && ( feature_code[8]==0 || feature_code[6]==0))
		chepai_Digital	<=	4'h9;
	else if( feature_sum == 7 && ( feature_code[0]==0 ||feature_code[2]==0   ) )
		chepai_Digital	<=	4'h6;
	else if( feature_sum >= 5 && ( feature_code[3]==0 ||feature_code[6]==0 ||feature_code[8]==0  ) )
		chepai_Digital	<=	4'h7;
	else if( feature_sum <= 4 && ( feature_code[0]==0 ||feature_code[2]==0 ||feature_code[3]==0 ||feature_code[5]==0 ||feature_code[6]==0 ||feature_code[8]==0  ) )
		chepai_Digital	<=	4'h1;
//**************************************		
	else
		chepai_Digital	<=	4'h8;
end


endmodule