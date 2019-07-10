module Picture_Char_Location
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
	
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output	reg	[11:0]		edge_left,	
	output	reg	[11:0]		edge_right,
	output	reg	[11:0]		edge_up,
	output	reg	[11:0]		edge_dowm,
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de

);

parameter	post_up		=	70;
parameter	post_dowm	=	200;
parameter	post_left	=	50;
parameter	post_right	=	430;	//扫描线的范围

parameter	y_scanf		=	130;	//边框定位的扫描线
parameter	x_scanf		=	170;

wire	[11:0] 	x_cnt	=	i_x;	//图像坐标
wire	[11:0]	y_cnt	=	i_y;

wire	y_scanf_en		=	( ( y_cnt == y_scanf )	&&	( x_cnt > post_left )	&& ( x_cnt <=  post_right) );
wire	x_scanf_en		=	( ( x_cnt == x_scanf )	&&	( y_cnt > post_up ) 	&& ( y_cnt <=  post_dowm ) );
wire	vaule_output	=	( (	x_cnt	==	450	 ) 	&&	( y_cnt	==	250	) );

reg		[post_right-post_left-1:0]	y_scanf_code,y_scanf_code_reg,y_scanf_code_temp,y_scanf_code_temp2;
reg		[post_dowm-post_up-1:0]		x_scanf_code,x_scanf_code_reg,x_scanf_code_temp,x_scanf_code_temp2;

reg		[11:0]	edge_left_reg;
reg		[11:0]	edge_right_reg;
reg		[11:0]	edge_up_reg;
reg		[11:0]	edge_dowm_reg;


always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		y_scanf_code_reg	<=	'b0;
	else if( y_scanf_en )
		y_scanf_code_reg	<=	{i_th,y_scanf_code_reg[post_right-post_left-1:1]};
	else
		y_scanf_code_reg	<=	y_scanf_code_reg;
end
	
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		x_scanf_code_reg	<=	'b0;
	else if( x_scanf_en )
		x_scanf_code_reg	<=	{i_th,x_scanf_code_reg[post_dowm-post_up-1:1]};
	else
		x_scanf_code_reg	<=	x_scanf_code_reg;
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		edge_left_reg	<=	post_left;
	else if( i_vs == 0 )
		begin
			edge_left_reg		<=	post_left;
			y_scanf_code_temp	<=	y_scanf_code;
		end
		
	else if(y_scanf_code_temp[0] == 1 )
		begin
			edge_left_reg	<=	edge_left_reg	+	1'b1;
			y_scanf_code_temp	<=	{1'b0,y_scanf_code_temp[post_right-post_left-1:1]};
		end
	else
		edge_left_reg	<=	edge_left_reg;	
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		edge_up_reg		<=	post_up;
	else if( i_vs == 0 )
		begin
			edge_up_reg			<=	post_up;
			x_scanf_code_temp	<=	x_scanf_code;
		end
		
	else if(x_scanf_code_temp[0] == 1 )
		begin
			edge_up_reg			<=	edge_up_reg	+	1'b1;
			x_scanf_code_temp	<=	{1'b0,x_scanf_code_temp[post_dowm-post_up-1:1]};
		end
	else
		edge_up_reg	<=	edge_up_reg;	
end



always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		edge_dowm_reg	<=	post_dowm;
	else if( i_vs == 0 )
		begin
			edge_dowm_reg			<=	post_dowm;
			x_scanf_code_temp2		<=	x_scanf_code;
		end
		
	else if(x_scanf_code_temp2[post_dowm-post_up-1] == 1 )
		begin
			edge_dowm_reg		<=	edge_dowm_reg	-	1'b1;
			x_scanf_code_temp2	<=	{x_scanf_code_temp2[post_dowm-post_up-2:0],1'b0};
		end
	else
		edge_dowm_reg	<=	edge_dowm_reg;	
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		edge_right_reg	<=	post_right;
	else if( i_vs == 0 )
		begin
			edge_right_reg		<=	post_right;
			y_scanf_code_temp2	<=	y_scanf_code;
		end
		
	else if(y_scanf_code_temp2[post_right-post_left-1] == 1 )
		begin
			edge_right_reg		<=	edge_right_reg	-	1'b1;
			y_scanf_code_temp2	<=	{y_scanf_code_temp2[post_right-post_left-2:0],1'b1};
		end
	else
		edge_right_reg	<=	edge_right_reg;	
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			y_scanf_code	<=	'b0	;
			x_scanf_code	<=	'b0	;
			edge_left		<=	'b0	;
			edge_up			<=	'b0	;	
			edge_dowm		<=	'b0	;
			edge_right		<=	'b0	;
		end
	else if(vaule_output)
		begin
			y_scanf_code	<=	y_scanf_code_reg;
			x_scanf_code	<=	x_scanf_code_reg;
			edge_left		<=	edge_left_reg;
			edge_up			<=	edge_up_reg;
			edge_dowm		<=	edge_dowm_reg;
			edge_right		<=	edge_right_reg;
		end
end

endmodule	