module  test_char_send
(
	input			clk,
	input			rst_n,
	input	[15:0]	send_str,
	input	[3:0]	reco_digital,	
	output			RsTx
);

reg		[30:0]	time_cnt;
reg		[ 7:0]	tx_data_in;
reg				tx_en;

always@(posedge clk,negedge	rst_n)
begin
	if(!rst_n)
		time_cnt	<=	'b0;
	else if( time_cnt ==	150_000_000 )
		time_cnt	<=	'b0;
	else
		time_cnt	<=	time_cnt	+	1'b1;
end


//	send_str	=	{x1_l,x1_r,x2_l,x2_r,y,x1,x2};
//	send_str	total is 16bit
//	x1_l,		1bit,send_str[15]		
//	x1_r,		1bit,send_str[14]	
//	x2_l,		1bit,send_str[13]	
//	x2_r,		1bit,send_str[12]	
//	y,			4bit,send_str[11:8]
//	x1,			4bit,send_str[7:4]	
//	x2			4bit,send_str[3:0]	
	

always@(*)
begin
	if( time_cnt <=	10)
		begin case( time_cnt )
			0		:	tx_data_in	=	8'h22;
			1		:	tx_data_in	=	{7'b0,send_str[15]	}	;	
			2		:	tx_data_in	=	{7'b0,send_str[14]	}	;
			3		:	tx_data_in	=	{7'b0,send_str[13]	}	;
			4		:	tx_data_in	=	{7'b0,send_str[12]	}	;
			5		:	tx_data_in	=	{4'b0,send_str[11:8]}	;	
			6		:	tx_data_in	=	{4'b0,send_str[7:4]	}	;
			7		:	tx_data_in	=	{4'b0,send_str[3:0]	}	;	
			8		:	tx_data_in	=	8'hff;
			9		:	tx_data_in	=	{4'b0,reco_digital	}	;	
			10		:	tx_data_in	=	8'h55;
			default	:	tx_data_in	=	8'h00;
		endcase end
	else 
		tx_data_in	=	8'h00;		
end

always@(*)
begin
	if( time_cnt <=	10 )
		tx_en	=	1'b1;
	else
		tx_en	=	1'b0;
end	
	
UART_TOP UART_TOP_m0
(

	.clk				(	clk					),
	.rst_n				(	rst_n				),

	.RsRx				(						),				//Input from RS-232
	.RsTx				(	RsTx				),				//Output to RS-232

	.tx_data_in			(	tx_data_in			),
	.rx_data_out		(						),

	.tx_en				(	tx_en				),
	.rx_en				(						),

	.uart_irq			(						)  //Interrupt
);

endmodule	