module Digital_feature_scan
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
	
	input		[11:0]		row_scanf_line1,
	input		[11:0]		row_scanf_line2,
	
	output		[8:0]		feature_code,
	output	reg	[3:0]		chepai_Digital,
	output		[11:0]		char_middle,
	
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,
	output		[7:0]		intersection_code

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

assign	intersection_code={2'b0,intersection_L1,intersection_L2,intersection_M1,intersection_M2,intersection_R1,intersection_R2};
reg		intersection_L1,intersection_L2;
reg		intersection_M1,intersection_M2;
reg		intersection_R1,intersection_R2;

reg		intersection_L1_reg,intersection_L2_reg;
reg		intersection_M1_reg,intersection_M2_reg;
reg		intersection_R1_reg,intersection_R2_reg;


wire	intersection_L1_en	=	((y_cnt == row_scanf_line1)&&( x_cnt>= char_left )&&( x_cnt<= char_left+18)	);
wire	intersection_L2_en	=	((y_cnt == row_scanf_line2)&&( x_cnt>= char_left )&&( x_cnt<= char_left+18)	);

wire	intersection_M1_en	=	((x_cnt == char_middle)&&( y_cnt>= char_up )&&( y_cnt<= row_scanf_line1)	);
wire	intersection_M2_en	=	((x_cnt == char_middle)&&( y_cnt>= row_scanf_line2 )&&( y_cnt<= char_down)	);

wire	intersection_R1_en	=	((y_cnt == row_scanf_line1)&&( x_cnt>= char_left+2*18 )&&( x_cnt<= char_right)	);
wire	intersection_R2_en	=	((y_cnt == row_scanf_line2)&&( x_cnt>= char_left+2*18 )&&( x_cnt<= char_right)	);


always@(posedge clk,negedge rst_n)
begin
	if( !rst_n )
		begin
			intersection_L1_reg	<=	'b0;
			intersection_L2_reg	<=	'b0;
			intersection_M1_reg	<=	'b0;
			intersection_M2_reg	<=	'b0;
			intersection_R1_reg	<=	'b0;
			intersection_R2_reg	<=	'b0;
		end
	else if( i_vs == 0 )
		begin
			intersection_L1_reg	<=	'b0;
			intersection_L2_reg	<=	'b0;
			intersection_M1_reg	<=	'b0;
			intersection_M2_reg	<=	'b0;
			intersection_R1_reg	<=	'b0;
			intersection_R2_reg	<=	'b0;
		end
	else if(intersection_L1_en && i_th)
		intersection_L1_reg	<=	1'b1;
	else if(intersection_L2_en && i_th)
		intersection_L2_reg	<=	1'b1;
	else if(intersection_R1_en && i_th)
		intersection_R1_reg	<=	1'b1;
	else if(intersection_R2_en && i_th)
		intersection_R2_reg	<=	1'b1;
	else if(intersection_M1_en && i_th)
		intersection_M1_reg	<=	1'b1;
	else if(intersection_M2_en && i_th)
		intersection_M2_reg	<=	1'b1;
end


assign	feature_code[0]	=	(	feature11_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[1]	=	(	feature12_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[2]	=	(	feature13_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[3]	=	(	feature21_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[4]	=	(	feature22_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[5]	=	(	feature23_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[6]	=	(	feature31_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[7]	=	(	feature32_count	>=	60	)	?	1'b1	:	1'b0	;
assign	feature_code[8]	=	(	feature33_count	>=	60	)	?	1'b1	:	1'b0	;

wire	[11:0]	char_width	=	char_right	-	char_left	;
wire	[11:0]	char_height	=	char_down	-	char_up		;
assign	char_middle	=	char_left	+	char_width[11:1];
wire	col_scanf_en	=	( ( x_cnt== char_middle	    ) && ( y_cnt > char_up   ) && ( y_cnt <= char_down  ) );

wire	row1_scanf_en	=	( ( y_cnt== row_scanf_line1 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );
wire	row2_scanf_en	=	( ( y_cnt== row_scanf_line2 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );

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
			intersection_L1	<=	'b0;
			intersection_L2	<=	'b0;
			intersection_M1	<=	'b0;
			intersection_M2	<=	'b0;
			intersection_R1	<=	'b0;
			intersection_R2	<=	'b0;
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

			intersection_L1	<=	intersection_L1_reg;
			intersection_L2	<=	intersection_L2_reg;
			intersection_M1	<=	intersection_M1_reg;
			intersection_M2	<=	intersection_M2_reg;
			intersection_R1	<=	intersection_R1_reg;
			intersection_R2	<=	intersection_R2_reg;
		end
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		chepai_Digital	<=	'b0;
	
	else if( feature_sum >= 8 && intersection_L1==1 && intersection_R1==1 && feature_code[4]==1)
		chepai_Digital	<=	4'h8;
	else if( feature_sum >= 8 && intersection_L1==1 && intersection_R1==0 && feature_code[4]==1)
		chepai_Digital	<=	4'h5;	
	else if( feature_sum >=7 && intersection_L1==0&& intersection_L2==1 && intersection_R1==1 && intersection_R2==0&& feature_code[4]==1)
		chepai_Digital	<=	4'h2;

	else if( feature_sum >= 8 && feature_code[0]==0 && intersection_L1==0  && intersection_L2==1 && intersection_R1==1 && intersection_R2==1)
		chepai_Digital	<=	4'h4;	
	
	else if( feature_sum >=7 && intersection_L1==0 && intersection_L2==1 && intersection_R1==1 && intersection_R2==1&& feature_code[4]==1)
		chepai_Digital	<=	4'h3;
		
	else if( feature_sum == 8 && feature_code[4]==0 )
		chepai_Digital	<=	4'h0;

	else if( feature_sum >= 7 && ( feature_code[8]==0 || feature_code[6]==0))
		chepai_Digital	<=	4'h9;
	else if( feature_sum == 7 && ( feature_code[0]==0 ||feature_code[2]==0   ) )
		chepai_Digital	<=	4'h6;
	else if( feature_sum <= 3 && ( (feature_code[0]==0 && feature_code[2]==0 && feature_code[3]==0) ||( feature_code[5]==0 ||feature_code[6]==0 ||feature_code[8]==0  ) ) )
		chepai_Digital	<=	4'h1;
	else if( feature_sum >= 5 && ( feature_code[3]==0 ||feature_code[6]==0 ||feature_code[8]==0  ) )
		chepai_Digital	<=	4'h7;

//**************************************		
	else
		chepai_Digital	<=	4'h8;
end


endmodule