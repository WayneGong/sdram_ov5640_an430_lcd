//////////////////////////////////////////////////////////////////////////////////
//  ov5640 lcd display                                                          //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/19     meisq          1.0         Original
//*******************************************************************************/

module top(
	input                       clk,
	input                       rst_n,
	input	[3:1]				key,

	inout                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
	output                      cmos_xclk,         //cmos externl clock
	input   [7:0]               cmos_db,           //cmos data
	output                      lcd_dclk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[7:0]                 lcd_r,             //lcd red
	output[7:0]                 lcd_g,             //lcd green
	output[7:0]                 lcd_b,	           //lcd blue

	output						tx,					//	RS232-tx
	
	output                      sdram_clk,         //sdram clock
	output                      sdram_cke,         //sdram clock enable
	output                      sdram_cs_n,        //sdram chip select
	output                      sdram_we_n,        //sdram write enable
	output                      sdram_cas_n,       //sdram column address strobe
	output                      sdram_ras_n,       //sdram row address strobe
	output[1:0]                 sdram_dqm,         //sdram data enable
	output[1:0]                 sdram_ba,          //sdram bank address
	output[12:0]                sdram_addr,        //sdram address
	inout[15:0]                 sdram_dq           //sdram data
);
parameter MEM_DATA_BITS          = 16;             //external memory user interface data width
parameter ADDR_BITS              = 24;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire		[15:0]				read_data;
wire                            write_en;
wire		[15:0]				write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            ext_mem_clk;       //external memory clock
wire                            video_clk;         //video pixel clock

wire                            timing_hs;
wire                            timing_vs;
wire                            timing_de;
wire		[15:0]				timing_data;

wire                            xy_hs;
wire                            xy_vs;
wire                            xy_de;
wire		[15:0]				xy_data;


wire              				disp_hs;	
wire              				disp_vs;
wire							disp_de;	
wire		[23:0]				disp_data;

wire		[23:0]				GB_data;			//Gary_Binary_data
wire                            GB_hs;
wire                            GB_vs;
wire                            GB_de;
wire		[11:0] 				GB_x;
wire		[11:0] 				GB_y;



wire		[15:0]				cmos_16bit_data;
wire							cmos_16bit_wr;
wire		[1:0]				write_addr_index;
wire		[1:0]				read_addr_index;
wire		[9:0]				lut_index;
wire		[31:0]				lut_data;

wire		[11:0] 				gen_x;
wire		[11:0] 				gen_y;

wire		[2:0]				key_out;

wire							th_flag;
wire							vs_fall;
wire							vs_rise;
wire							hs_fall;
wire							hs_rise;
wire							th_fall;
wire							th_rise;

wire		[11:0] 				h_2;
wire		[11:0] 				v_5;
wire		[11:0] 				v_3;

wire		[15:0]				send_str;
wire		[3:0]				reco_digital;

wire		[2:0] 				frame_cnt;

assign	lcd_hs	=	disp_hs;
assign	lcd_vs	=	disp_vs;
assign	lcd_de	=	disp_de;
			
assign	lcd_r 	=	disp_data[23:16];	
assign	lcd_g 	=	disp_data[15: 8];	
assign	lcd_b 	=	disp_data[ 7: 0];
		
assign	lcd_dclk	=	~video_clk;

assign	sdram_clk	=	ext_mem_clk;
assign	write_en 	=	cmos_16bit_wr;
assign	write_data 	=	{cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (cmos_xclk                ),
	.c1                         (ext_mem_clk              )
	);
//generate video pixel clock
video_pll video_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (video_clk                )
	);
//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),
	.clk_div_cnt                (16'd500                  ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);
//configure look-up table
lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);
//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
	.de_o                       (cmos_16bit_wr            )
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_vsync               ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);
//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (	video_clk			),
	.rst                        (	~rst_n				),
	.read_req                   (	read_req			),
	.read_req_ack               (	read_req_ack		),
	.read_en                    (	read_en				),
	.read_data                  (	read_data			),
	.hs                         (	timing_hs			),
	.vs                         (	timing_vs			),
	.de                         (	timing_de			),
	.vout_data                  (	timing_data			)
);


