module Char_Pic_Disply
( 	
	input                   rst_n,   
	input                   clk,
	input		[11:0]		x,        // video position X
	input		[11:0]		y,         // video position y
		
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de,    
	input		[23:0]		i_data,
	input		[3:0]		reco_digital,
	input		[2:0]		key, 

	input		[11:0] 		h_2,
	input		[11:0] 		v_5,
	input		[11:0] 		v_3,
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,    
	output		[23:0]		o_data

);


parameter	LSB			=	2;

parameter	car_digital	=	20'h01234;

parameter	post_up		=	80;
parameter	post_dowm	=	190;
parameter	post_left	=	70;
parameter	post_right	=	430;

reg 			de_d0;
reg 			de_d1;
reg 			vs_d0;
reg 			vs_d1;
reg 			hs_d0;
reg 			hs_d1;
reg		[23:0]	vout_data;	

wire	[11:0] 	x_cnt	=	x;
wire	[11:0]	y_cnt	=	y;

assign o_de 	= 	de_d0;
assign o_vs 	= 	vs_d0;
assign o_hs 	= 	hs_d0;
assign o_data 	= 	vout_data;

always@(posedge clk)
begin
	de_d0 		<= 	i_de	;
	vs_d0 		<= 	i_vs	;	
	hs_d0 		<= 	i_hs	;
end

wire	[3:0]	char1	=	reco_digital	;
wire	[3:0]	char2	=	car_digital[15:12]	;
wire	[3:0]	char3	=	car_digital[11:8]	;
wire	[3:0]	char4	=	car_digital[7:4]	;
wire	[3:0]	char5	=	car_digital[3:0]	;


wire	edge_line		=	( ( x_cnt	==	1  ) || ( x_cnt	==	480 ) || ( y_cnt == 0  ) || ( y_cnt == 271 ) );
wire	char_region		=	( ( x_cnt	==	post_left ) || ( x_cnt	==	post_right ) || ( y_cnt == post_up ) || ( y_cnt == post_dowm ) );

wire	char_Division	=	( 	( x_cnt	==	post_left + 70 )	|| 					//字符分割线	
								( x_cnt	==	post_left + 70*2+5 )	|| 
								( x_cnt	==	post_left + 70*3+10 )	|| 
								( x_cnt	==	post_left + 70*4+10 )	 );
								
wire	column_feature	=	( 	( x_cnt	==	post_left + 23 )	|| 					//列特征线	
								( x_cnt	==	post_left + 23*2 )	|| 
								( x_cnt	==	post_left + 70*2 -35 )	|| 
								( x_cnt	==	post_left + 70*3+10 -40 )	|| 
								( x_cnt	==	post_left + 70*4+10 -35 )	||
								( x_cnt	==	post_left + 70*4+10 +35 )	);
wire	row_feature		=	( 	( y_cnt	==	80+35 )	||	( y_cnt	==	80+35*2 ) );		//行特征线	
								
wire	featuer_point	=	(	(( x_cnt[11:1] == 40 ) ||( x_cnt[11:1] == 50 )			)
								&& (( y_cnt[11:1] == 45 )||( y_cnt[11:1] == 50 )		)	
							);

wire	featuer_region1	=	(		(	( x_cnt >= post_left )	&&	( x_cnt <= post_left+70	)	)
								&&	(	( y_cnt >= post_up )	&&	( y_cnt <= post_dowm 	)	)	
							);
							
wire	disp_region1	=	( y[11:4+LSB] == 0 )&& ( x[11:3+LSB] == 0 );
wire	disp_region2	=	( y[11:4+LSB] == 0 )&& ( x[11:3+LSB] == 1 );
wire	disp_region3	=	( y[11:4+LSB] == 0 )&& ( x[11:3+LSB] == 2 );
wire	disp_region4	=	( y[11:4+LSB] == 0 )&& ( x[11:3+LSB] == 3 );
wire	disp_region5	=	( y[11:4+LSB] == 0 )&& ( x[11:3+LSB] == 4 );
	
wire		[127:0]		char_array1;
wire		[127:0]		char_array2;
wire		[127:0]		char_array3;
wire		[127:0]		char_array4;
wire		[127:0]		char_array5;

char_array_decode  char_array_decode_m1(	.char(	char1	),	.char_array(	char_array1	)	);	
char_array_decode  char_array_decode_m2(	.char(	char2	),	.char_array(	char_array2	)	);	
char_array_decode  char_array_decode_m3(	.char(	char3	),	.char_array(	char_array3	)	);	
char_array_decode  char_array_decode_m4(	.char(	char4	),	.char_array(	char_array4	)	);	
char_array_decode  char_array_decode_m5(	.char(	char5	),	.char_array(	char_array5	)	);	
	


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		vout_data	<=	24'b0;		
	else if( edge_line )		//显示屏边框线
		vout_data	<=	24'hff0000;			//红色	
	
	else if( char_region )		//字符区域
		vout_data	<=	24'h0000ff;			//蓝色

	else if(char_Division )		//字符分割线
		vout_data	<=	24'hff00ff;			//紫色

	
//	else if( column_feature )	//行特征线				
//		vout_data	<=	24'h00ffff;			//青绿色
//		
//	else if( row_feature )		//列特征线
//		vout_data	<=	24'hffff00;			//黄色	
//	else if( featuer_point )	//特征点
//		vout_data	<=	24'hff0000;			//红色
	
	else if( disp_region1 )
		vout_data	<=	{24{char_array1[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region2 )
		vout_data	<=	{24{char_array2[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region3 )
		vout_data	<=	{24{char_array3[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region4 )
		vout_data	<=	{24{char_array4[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else if( disp_region5 )
		vout_data	<=	{24{char_array5[127-(8*y_cnt[3+LSB:0+LSB]+x_cnt[2+LSB:0+LSB])]}};
	else
		vout_data	<=	i_data;
end


endmodule 