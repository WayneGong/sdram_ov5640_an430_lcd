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
	output						led,
	
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

wire		[2:0] 				frame_cnt;

wire		[8:0]				feature_code1;
wire		[8:0]				feature_code2;
wire		[8:0]				feature_code3;
wire		[8:0]				feature_code4;
wire		[8:0]				feature_code5;

wire		[11:0]				edge_left;	
wire		[11:0]				edge_right;
wire		[11:0]				edge_up;
wire		[11:0]				edge_down;

wire		[11:0]				Partition_line1;
wire		[11:0]				Partition_line2;
wire		[11:0]				Partition_line3;
wire		[11:0]				Partition_line4;
wire		[11:0]				Partition_line5;
wire		[11:0]				Partition_line6;

wire		[11:0]				char_up_position;	
wire		[11:0]				char_down_position;

wire		[11:0]				row_scanf_line1;
wire		[11:0]				row_scanf_line2;

wire		[3:0]				chepai_Digital_1;
wire		[3:0]				chepai_Digital_2;
wire		[3:0]				chepai_Digital_3;
wire		[3:0]				chepai_Digital_4;
wire		[3:0]				chepai_Digital_5;

wire		[11:0]				char1_middle;
wire		[11:0]				char2_middle;
wire		[11:0]				char3_middle;
wire		[11:0]				char4_middle;
wire		[11:0]				char5_middle;

wire		[7:0]				intersection_code1;
wire		[7:0]				intersection_code2;
wire		[7:0]				intersection_code3;
wire		[7:0]				intersection_code4;
wire		[7:0]				intersection_code5;

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
//PLL模块，用于生产摄像头的时钟信号和SDRMA的时钟信号
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (cmos_xclk                ),	//24MHz
	.c1                         (ext_mem_clk              )		//100MHz
	);
//generate video pixel clock
//PLL模块，生产LCD屏幕的时钟信号
video_pll video_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (video_clk                )		//9MHz
	);
	
//I2C master controller
//IIC时序生成器，用于摄像头参数的配置
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
//摄像头配置参数表
lut_ov5640_rgb565_480_272 lut_ov5640_rgb565_480_272_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);
//CMOS sensor 8bit data is converted to 16bit data
//摄像头的图像数据的捕获和位宽转换，将输入的8位图像数据拼接位16位的图像数据（RGB565）
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
//CMOS传感器写入请求并生成读写地址索引
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
//生成LCD屏幕的驱动时序，并且生成读信号请求，用于从SDRAM中读取缓存的图像数据。
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

//用于生成LCD的坐标参数
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

//按键模块，将数据的按键信号进行消抖处理
key_Module  key_Module_m0
(
	.clk					(	video_clk			),
	.rst_n					(	rst_n				),
	.key_in					(	key					),
	.key_out				(	key_out				)
); 

//图像数据的灰度处理和二值化处理
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
	.th_flag				(	th_flag				),
	
	.o_hs					(	GB_hs				),
    .o_vs					(	GB_vs				),
    .o_de					(	GB_de				),
	.o_x					(	GB_x				),
    .o_y					(	GB_y				),
	.o_data					(	GB_data				)

);

//车牌图像的定位模块
Picture_Char_Location Picture_Char_Location_m0
(

	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 

	.i_x					(	GB_x				),        // video position X
	.i_y					(	GB_y				),         // video position y	
	.i_data					(	GB_data				),
	.i_th					(	th_flag				),
	
	.edge_left				(	edge_left			),	
	.edge_up				(	edge_up				),
	.edge_down				(	edge_down			),
	.edge_right				(	edge_right			)
	
);

//车牌字符分割模块
Char_Division Char_Division_m0
( 
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),

	.i_x					(	GB_x				),        // video position X
	.i_y					(	GB_y				),         // video position y

	.edge_left				(	edge_left			),
	.edge_up				(	edge_up				),
	.edge_down				(	edge_down			),
	.edge_right				(	edge_right			),

	.char_up_position		(	char_up_position	),
	.char_down_position		(	char_down_position	),
	
	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),
	
	.Partition_line1		(	Partition_line1		),
	.Partition_line2		(	Partition_line2		),
	.Partition_line3		(	Partition_line3		),
	.Partition_line4		(	Partition_line4		),
	.Partition_line5		(	Partition_line5		),
	.Partition_line6		(	Partition_line6		)

);

//第一个字符的识别模块。采用区域扫描发和特征点识别法相结合的算法
Digital_feature_scan Digital_feature_scan_m1
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 
	
	.char_up				(	char_up_position	),
	.char_down				(	char_down_position	),	
	.char_left				(	Partition_line1		),
	.char_right				(	Partition_line2		),
	
	.i_x					(	GB_x				),			// video position X
	.i_y					(	GB_y				),			// video position y	

	.i_th					(	th_flag				),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),	
	
	.chepai_Digital			(	chepai_Digital_1	),
	.feature_code			(	feature_code1		),
	.char_middle			(	char1_middle		),
	.intersection_code		(	intersection_code1	)

);

//第二个字符的识别模块。采用区域扫描发和特征点识别法相结合的算法
Digital_feature_scan Digital_feature_scan_m2
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 
	
	.char_up				(	char_up_position	),
	.char_down				(	char_down_position	),	
	.char_left				(	Partition_line2		),
	.char_right				(	Partition_line3		),
	
	.i_x					(	GB_x				),			// video position X
	.i_y					(	GB_y				),			// video position y	

	.i_th					(	th_flag				),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),	
	
	.chepai_Digital			(	chepai_Digital_2	),
	.feature_code			(	feature_code2		),
	.char_middle			(	char2_middle		)

);

