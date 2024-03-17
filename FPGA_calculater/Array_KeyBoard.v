// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Array_KeyBoard
// 
// Author: Step
// 
// Description: Array_KeyBoard
// 
// Web: www.stepfapga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module Array_KeyBoard #
(
	parameter			NUM_FOR_200HZ = 60000	//定义计数器cnt的计数范围，例化时可更改
)
(
	input					clk_in,			//系统时钟
	input					rst_n_in,		//系统复位，低有效
	input			[3:0]	col,			//矩阵按键列接口
	output	reg		[3:0]	row,			//矩阵按键行接口
	output	reg		[15:0]	key_out			//消抖后的信号
);
/*
因使用4x4矩阵按键，通过扫描方法实现，所以这里使用状态机实现，共分为4种状态
在其中的某一状态时间里，对应的4个按键相当于独立按键，可按独立按键的周期采样法采样
周期采样时每隔20ms采样一次，对应这里状态机每隔20ms循环一次，每个状态对应5ms时间
对矩阵按键实现原理不明白的，请去了解矩阵按键实现原理
*/	
	localparam			STATE0 = 2'b00;
	localparam			STATE1 = 2'b01;
	localparam			STATE2 = 2'b10;
	localparam			STATE3 = 2'b11;
 
	//计数器计数分频实现5ms周期信号clk_200hz
	reg		[15:0]		cnt;
	reg					clk_200hz;
	always@(posedge clk_in or negedge rst_n_in) begin
		if(!rst_n_in) begin		//复位时计数器cnt清零，clk_200hz信号起始电平为低电平
			cnt <= 16'd0;
			clk_200hz <= 1'b0;
		end else begin
			if(cnt >= ((NUM_FOR_200HZ>>1) - 1)) begin	//数字逻辑中右移1位相当于除2
				cnt <= 16'd0;
				clk_200hz <= ~clk_200hz;	//clk_200hz信号取反
			end else begin
				cnt <= cnt + 1'b1;
				clk_200hz <= clk_200hz;
			end
		end
	end
 
	reg		[1:0]		c_state;
	//状态机根据clk_200hz信号在4个状态间循环，每个状态对矩阵按键的行接口单行有效
	always@(posedge clk_200hz or negedge rst_n_in) begin
		if(!rst_n_in) begin
			c_state <= STATE0;
			row <= 4'b1110;
		end else begin
			case(c_state)
				STATE0: begin c_state <= STATE1; row <= 4'b1101; end	//状态c_state跳转及对应状态下矩阵按键的row输出
				STATE1: begin c_state <= STATE2; row <= 4'b1011; end
				STATE2: begin c_state <= STATE3; row <= 4'b0111; end
				STATE3: begin c_state <= STATE0; row <= 4'b1110; end
				default:begin c_state <= STATE0; row <= 4'b1110; end
			endcase
		end
	end
 
	//因为每个状态中单行有效，通过对列接口的电平状态采样得到对应4个按键的状态，依次循环
	always@(negedge clk_200hz or negedge rst_n_in) begin
		if(!rst_n_in) begin
			key_out <= 16'hffff;
		end else begin
			case(c_state)
				STATE0:key_out[3:0] <= col;		//采集当前状态的列数据赋值给对应的寄存器位
				STATE1:key_out[7:4] <= col;
				STATE2:key_out[11:8] <= col;
				STATE3:key_out[15:12] <= col;
				default:key_out <= 16'hffff;
			endcase
		end
	end
 
endmodule