timing_gen_xy timing_gen_xy_m0
(
	.rst_n					(	rst_n			),   
	.clk					(	video_clk		),
	
	.i_hs					(	timing_hs		),    
	.i_vs					(	timing_vs		),    
	.i_de					(	timing_de		),    
	.i_data					(	timing_data		), 
	
	.o_hs					(	xy_hs			),    
	.o_vs					(	xy_vs			),    
	.o_de					(	xy_de			),    
	.o_data					(	xy_data			),  
	
	.x						(	gen_x			),        // video position X
	.y						(	gen_y			)    	// video position y
);

key_Module  key_Module_m0
(
	.clk					(	video_clk			),
	.rst_n					(	rst_n				),
	.key_in					(	key					),
	.key_out				(	key_out				)
); 


RGB_Gary_Binary RGB_Gary_Binary_m0
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.key					(	key_out				),
	.i_hs					(	xy_hs				),
	.i_vs					(	xy_vs				),
	.i_de					(	xy_de				),
	.i_x					(	gen_x				),
	.i_y					(	gen_y				),	
	.i_data					(	xy_data				),
	
	.o_hs					(	GB_hs				),
    .o_vs					(	GB_vs				),
    .o_de					(	GB_de				),
	.o_x					(	GB_x				),
    .o_y					(	GB_y				),
	.o_data					(	GB_data				)

);







//Edge_Detect_cnt Edge_Detect_cnt_m0
//(
//	.clk					(	video_clk		),
//	.rst_n					(	rst_n			),
//
//	.i_hs					(	timing_hs		),    
//	.i_vs					(	timing_vs		),    
//	.i_de					(	timing_de		),     
//	.i_data					(	timing_data		),
//	.th_flag				(	th_flag			),
//	.frame_cnt				(	frame_cnt		),
//	.vs_fall				(	vs_fall			),
//	.vs_rise				(	vs_rise			),
//	.hs_fall				(	hs_fall			),
//	.hs_rise				(	hs_rise			),
//	.th_fall				(	th_fall			),
//	.th_rise				(	th_rise			)
//);


//digital_recognition digital_recognition_m0
//(
//	.TFT_VCLK			(	video_clk		),
//	.TFT_VS				(	timing_vs		),
//	.rst_n				(	rst_n			),
//	.th_flag			(	th_flag			),  	//threshold value
//	.hcount				(	gen_x			),		//x_cnt
//	.vcount				(	gen_y			),		//y_cnt
//	
//	.th_flag_rise		(	th_rise			),
//	.th_flag_fall		(	th_fall			), 
//	.TFT_VS_rise		(	vs_rise			),
//	.TFT_VS_fall		(	vs_fall			),
//	.frame_cnt			(	frame_cnt		),
//
//	.h_2				(	h_2				),
//	.v_5				(	v_5				),
//	.v_3				(	v_3				),
//	
//	.send_str			(	send_str		),
//	.reco_digital		(	reco_digital	)
//);


Char_Pic_Disply Char_Pic_Disply_m0
( 	
	.rst_n				(	rst_n				),   
	.clk				(	video_clk			),
	.x					(	GB_x				),        // video position X
	.y					(	GB_y				),         // video position y
	.i_hs				(	GB_hs				),    
	.i_vs				(	GB_vs				),    
	.i_de				(	GB_de				),    
	.i_data				(	GB_data				),
//	.reco_digital		(	reco_digital		),
	
//	.h_2				(	h_2					),
//	.v_5				(	v_5					),
//	.v_3				(	v_3					),		
	
	.o_hs				(	disp_hs				),    
	.o_vs				(	disp_vs				), 
	.o_de				(	disp_de				),
	.o_data 			(	disp_data			)

);

test_char_send test_char_send_m0
(
	.clk				(	clk					),
	.rst_n				(	rst_n				),
	.send_str			(	send_str			),
	.reco_digital		(	reco_digital		),
	
	.RsTx				(	tx					)
);

//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd130560               ), //frame size 480x272
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd130560               ), //frame size
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
//sdram controller
sdram_core sdram_core_m0
(
	.rst                        (~rst_n                   ),
	.clk                        (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.sdram_cke                  (sdram_cke                ),
	.sdram_cs_n                 (sdram_cs_n               ),
	.sdram_ras_n                (sdram_ras_n              ),
	.sdram_cas_n                (sdram_cas_n              ),
	.sdram_we_n                 (sdram_we_n               ),
	.sdram_dqm                  (sdram_dqm                ),
	.sdram_ba                   (sdram_ba                 ),
	.sdram_addr                 (sdram_addr               ),
	.sdram_dq                   (sdram_dq                 )
);
endmodule