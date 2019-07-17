module led_shaning
(
	input		clk,
	input		rst_n,
	
	output	reg	led

);

reg		[30:0]	time_cnt;

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		time_cnt	<=	'b0;
	else if( time_cnt == 10_000_000 )
		time_cnt	<=	'b0;
	else
		time_cnt	<=	time_cnt	+	1'b1;
end

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		led	<=	1'b1;
	else if( time_cnt == 10_000_000 )
		led	<=	~led;
end

endmodule
