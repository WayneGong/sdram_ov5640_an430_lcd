module  Edge_Detect_cnt
(
	input					clk,
	input					rst_n,
	
	input                   i_hs,    
	input                   i_vs,    
	input                   i_de,    
	input			[23:0]	i_data,
	input					th_flag,
	
	output 	reg 	[2:0] 	frame_cnt,
	output	wire			vs_fall,
	output	wire			vs_rise,
	output	wire			hs_fall,
	output	wire			hs_rise,
	output	wire			th_fall,
	output	wire			th_rise
);

reg			th_d0;
reg			th_d1;
reg			vs_d0;
reg			vs_d1;
reg			hs_d0;
reg			hs_d1;

assign		vs_fall	=	( !vs_d0 ) && vs_d1;
assign		vs_rise	=	vs_d0 && ( !vs_d1 );

assign		hs_fall	=	( !hs_d0 ) && hs_d1;
assign		hs_rise	=	hs_d0 && ( !hs_d1 );
	
assign		th_fall	=	( !th_d0 ) && th_d1;
assign		th_rise	=	th_d0 && ( !th_d1 );

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) 
    frame_cnt <=3'd0;
  else if(frame_cnt == 3'd4)
    frame_cnt <=3'd0;
  else if(vs_fall== 1'b1) //falling edge
    frame_cnt <= frame_cnt + 3'd1;
  else
    frame_cnt <= frame_cnt;   
end 


always@(posedge clk)
begin
	th_d0	<=	th_flag		;
	th_d1	<=	th_d0		;
	vs_d0 	<= 	i_vs		;
	vs_d1 	<= 	vs_d0		;
	hs_d0 	<= 	i_hs		;
	hs_d1 	<= 	hs_d0		;
end


endmodule
