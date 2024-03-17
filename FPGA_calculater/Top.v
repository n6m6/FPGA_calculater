module Top
(
    input           clk_in,
    input           rst_n,
	input			[3:0]	KeyBoard_col,//矩阵按键列接口
    
    output      	[3:0]	row_out,	//消抖后的信号
    output			top_rclk_out,		//74HC595的RCK管脚
    output			top_sclk_out,		//74HC595的SCK管脚
    output			top_sdio_out		//74HC595的SER管脚

);

wire    [15:0]      key_location; //消抖后的信号

wire	[3:0]	    top_seg_data_1;		//SEG1 数码管要显示的数据
wire	[3:0]   	top_seg_data_2;		//SEG2 数码管要显示的数据
wire	[3:0]   	top_seg_data_3;		//SEG3 数码管要显示的数据
wire	[3:0]   	top_seg_data_4;		//SEG4 数码管要显示的数据
wire	[3:0]   	top_seg_data_5;		//SEG5 数码管要显示的数据
wire	[3:0]   	top_seg_data_6;		//SEG6 数码管要显示的数据
wire	[3:0]   	top_seg_data_7;		//SEG7 数码管要显示的数据
wire	[3:0]   	top_seg_data_8;		//SEG8 数码管要显示的数据

wire    [7:0]       top_seg_data_en;    //各位数码管数据显示使能，[MSB~LSB]=[SEG8~SEG1]
wire    [7:0]       top_seg_dot_en;	    //各位数码管小数点显示使能，[MSB~LSB]=[SEG8~SEG1]

Array_KeyBoard Array_KeyBoard1
(
    .clk_in         (clk_in       ),
    .rst_n_in       (rst_n        ),
	.col            (KeyBoard_col),
	
	.row            (row_out      ),		//矩阵按键行接口
	.key_out        (key_location ) 		//消抖后的信号

);

calculate calculate1
(
    .clk_in         (clk_in       ),
    .rst_n_in       (rst_n        ),
	.key_in         (key_location ),	    	//矩阵按键列接口
	
	.seg_data_1     (top_seg_data_1),	    	//SEG1 数码管要显示的数据
    .seg_data_2     (top_seg_data_2),	    	//SEG2 数码管要显示的数据
    .seg_data_3     (top_seg_data_3),	       	//SEG3 数码管要显示的数据
    .seg_data_4     (top_seg_data_4),	    	//SEG4 数码管要显示的数据
    .seg_data_5     (top_seg_data_5),	    	//SEG5 数码管要显示的数据
    .seg_data_6     (top_seg_data_6),		    //SEG6 数码管要显示的数据
    .seg_data_7     (top_seg_data_7),		    //SEG6 数码管要显示的数据
    .seg_data_8     (top_seg_data_8),		    //SEG6 数码管要显示的数据
    .seg_data_en    (top_seg_data_en),    	    //各位数码管数据显示使能，[MSB~LSB]=[SEG8~SEG1]
    .seg_dot_en     (top_seg_dot_en)	    	//各位数码管小数点显示使能，[MSB~LSB]=[SEG8~SEG1]
	
);

display display1
(
    .clk            (clk_in       ),			//系统时钟
    .rst_n          (rst_n        ),		    //系统复位，低有效
    .dat_1         (top_seg_data_1),	    	//SEG1 数码管要显示的数据
    .dat_2         (top_seg_data_2),	    	//SEG2 数码管要显示的数据
    .dat_3         (top_seg_data_3),	       	//SEG3 数码管要显示的数据
    .dat_4         (top_seg_data_4),	    	//SEG4 数码管要显示的数据
    .dat_5         (top_seg_data_5),	    	//SEG5 数码管要显示的数据
    .dat_6         (top_seg_data_6),		    //SEG6 数码管要显示的数据
    .dat_7         (top_seg_data_7),		    //SEG6 数码管要显示的数据
    .dat_8         (top_seg_data_8),		    //SEG6 数码管要显示的数据
    .dat_en        (top_seg_data_en),    	    //各位数码管数据显示使能，[MSB~LSB]=[SEG8~SEG1]
    .dot_en         (top_seg_dot_en),	    	//各位数码管小数点显示使能，[MSB~LSB]=[SEG8~SEG1]
    
    .seg_rck        (top_rclk_out),		//74HC595的RCK管脚
    .seg_sck        (top_sclk_out),		//74HC595的SCK管脚
    .seg_din        (top_sdio_out)		//74HC595的SER管脚

);

endmodule

