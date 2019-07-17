module Digital_intersection_Recognition
(
	input                   rst_n,   
	input                   clk,
	input		[11:0]		x,        // video position X
	input		[11:0]		y,         // video position y
		
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de,    
	input					i_th,
	
	input		[11:0]		char_up,
	input		[11:0]		char_down,	
	input		[11:0]		char_left,
	input		[11:0]		char_right,
	
	input		[11:0]		row_scanf_line1,
	input		[11:0]		row_scanf_line2,	
	
	output	reg	[3:0]		cross_point1,cross_point2,cross_point3,
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,    
	output		[23:0]		o_data
);
 
parameter	TH	=	5; 

reg				th_reg_d0;
reg		[11:0]	white_width1,black_width1;
reg		[11:0]	white_width2,black_width2;
reg		[11:0]	white_width3,black_width3;


wire	[11:0] 	x_cnt	=	x;
wire	[11:0]	y_cnt	=	y;

wire	[11:0]	char_width	=	char_right	-	char_left	;
wire	[11:0]	char_height	=	char_down	-	char_up		;
wire	[11:0]	char_middle	=	char_left	+	char_width[11:2];

wire	row1_scanf_en	=	( ( y_cnt== row_scanf_line1 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );
wire	row2_scanf_en	=	( ( y_cnt== row_scanf_line2 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );
wire	col_scanf_en	=	( ( x_cnt== char_middle	    ) && ( y_cnt > char_up   ) && ( y_cnt <= char_down  ) );


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		th_reg_d0	<=	1'b0;
	else
		th_reg_d0	<=	i_th;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			cross_point1	<=	'b0;
			white_width1	<=	'b0;
			black_width1	<=	'b0;
		end
	else if( i_vs == 0 )
		begin
			cross_point1	<=	'b0;
			white_width1	<=	'b0;
			black_width1	<=	'b0;
		end
	else if( row1_scanf_en )
		begin
			if( i_th == 0 && th_reg_d0 == 1	)			//1--->0,
				begin
					if( white_width1 < TH )					//如果白色的像素点小于阈值，说明是白噪点，将该白色噪点补到黑色处
						begin
							black_width1	<=	black_width1	+	white_width1;	
							white_width1	<=	1'b0;
						end
					else	//如果白色像素点数量大于阈值，则表示为一段有效的黑色区域，将黑色像素置0，用于此段黑色区域的计数
						black_width1	<=	'b0;
				end	
			else if( i_th == 1 && th_reg_d0 == 0 )		//0--->1
				begin
					if( black_width1 < TH )	//如果黑色的像素点小于阈值，说明是黑噪点，将该黑色噪点补到白色处
						begin
							white_width1	<=	white_width1	+	black_width1;
							black_width1	<=	1'b0;
						end					
					else if( white_width1 >= TH && black_width1 >= TH )	//从黑变白，如果都大于阈值，说明是一个有效的交点，交点计数加一
						begin 
							cross_point1	<=	cross_point1	+	1'b1;
							white_width1	<=	'b0;
						end
				end
			else if(i_th == 0 && th_reg_d0 == 0)
				begin
					black_width1	<=	black_width1	+	1'b1;
					if( ( white_width1 >= TH ) && ( x_cnt == char_right ) )
						cross_point1	<=	cross_point1	+	1'b1;			
				end
			else if( i_th == 1 && th_reg_d0 == 1 )
				white_width1	<=	white_width1	+	1'b1;			
		end
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			cross_point2	<=	'b0;
			white_width2	<=	'b0;
			black_width2	<=	'b0;
		end
	else if( i_vs == 0 )
		begin
			cross_point2	<=	'b0;
			white_width2	<=	'b0;
			black_width2	<=	'b0;
		end
	else if( row2_scanf_en )
		begin
			if( i_th == 0 && th_reg_d0 == 1	)			//1--->0,
				begin
					if( white_width2 < TH )					//如果白色的像素点小于阈值，说明是白噪点，将该白色噪点补到黑色处
						begin
							black_width2	<=	black_width2	+	white_width2;	
							white_width2	<=	1'b0;
						end
					else	//如果白色像素点数量大于阈值，则表示为一段有效的黑色区域，将黑色像素置0，用于此段黑色区域的计数
						black_width2	<=	'b0;
				end	
			else if( i_th == 1 && th_reg_d0 == 0 )		//0--->1
				begin
					if( black_width2 < TH )	//如果黑色的像素点小于阈值，说明是黑噪点，将该黑色噪点补到白色处
						begin
							white_width2	<=	white_width2	+	black_width2;
							black_width2	<=	1'b0;
						end					
					else if( white_width2 >= TH && black_width2 >= TH )	//从黑变白，如果都大于阈值，说明是一个有效的交点，交点计数加一
						begin 
							cross_point2	<=	cross_point2	+	1'b1;
							white_width2	<=	'b0;
						end
				end
			else if(i_th == 0 && th_reg_d0 == 0)
				begin
					black_width2	<=	black_width2	+	1'b1;
					if( ( white_width2 >= TH ) && ( x_cnt == char_right ) )
						cross_point2	<=	cross_point2	+	1'b1;			
				end
			else if( i_th == 1 && th_reg_d0 == 1 )
				white_width2	<=	white_width1	+	1'b1;			
		end
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			cross_point3	<=	'b0;
			white_width3	<=	'b0;
			black_width3	<=	'b0;
		end
	else if( i_vs == 0 )
		begin
			cross_point3	<=	'b0;
			white_width3	<=	'b0;
			black_width3	<=	'b0;
		end
	else if( row2_scanf_en )
		begin
			if( i_th == 0 && th_reg_d0 == 1	)			//1--->0,
				begin
					if( white_width3 < TH )					//如果白色的像素点小于阈值，说明是白噪点，将该白色噪点补到黑色处
						begin
							black_width3	<=	black_width3	+	white_width3;	
							white_width3	<=	1'b0;
						end
					else	//如果白色像素点数量大于阈值，则表示为一段有效的黑色区域，将黑色像素置0，用于此段黑色区域的计数
						black_width3	<=	'b0;
				end	
			else if( i_th == 1 && th_reg_d0 == 0 )		//0--->1
				begin
					if( black_width3 < TH )	//如果黑色的像素点小于阈值，说明是黑噪点，将该黑色噪点补到白色处
						begin
							white_width3	<=	white_width3	+	black_width3;
							black_width3	<=	1'b0;
						end					
					else if( white_width3 >= TH && black_width3 >= TH )	//从黑变白，如果都大于阈值，说明是一个有效的交点，交点计数加一
						begin 
							cross_point3	<=	cross_point3	+	1'b1;
							white_width3	<=	'b0;
						end
				end
			else if(i_th == 0 && th_reg_d0 == 0)
				begin
					black_width3	<=	black_width3	+	1'b1;
					if( ( white_width3 >= TH ) && ( x_cnt == char_right ) )
						cross_point3	<=	cross_point3	+	1'b1;			
				end
			else if( i_th == 1 && th_reg_d0 == 1 )
				white_width3	<=	white_width1	+	1'b1;			
		end
end


endmodule