//第三个字符的识别模块。采用区域扫描发和特征点识别法相结合的算法
Digital_feature_scan Digital_feature_scan_m3
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 
	
	.char_up				(	char_up_position	),
	.char_down				(	char_down_position	),	
	.char_left				(	Partition_line3		),
	.char_right				(	Partition_line4		),
	
	.i_x					(	GB_x				),			// video position X
	.i_y					(	GB_y				),			// video position y	

	.i_th					(	th_flag				),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),
	
	.chepai_Digital			(	chepai_Digital_3	),
	.feature_code			(	feature_code3		),
	.char_middle			(	char3_middle		)

);
//第四个字符的识别模块。采用区域扫描发和特征点识别法相结合的算法
Digital_feature_scan Digital_feature_scan_m4
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 
	
	.char_up				(	char_up_position	),
	.char_down				(	char_down_position	),	
	.char_left				(	Partition_line4		),
	.char_right				(	Partition_line5		),
	
	.i_x					(	GB_x				),			// video position X
	.i_y					(	GB_y				),			// video position y	

	.i_th					(	th_flag				),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),
	
	.chepai_Digital			(	chepai_Digital_4	),
	.feature_code			(	feature_code4		),
	.char_middle			(	char4_middle		)

);
//第五个字符的识别模块。采用区域扫描发和特征点识别法相结合的算法
Digital_feature_scan5 Digital_feature_scan_m5
(
	.rst_n					(	rst_n				),   
	.clk					(	video_clk			),
	.i_hs					(	GB_hs				),    
	.i_vs					(	GB_vs				),    
	.i_de					(	GB_de				), 
	
	.char_up				(	char_up_position	),
	.char_down				(	char_down_position	),	
	.char_left				(	Partition_line5		),
	.char_right				(	Partition_line6		),
	
	.i_x					(	GB_x				),			// video position X
	.i_y					(	GB_y				),			// video position y	

	.i_th					(	th_flag				),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),
	
	
	.chepai_Digital			(	chepai_Digital_5	),
	.feature_code			(	feature_code5		),
	.char_middle			(	char5_middle		)

);

//Digital_intersection_Recognition Digital_intersection_Recognition_m0
//(
//	.rst_n					(	rst_n				),   
//	.clk					(	video_clk			),
//	.x						(	GB_x				),        // video position X
//	.y						(	GB_y				),         // video position y
//
//	.i_hs					(	GB_hs				),    
//	.i_vs					(	GB_vs				),    
//	.i_de					(	GB_de				),    
//	.i_th					(	th_flag				),
//	
//	.char_up				(	char_up_position	),
//	.char_down				(	char_down_position	),
//	.char_left				(	Partition_line1		),
//	.char_right				(	Partition_line2		),
//	
//	.row_scanf_line1		(	row_scanf_line1		),
//	.row_scanf_line2		(	row_scanf_line2		)
//		
//);

//车牌图像以及识别字符，辅助线的显示模块
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
	
	.edge_left			(	edge_left			),	
	.edge_up			(	edge_up				),
	.edge_down			(	edge_down			),
	.edge_right			(	edge_right			),
	
	.char_up_position		(	char_up_position	),
	.char_down_position		(	char_down_position	),

	.row_scanf_line1		(	row_scanf_line1		),
	.row_scanf_line2		(	row_scanf_line2		),	
	
	.Partition_line1		(	Partition_line1		),
	.Partition_line2		(	Partition_line2		),
	.Partition_line3		(	Partition_line3		),
	.Partition_line4		(	Partition_line4		),
	.Partition_line5		(	Partition_line5		),
	.Partition_line6		(	Partition_line6		),
	
	.char1_middle			(	char1_middle		),
	.char2_middle			(	char2_middle		),
	.char3_middle			(	char3_middle		),
	.char4_middle			(	char4_middle		),
	.char5_middle			(	char5_middle		),
	
	
	.chepai_Digital_1		(	chepai_Digital_1	),			
	.chepai_Digital_2		(	chepai_Digital_2	),
	.chepai_Digital_3		(	chepai_Digital_3	),
	.chepai_Digital_4		(	chepai_Digital_4	),
	.chepai_Digital_5		(	chepai_Digital_5	),
	
	.o_hs				(	disp_hs				),    
	.o_vs				(	disp_vs				), 
	.o_de				(	disp_de				),
	.o_data 			(	disp_data			)

);

//串口发送模块，用于调试数据
test_char_send test_char_send_m0
(
	.clk				(	clk					),
	.rst_n				(	rst_n				),
	.send_str			(	intersection_code1	),

	
	.RsTx				(	tx					)
);

//LED灯闪烁模块
led_shaning led_shaning_m0
(
	.clk				(	clk				),
	.rst_n				(	rst_n			),

	.led				(	led				)

);

//video frame data read-write control
//视频读写控制没夸
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
	.write_req                  (write_req                ),	//sys_addr[23:0]
	.write_req_ack              (write_req_ack            ),	//[23:22]	bank_addr
	.write_finish               (                         ),	//[21:9]	row_addr
	.write_addr_0               (24'd0                    ),	//[8:0]		col_addr
	.write_addr_1               (24'd2073600              ),	//‭00_01111110100100_00000000‬
	.write_addr_2               (24'd4147200              ),	//‭00_11111101001000_00000000‬
	.write_addr_3               (24'd6220800              ),	//‭01_01111011101100_00000000‬
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd130560               ), 	//frame size 480*272=130560	
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
//sdram controller
//SDRAM控制模块
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