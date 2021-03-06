module Char_Division
(
	input                   rst_n,   
	input                   clk,

	input		[11:0]		i_x,        // video position X
	input		[11:0]		i_y,         // video position y
	
	input		[11:0]		edge_left,
	input		[11:0]		edge_up,
	input		[11:0]		edge_down	,
	input		[11:0]		edge_right	,
	
	output	reg	[11:0]		char_up_position,	
	output	reg	[11:0]		char_down_position,

	output	reg	[11:0]		row_scanf_line1,
	output	reg	[11:0]		row_scanf_line2,	
	
	output	reg	[11:0]		Partition_line1,
	output	reg	[11:0]		Partition_line2,
	output	reg	[11:0]		Partition_line3,
	output	reg	[11:0]		Partition_line4,
	output	reg	[11:0]		Partition_line5,
	output	reg	[11:0]		Partition_line6

);

wire	[11:0]	image_width		=	edge_right	-	edge_left;
wire	[11:0]	image_height	=	edge_down	-	edge_up;
wire	[11:0]	char_height	=	char_down_position	-	char_up_position	;

wire	[11:0] 	x_cnt	=	i_x;
wire	[11:0]	y_cnt	=	i_y;

wire	vaule_output	=	(	x_cnt	==	450	&&	y_cnt	==	250	);

reg	[11:0]		Partition_line1_reg;
reg	[11:0]		Partition_line2_reg;
reg	[11:0]		Partition_line3_reg;
reg	[11:0]		Partition_line4_reg;
reg	[11:0]		Partition_line5_reg;
reg	[11:0]		Partition_line6_reg;
reg	[11:0]		char_up_position_reg;	
reg	[11:0]		char_down_position_reg;
reg	[11:0]		row_scanf_line1_reg;
reg	[11:0]		row_scanf_line2_reg;




always@(posedge clk,negedge rst_n)
begin
	if( !rst_n )
		begin
			Partition_line1_reg		<=	'b0;
			Partition_line2_reg		<=	'b0;
			Partition_line3_reg		<=	'b0;
			Partition_line4_reg		<=	'b0;
			Partition_line5_reg		<=	'b0;
		    Partition_line6_reg		<=	'b0;
			char_up_position_reg	<=	'b0;	
			char_down_position_reg	<=	'b0;
			row_scanf_line1_reg		<=	'b0;
            row_scanf_line2_reg		<=	'b0;
			
		end
	else 
		begin
			Partition_line1_reg		<=	edge_left	+	21*image_width/64	+	0*9*image_width/64	;
			Partition_line2_reg		<=	edge_left	+	21*image_width/64	+	1*9*image_width/64	;
			Partition_line3_reg		<=	edge_left	+	21*image_width/64	+	2*9*image_width/64	-0;
			Partition_line4_reg		<=	edge_left	+	21*image_width/64	+	3*9*image_width/64	-2;
			Partition_line5_reg		<=	edge_left	+	21*image_width/64	+	4*9*image_width/64	-4;
		    Partition_line6_reg		<=	edge_left	+	21*image_width/64	+	5*9*image_width/64	-11;
			
			char_up_position_reg	<=	edge_up		+	3*image_height/32;
			char_down_position_reg	<=	edge_down	-	3*image_height/32;
			row_scanf_line1_reg		<=	char_up_position	+	5*char_height/16	;
            row_scanf_line2_reg		<=	char_up_position	+	12*char_height/16	;
			
			
		end
end


always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		begin
			Partition_line1		<=	'b0;
			Partition_line2		<=	'b0;
			Partition_line3		<=	'b0;
			Partition_line4		<=	'b0;
			Partition_line5		<=	'b0;
		    Partition_line6		<=	'b0;
			char_up_position	<=	'b0;
			char_down_position	<=	'b0;
			row_scanf_line1		<=	'b0;
			row_scanf_line2		<=	'b0;			
		end
	else if(vaule_output)
		begin
			Partition_line1		<=	Partition_line1_reg;
			Partition_line2		<=	Partition_line2_reg;
			Partition_line3		<=	Partition_line3_reg;
			Partition_line4		<=	Partition_line4_reg;
			Partition_line5		<=	Partition_line5_reg;
		    Partition_line6		<=	Partition_line6_reg;
			char_up_position	<=	char_up_position_reg;
			char_down_position	<=	char_down_position_reg;
			row_scanf_line1		<=	row_scanf_line1_reg;
			row_scanf_line2		<=	row_scanf_line2_reg;			
			
		end
end

endmodule	
