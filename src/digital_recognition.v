module Digital_Recognition
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
	
	output                  o_hs,    
	output                  o_vs,    
	output                  o_de,    
	output		[23:0]		o_data

);
 
reg				th_reg_d0;
reg		[11:0]	white_count1,black_count1;
reg		[11:0]	white_count2,black_count2;

wire	[11:0] 	x_cnt	=	x;
wire	[11:0]	y_cnt	=	y;


wire	[11:0]	char_width	=	char_right	-	char_left	;
wire	[11:0]	char_height	=	char_down	-	char_up	;

wire	row1_scanf_en	=	( ( y_cnt== row_scanf_line1 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );
wire	row2_scanf_en	=	( ( y_cnt== row_scanf_line2 ) && ( x_cnt > char_left ) && ( x_cnt <= char_right ) );

reg		[50:0]	row1_char_code;
reg		[50:0]	row2_char_code;

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		th_reg_d0	<=	1'b0;
	else
		th_reg_d0	<=	i_th;
end


endmodule