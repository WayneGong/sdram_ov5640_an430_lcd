module Digital_feature_scan
(
	input                   rst_n,   
	input                   clk,
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de, 

	input		[11:0]		i_x,        // video position X
	input		[11:0]		i_y,         // video position y	
	input		[15:0]		i_data,
	input					i_th,
	
	output	reg	[23:0]		feature_count1,
	
	output		[23:0]		o_data,
	output		[11:0]		o_x,        // video position X
	output		[11:0]		o_y,         // video position y	
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de

);

parameter	post_up		=	80;
parameter	post_dowm	=	190;
parameter	post_left	=	70;
parameter	post_right	=	430;


wire	[11:0] 	x_cnt	=	i_x;
wire	[11:0]	y_cnt	=	i_y;

reg	[23:0]	feature_count_reg;

wire	vaule_output	=	(	x_cnt	==	450	&&	y_cnt	==	250	);

wire	featuer_region1	=	(		(	( x_cnt >= post_left )	&&	( x_cnt <= post_left+70	)	)
								&&	(	( y_cnt >= post_up )	&&	( y_cnt <= post_dowm 	)	)	
							);


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature_count_reg	<=	'b0;
	else if( i_vs == 1'b0 )
		feature_count_reg	<=	'b0;
	else if( featuer_region1 && i_th )  
		feature_count_reg	<=	feature_count_reg + 1'b1;
	else
		feature_count_reg	<=	feature_count_reg;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		feature_count1	<=	'b0;
	else if( vaule_output )
		feature_count1	<=	feature_count_reg;
	else 
		feature_count1	<=	feature_count1;
end




endmodule