/*
Module name:  digital_recognition.v
Description:  digital recognition
              
Data:         2018/04/17
Engineer:     lipu
e-mail:       137194782@qq.com 
微信公众号：    FPGA开源工作室
*/
`timescale 1ns/1ps

module digital_recognition(
	input               	TFT_VCLK,
	input               	TFT_VS,
	input               	rst_n,
	input               	th_flag,  	//threshold value
	input	[11:0]			hcount,		//x_cnt
	input	[11:0]			vcount,		//y_cnt

//	input	[11:0]    		hcount_l,	//左边界
//	input	[11:0]    		hcount_r,	//右边界
//	input	[11:0]    		vcount_l,	//上边界
//	input	[11:0]    		vcount_r,	//下边界
	
	input               	th_flag_rise,
	input              	 	th_flag_fall,
	input               	TFT_VS_rise,
	input               	TFT_VS_fall,
	input		[2:0]     	frame_cnt,
	
	output	reg [11:0] 		h_2,
	output	reg [11:0] 		v_5,
	output	reg [11:0] 		v_3,
	output		[15:0]		send_str,
	output	reg	[3:0]		reco_digital
);

parameter 	P_1_3 		= 	6'b010101;	//1/3 0.333

//	parameter 	P_2_3 		= 	6'b101011;	//2/3 0.667
parameter 	P_2_3 		= 	6'b101110;	//2/3 0.667

//	parameter	P_2_5 		= 	6'b010101;	//2/5 0.4
parameter	P_2_5 		= 	6'b011001;	//2/5 0.4
parameter 	P_3_5 		= 	6'b100010;	//3/5 0.6

parameter	hcount_l	=	12'd180	;
parameter	hcount_r	=	12'd225	;
parameter	vcount_l	=	12'd80	;
parameter	vcount_r	=	12'd160	;

wire	[11:0]	y_spacing;
assign			y_spacing	=	vcount_r	-	vcount_l	+	1'b1;


reg			x1_l;		//x1左
reg			x1_r; 		//x1右
reg			x2_l; 
reg			x2_r;
reg [3:0]	y;
reg [3:0]	x1;
reg [3:0]	x2;
reg	[30:0]	Refresh_time;

assign		send_str	=	{x1_l,x1_r,x2_l,x2_r,y,x1,x2};
		 
wire		y_flag;
reg			y_flag_r0;
reg			y_flag_r1;

reg			wr_y_en;
reg			rd_y_en;
reg	[11:0] 	y_cnt;

wire		y_flag_fall;

reg 		TFT_VS_rise_r0;
reg 		TFT_VS_rise_r1;
reg 		TFT_VS_rise_r2;

reg     [17:0]    hcount_l_r;
reg     [17:0]    hcount_r_r;
reg     [17:0]    vcount_l_r;
reg     [17:0]    vcount_r_r;

//	reg [11:0] h_2; 		//(hcount_l + hcount_r)/2
//	reg [11:0] v_5; 		// (vcount_r - vcount_l)*2/5 + vcount_l
//	reg [11:0] v_3; 		// (vcount_r - vcount_l)*2/3 + vcount_l

reg [17:0] h_2_r; 		//(hcount_l + hcount_r)/2
reg [23:0] v_5_r; 		// (vcount_r - vcount_l)*2/5 + vcount_l
reg [23:0] v_3_r; 		// (vcount_r - vcount_l)*2/3 + vcount_l

//pipiline
always @(posedge TFT_VCLK ) begin
  TFT_VS_rise_r0 <= TFT_VS_rise;
  TFT_VS_rise_r1 <= TFT_VS_rise_r0;
  TFT_VS_rise_r2 <= TFT_VS_rise_r1;
end
//-------------------------------------------------
// 1/2 x            2/5 y             2/3 y
//-------------------------------------------------
always @(posedge TFT_VCLK or negedge rst_n) 
begin  
	if(!rst_n) 
		begin
			h_2 <= 12'd0;
			v_5 <= 12'd0;
			v_3 <= 12'd0;
			h_2_r <= 18'd0;
			v_5_r <= 23'd0;
			v_3_r <= 23'd0;
			hcount_l_r <= 18'b0;
			hcount_r_r <= 18'b0;
			vcount_l_r <= 18'b0;
			vcount_r_r <= 18'b0;
		end
	else if(frame_cnt == 3'd0) 
		begin
			if(TFT_VS_rise) 
				begin
					hcount_l_r <= {hcount_l,6'b0};//位扩展
					hcount_r_r <= {hcount_r,6'b0};
					vcount_l_r <= {vcount_l,6'b0};
					vcount_r_r <= {vcount_r,6'b0};
				end
			else if(TFT_VS_rise_r0) 
				begin
					h_2_r <=  (hcount_r_r + hcount_l_r)>>1;       		// y 线
					v_5_r <=  vcount_r_r*P_2_5 + vcount_l_r*P_3_5;		//x1 线
					v_3_r <=  vcount_r_r*P_2_3 + vcount_l_r*P_1_3;		//x2 线
				end
			else if(TFT_VS_rise_r1) 
				begin
					h_2 <= h_2_r[17:6]; 	//bit位还原
					v_5 <= v_5_r[23:12];	
					v_3 <= v_3_r[23:12];
				end
		end
	else 
    ;
end

//----------------------------------------------------
// x1 
//----------------------------------------------------
always @(posedge TFT_VCLK or negedge rst_n) begin
	if(!rst_n)
		x1 <= 4'd0;
	else if(frame_cnt == 3'd0) begin
		if(TFT_VS_rise)			//TFT_VS rising edge 
			x1 <= 4'd0;
	else if( (vcount == v_5) && ( hcount>=hcount_l ) && ( hcount<=hcount_r )) 
		if(th_flag_fall)
			x1 <= x1 + 4'd1;
	 else
	   x1 <= x1;
  end
  else
     x1 <= x1;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    x1_l <= 1'b0;
  else if(frame_cnt == 3'd0) begin
   if(TFT_VS_rise)//TFT_VS rising edge 
    x1_l <= 1'b0;
   else if((vcount == v_5) && (hcount < h_2)  && ( hcount>=hcount_l ) ) //left
    if(th_flag)
	   x1_l <= 1'b1;
	 else
	   x1_l <= x1_l;
  end
  else
    x1_l <= x1_l;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    x1_r <= 1'b0;
  else if(frame_cnt == 3'd0) begin
   if(TFT_VS_rise)//TFT_VS rising edge 
     x1_r <= 1'b0;
   else if((vcount == v_5) && (hcount > h_2)  && ( hcount<=hcount_r ) ) 
     if(th_flag)
	    x1_r <= 1'b1;
	  else
	    x1_r <= x1_r;
  end
  else
    x1_r <= x1_r;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    x2 <= 4'd0;
  else if(frame_cnt == 3'd0) begin
    if(TFT_VS_rise) //TFT_VS rising edge 
      x2 <= 4'd0;
    else if( ( vcount == v_3 ) && ( hcount>=hcount_l ) && ( hcount<=hcount_r )) 
      if(th_flag_fall)
	     x2 <= x2 + 4'd1;
	   else
	     x2 <= x2;
  end
  else
    x2 <= x2;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    x2_l <= 1'b0;
  else if(frame_cnt == 3'd0) begin
    if(TFT_VS_rise)//TFT_VS rising edge 
      x2_l <= 1'b0;
    else if((vcount == v_3) && (hcount < h_2) && ( hcount>=hcount_l )  )
      if(th_flag)
	     x2_l <= 1'b1;
	   else
	     x2_l <= x2_l;
  end
  else
    x2_l <= x2_l;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    x2_r <= 1'b0;
  else if(frame_cnt == 3'd0) begin
    if(TFT_VS_rise)//TFT_VS rising edge 
     x2_r <= 1'b0;
    else if((vcount == v_3) && (hcount > h_2) && ( hcount<=hcount_r ))
      if(th_flag)
	     x2_r <= 1'b1;
	   else
	     x2_r <= x2_r;
  end
  else
    x2_r <= x2_r;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n) 
    y_cnt <= 12'd0;
  else if(frame_cnt == 3'd0) begin
    if(TFT_VS_rise)//TFT_VS rising edge 
      y_cnt <= y_spacing;
    else if(TFT_VS)
      y_cnt <=  y_cnt - 12'd1;
    else if(y_cnt == 12'd0)
      y_cnt <=  y_cnt;
  end
  else
    ;
end


always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n) 
    rd_y_en <= 1'b0;
  else if(frame_cnt == 3'd1) begin
    if(TFT_VS && (y_cnt > 0))
      rd_y_en <= 1'b1;
    else
      rd_y_en <= 1'b0;
  end
  else
    ;
end

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n) 
    wr_y_en <= 1'b0;
  else if(frame_cnt == 3'd0) begin 
    if(hcount == h_2 &&( vcount >= vcount_l )&&( vcount <= vcount_r ) )
      wr_y_en <= 1'b1;
    else
      wr_y_en <= 1'b0;
  end
  else
    ;
end

always @(posedge TFT_VCLK ) begin
  y_flag_r0 <= y_flag;
  y_flag_r1 <= y_flag_r0;
end

assign y_flag_fall = (!y_flag_r0 && y_flag_r1) ? 1'b1:1'b0;

always @(posedge TFT_VCLK or negedge rst_n) begin
  if(!rst_n)
    y <= 4'd0;
  else if(frame_cnt == 3'd1) begin
    if(TFT_VS_rise)//TFT_VS rising edge 
      y <= 4'd0;
    else  if(y_flag_fall)
	   y <= y + 4'd1;
    else
	   y <= y;
  end
  else
   ;
end

fifo_y fifo_y_inst(
	   .clock(TFT_VCLK),
	   .data(th_flag),
	   .rdreq(rd_y_en),
	   .wrreq(wr_y_en),
	   .empty(),
	   .full(),
	   .q(y_flag),
	   .usedw());
	   
always @(posedge TFT_VCLK or negedge rst_n)
begin
	if(!rst_n)
		Refresh_time	<=	'b0;
	else if( Refresh_time == 9_000_000 )		//TFT_VCLK,9Mhz,9_000_000 is 1s
		Refresh_time	<=	'b0;
	else 
		Refresh_time	<=	Refresh_time	+	1'b1;
end
		
	   
always @(posedge TFT_VCLK or negedge rst_n)
begin
	if(!rst_n)
    reco_digital <= 4'h0;
  else if((frame_cnt == 3'd1) && TFT_VS_rise && ( Refresh_time > 5_000_000 ))
    case({x1_l,x1_r,x2_l,x2_r,y,x1,x2})             //特征统计数据对应列表
	   16'b1111_0010_0010_0010: reco_digital <= 4'h0; //0
		16'b1010_0001_0001_0001: reco_digital <= 4'h1; //1
		16'b0110_0011_0001_0001: reco_digital <= 4'h2; //2
		16'b0101_0011_0001_0001: reco_digital <= 4'h3; //3
		16'b1101_0010_0010_0001: reco_digital <= 4'h4; //4
		16'b1001_0011_0001_0001: reco_digital <= 4'h5; //5
		16'b1011_0011_0001_0010: reco_digital <= 4'h6; //6
		16'b????_0010_0001_0001: reco_digital <= 4'h7; //7
		16'b1111_0011_0010_0010: reco_digital <= 4'h8; //8
		16'b1101_0011_0010_0001: reco_digital <= 4'h9; //9
		default: reco_digital <= 32'b0;
	 endcase
  else
	 reco_digital <= reco_digital; 
end   

	   

endmodule 