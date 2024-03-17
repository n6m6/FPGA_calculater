module calculate
(
	input					clk_in,			//系统时钟
	input					rst_n_in,		//系统复位，低有效
	input		[15:0]	    key_in,	    	//矩阵按键列接口
	
	output reg	[3:0]	    seg_data_1,	    	//SEG1 数码管要显示的数据
    output reg	[3:0]	    seg_data_2,	    	//SEG2 数码管要显示的数据
    output reg	[3:0]	    seg_data_3,	       	//SEG3 数码管要显示的数据
    output reg	[3:0]	    seg_data_4,	    	//SEG4 数码管要显示的数据
    output reg	[3:0]	    seg_data_5,	    	//SEG5 数码管要显示的数据
    output reg	[3:0]	    seg_data_6,		    //SEG6 数码管要显示的数据
    output reg	[3:0]	    seg_data_7,		    //SEG6 数码管要显示的数据
    output reg	[3:0]	    seg_data_8,		    //SEG6 数码管要显示的数据
    output reg	[7:0]	    seg_data_en,    	//各位数码管数据显示使能，[MSB~LSB]=[SEG8~SEG1]
    output reg 	[7:0]	    seg_dot_en	    	//各位数码管小数点显示使能，[MSB~LSB]=[SEG8~SEG1]
	
);
    //按键信息转化
    localparam ZERO  = 16'b1110111111111111;  //0
    localparam ONE   = 16'b1111101111111111;  //1
    localparam TWO   = 16'b1111110111111111;  //2
    localparam THREE = 16'b1111111011111111;  //3
    localparam FOUR  = 16'b1111111111101111;  //4
    localparam FIVE  = 16'b1111111111011111;  //5
    localparam SIX   = 16'b1111111110111111;  //6
    localparam SEVEN = 16'b1111111111111110;  //7
    localparam EIGHT = 16'b1111111111111101;  //8
    localparam NINE  = 16'b1111111111111011;  //9
    localparam PLUS  = 16'b0111111111111111;  //+
    localparam MINUS = 16'b1111011111111111;  //-
    localparam MUL   = 16'b1111111101111111;  //×
    localparam DIV   = 16'b1111111111110111;  //÷
    localparam EQL   = 16'b1011111111111111;  //=
    
    //状态机状态定义
    localparam STATE1 =4'b0001;//初始状态
    localparam STATE2 =4'b0010;//接收完第一个数字
    localparam STATE3 =4'b0011;//接收完第二个数字
    localparam STATE4 =4'b0100;//接收运算符
    localparam STATE5 =4'b0101;//接收完第三个数字
    localparam STATE6 =4'b0110;//接收完第四个数字
    localparam STATE7 =4'b0111;//显示结果
    
    //运算状态定义
    localparam STATE_PLUS  =2'b00;//初始状态
    localparam STATE_MINUS =2'b01;//初始状态
    localparam STATE_MUL   =2'b10;//初始状态
    localparam STATE_DIV   =2'b11;//初始状态
    
    reg [15:0]num1;
    reg [15:0]num2;
    reg [15:0]answer;
    
    reg [3:0]state;//状态机状态
    reg [1:0]state_o;//运算状态
    
    reg [15:0]pre_key_in;
    reg [15:0]now_key_in;
    
    wire key_in_state;
    
    always@(posedge clk_in or negedge rst_n_in) begin
    if(!rst_n_in) begin
        now_key_in <= 16'b0;
        pre_key_in <= 16'b0;
    end else begin
        now_key_in <= key_in;
        pre_key_in <= now_key_in;
    end
    end
    
    assign key_in_state = (&pre_key_in)&(~(&now_key_in));    //检测按键信号上升沿
    
    reg [15:0]  num1_1;//num1小数部分×100
    
    reg [19:0]answer_r;
    
    reg [3:0]answer_001num = 4'b0;
    reg [3:0]answer_01num = 4'b0;
    reg [3:0]answer_1num = 4'b0;
    reg [3:0]answer_10num = 4'b0;
    reg [3:0]answer_100num = 4'b0;
    reg [3:0]answer_1000num = 4'b0;
    
    reg DIV_flag = 1'b0;//除法标志位
    reg minus_flag = 1'b0;//除法标志位
    reg done_flag = 1'b0;//完成标志位
    reg mul_flag = 1'b0;
    
    reg temp = 1'b0;
    reg qidong_state = 1'b0;
    
always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin	//复位状态下，各寄存器置初值
		state <= STATE1;
		state_o <= 2'b0;
		num1 <= 16'b0;
		num2 <= 16'b0;
		seg_data_1 <= 4'b0;
		seg_data_2 <= 4'b0;
		seg_data_3 <= 4'b0;
		seg_data_4 <= 4'b0;
		seg_data_5 <= 4'b0;
		seg_data_6 <= 4'b0;
		seg_data_7 <= 4'b0;
		seg_data_8 <= 4'b0;
		seg_data_en<= 8'b11111111;
		seg_dot_en <= 8'b0;
		answer <= 14'b0;
		
		answer_r <= 20'b0;
        answer_001num <= 4'b0;
        answer_01num <= 4'b0;
        answer_1num <= 4'b0;
        answer_10num <= 4'b0;
        answer_100num <= 4'b0;
        answer_1000num <= 4'b0;
        seg_data_en <= 8'b0;
        seg_dot_en <= 8'b0;
        DIV_flag <= 1'b0;
        done_flag <= 1'b0;
        minus_flag <= 1'b0;
        mul_flag <= 1'b0;
        qidong_state <= 1'b0;
		
	end else begin
	    seg_dot_en <= 8'b0;
	    if(key_in_state ) begin
    		case(state)
    		STATE1:begin
    			    state <= STATE2;
    			    seg_data_en <= 8'b00000001;
    				case(key_in)
    				    ZERO: begin    
    				        seg_data_8 <= 4'd0;
    				        num1<=16'd0;end
    				    ONE : begin    
    				        seg_data_8 <= 4'd1;
    				        num1<=16'd1;end
    				    TWO :   begin    
    				        seg_data_8 <= 4'd2;
    				        num1<=16'd2;end
    				    THREE :  begin    
    				        seg_data_8 <= 4'd3;
    				        num1<=16'd3;end
    				    FOUR :   begin    
    				        seg_data_8 <= 4'd4;
    				        num1<=16'd4;end
    				    FIVE :  begin    
    				        seg_data_8 <= 4'd5;
    				        num1<=16'd5;end
    				    SIX :   begin    
    				        seg_data_8 <= 4'd6;
    				        num1<=16'd6;end
    				    SEVEN :begin    
    				        seg_data_8 <= 4'd7;
    				        num1<=16'd7;end
    				    EIGHT : begin    
    				        seg_data_8 <= 4'd8;
    				        num1<=16'd8;end
    				    NINE :   begin    
    				        seg_data_8 <= 4'd9;
    				        num1<=16'd9;end
    				    default : begin 
    				        state <= STATE1;
    				        seg_data_en <= 8'b0;
    				        num1<=0;
    				        end
    				endcase
    		end
    			
    		STATE2:begin
    				state <= STATE3;
    			    seg_data_7 <= seg_data_8;
    				case(key_in)
    				    ZERO:  begin   
        				    seg_data_8 <= 4'd0;
        				    num1<=(16'd10*num1) + 16'd0;
        				    seg_data_en <= 8'b00000011;end
    				    ONE : begin   
        				    seg_data_8 <= 4'd1;
        				    num1<=(16'd10*num1) + 16'd1;
        				    seg_data_en <= 8'b00000011;end
    				    TWO :  begin   
        				    seg_data_8 <= 4'd2;
        				    num1<=(16'd10*num1) + 16'd2;
        				    seg_data_en <= 8'b00000011;end
    				    THREE :  begin   
        				    seg_data_8 <= 4'd3;
        				    num1<=(16'd10*num1) + 16'd3;
        				    seg_data_en <= 8'b00000011;end
    				    FOUR :  begin   
        				    seg_data_8 <= 4'd4;
        				    num1<=(16'd10*num1) + 16'd4;
        				    seg_data_en <= 8'b00000011;end
        				FIVE :  begin    
    				        seg_data_8 <= 4'd5;
    				        num1<=(16'd10*num1) + 16'd5;
    				        seg_data_en <= 8'b00000011;end
    				    SIX :   begin   
        				    seg_data_8 <= 4'd6;
        				    num1<=(16'd10*num1) + 16'd6;
        				    seg_data_en <= 8'b00000011;end
    				    SEVEN :  begin   
        				    seg_data_8 <= 4'd7;
        				    num1<=(16'd10*num1) + 16'd7;
        				    seg_data_en <= 8'b00000011;end
    				    EIGHT :  begin   
        				    seg_data_8 <= 4'd8;
        				    num1<=(16'd10*num1) + 16'd8;
        				    seg_data_en <= 8'b00000011;end
    				    NINE :  begin   
        				    seg_data_8 <= 4'd9;
        				    num1<=(16'd10*num1) + 16'd9;
        				    seg_data_en <= 8'b00000011;end
        				PLUS :begin
        				    num1 <= num1;
        				    seg_data_en <= 8'b00000001;
    				        state <= STATE4;
    				        state_o <= STATE_PLUS;
    				        end
    				    MINUS :begin
    				        num1 <= num1;
        				    seg_data_en <= 8'b00000001;
    				        state <= STATE4;
    				        state_o <= STATE_MINUS;
    				        end
    			        MUL :begin
    			            num1 <= num1;
        				    seg_data_en <= 8'b00000001;
    				        state <= STATE4;
    				        state_o <= STATE_MUL;
    				        end
    			        DIV :begin
    			            num1 <= num1;
        				    seg_data_en <= 8'b00000001;
    				        state <= STATE4;
    				        state_o <= STATE_DIV;
    				        end
    				    default : begin 
    				        state <= STATE1;
    				        seg_data_en <= 8'b0;
    				        seg_data_7 <= 4'b0;
    				        seg_data_8 <= 4'b0;
    				        num1<=0;
    				        end
    				endcase
    				// num1 <= seg_data_7 * 4'd10 + seg_data_8;
    		end
    			
    		STATE3:begin
    			    state <= STATE4;
    			    case(key_in)
    			        PLUS :  state_o <= STATE_PLUS;
    			        MINUS : state_o <= STATE_MINUS;
    			        MUL :   state_o <= STATE_MUL;
    			        DIV :   state_o <= STATE_DIV;
    			        default : state <= STATE3;
    			    endcase
    		end
    			
    		STATE4:begin
    			    state <= STATE5;
    			    seg_data_en <= 8'b00000001;
    			    seg_data_8 <= 4'b0;
    			    case(key_in)
    				    ZERO: begin
    				        seg_data_8 <= 4'd0;
    				        num2<=16'd0;end
    				    ONE :   begin
    				        seg_data_8 <= 4'd1;
    				        num2<=16'd1;end
    				    TWO :   begin
    				        seg_data_8 <= 4'd2;
    				        num2<=16'd2;end
    				    THREE :  begin
    				        seg_data_8 <= 4'd3;
    				        num2<=16'd3;end
    				    FOUR :   begin
    				        seg_data_8 <= 4'd4;
    				        num2<=16'd4;end
    				    FIVE :  begin
    				        seg_data_8 <= 4'd5;
    				        num2<=16'd5;end
    				    SIX :    begin
    				        seg_data_8 <= 4'd6;
    				        num2<=16'd6;end
    				    SEVEN : begin
    				        seg_data_8 <= 4'd7;
    				        num2<=16'd7;end
    				    EIGHT :  begin
    				        seg_data_8 <= 4'd8;
    				        num2<=16'd8;end
    				    NINE :  begin
    				        seg_data_8 <= 4'd9;
    				        num2<=16'd9;end
    				   
    				    default : begin 
    				        state <= STATE4;
    				        seg_data_en <= 8'b0;
    				        num2<=0;
    				        end
    				endcase
    		end
    			
    		STATE5:begin
    			    state <= STATE6;
    			    seg_data_7 <= seg_data_8;
    				case(key_in)
    				    ZERO:  begin
    				        seg_data_8 <= 4'd0;
    				        num2<=(num2*16'd10) + 16'd0;
    				        seg_data_en <= 8'b00000011;end
    				    ONE :   begin
    				        seg_data_8 <= 4'd1;
    				        num2<=(num2*16'd10) +16'd1;
    				        seg_data_en <= 8'b00000011;end
    				    TWO :    begin
    				        seg_data_8 <= 4'd2;
    				        num2<=(num2*16'd10) + 16'd2;
    				        seg_data_en <= 8'b00000011;end
    				    THREE :  begin
    				        seg_data_8 <= 4'd3;
    				        num2<=(num2*16'd10) + 16'd3;
    				        seg_data_en <= 8'b00000011;end
    				    FOUR :   begin
    				        seg_data_8 <= 4'd4;
    				        num2<=(num2*16'd10)+16'd4;
    				        seg_data_en <= 8'b00000011;end
    				    FIVE :  begin
    				        seg_data_8 <= 4'd5;
    				        num2<=(num2*16'd10)+16'd5;
    				        seg_data_en <= 8'b00000011;end
    				    SIX :   begin
    				        seg_data_8 <= 4'd6;
    				        num2<=(num2*16'd10)+16'd6;
    				        seg_data_en <= 8'b00000011;end
    				    SEVEN : begin
    				        seg_data_8 <= 4'd7;
    				        num2<=(num2*16'd10)+16'd7;
    				        seg_data_en <= 8'b00000011;end
    				    EIGHT : begin
    				        seg_data_8 <= 4'd8;
    				        num2<=(num2*16'd10)+16'd8;
    				        seg_data_en <= 8'b00000011;end
    				    NINE :   begin
    				        seg_data_8 <= 4'd9;
    				        num2<=(num2*16'd10)+16'd9;
    				        seg_data_en <= 8'b00000011;end
    				    PLUS :begin
        				    num2 <= num2;
        				    seg_data_en <= 8'b00000001;
    				        end
    				    MINUS :begin
    				        num2 <= num2;
        				    seg_data_en <= 8'b00000001;
    				        end
    			        MUL :begin
    			            num2 <= num2;
        				    seg_data_en <= 8'b00000001;
    				        end
    			        DIV :begin
    			            num2 <= num2;
        				    seg_data_en <= 8'b00000001;
    				        end
    				        
    				    default : begin 
    				        state <= STATE4;
    				        seg_data_en <= 8'b0;
    				        seg_data_7 <= 4'b0;
    				        seg_data_8 <= 4'b0;
    				        num2<=0;
    				        end
    				endcase
    		end
    			
    		
    			
    		endcase
		end
		else begin
    		if(state==STATE6) begin
        		       if(key_in == EQL)begin
            			    state <= STATE7;
            			    
            			    case(state_o)
                			    STATE_PLUS:begin
                    			    answer <= num1 + num2;
                    			
                			    end
                			
                			    STATE_MINUS:begin
                    			    answer <= num1 - num2;
                    			
                			    end
                			    
                			    STATE_MUL:begin
                    			    answer <= num1 * num2;
                    			   
                			    end
                			    
                			    STATE_DIV:begin
                			        qidong_state <= 1'b1;
                    			    DIV_flag <= 1'b1;
                    			    if(!mul_flag)begin
                    			        num1_1 <= num1 * 16'd10000;
                    			        mul_flag <= 1'b1;
                    			        state <= STATE6;
                    			        end
                    			    if(num1_1>num2)begin
                    			        answer <= answer +16'b1;
                    			        num1_1 <= num1_1 - num2;
                    			        state <= STATE6;
                    			    end else begin
                    			        DIV_flag <= 1'b0;
                    			        qidong_state <= 1'b0;
                    			        state <= STATE7;
                    			    end
                			        
                			    end
            			    endcase
        			  end
        			 
        	end
        			
        	else if(state==STATE7) begin
        		qidong_state <= 1'b1;
        		    if(temp==0)begin
                        seg_data_5 <= 4'd0;
                        seg_data_6 <= 4'd0;
                        seg_data_7 <= 4'd0;
                        seg_data_8 <= 4'd0;
                        seg_data_1 <= 4'd0;
                        seg_data_2 <= 4'd0;
                        seg_data_3 <= 4'd0;
                        seg_data_4 <= 4'd0;
                        
                        temp<=1;
                        
                    end
        
                    else if(DIV_flag)begin//除法运算的显示
                        if(answer>=20'd100000)begin
                        answer <= answer - 16'd1000;
                        seg_data_3<=seg_data_3 + 4'd1;
                       
                        end
                        else if(answer>=16'd10000 )begin
                            answer<=answer - 16'd10000;
                            seg_data_4<=seg_data_4 + 4'd1;
                        end
                        else if(answer>=16'd1000 )begin
                            answer<=answer - 16'd1000;
                            seg_data_5<=seg_data_5 + 4'd1;
                        end
                        else if(answer>=16'd100 )begin
                            answer<=answer - 16'd100;
                            seg_data_6<=seg_data_6 + 4'd1;
                        end
                        else if(answer>=16'd10 )begin
                            answer<=answer - 16'd10;
                            seg_data_7<=seg_data_7 + 4'd1;
                        end
                        else if(answer>=16'd1 )begin//最后一个个位数，显示完毕
                            answer<=answer - 16'd1;
                            seg_data_8<=seg_data_8 + 4'd1;
                        end else begin
                            seg_data_en <= 8'b00111111;
                            seg_dot_en <= 8'b00010000;
                        end
        	            
        	    	end 
        	    	else if(done_flag==0) begin//非除法运算的显示
        	    	
        		        if(answer>=16'd1000)begin
                        answer <= answer - 16'd1000;
                        seg_data_5<=seg_data_5 + 4'd1;
                       
                        end
                        else if(answer>=16'd100 )begin
                            answer<=answer - 16'd100;
                            seg_data_6<=seg_data_6 + 4'd1;
                        end
                        else if(answer>=16'd10 )begin
                            answer<=answer - 16'd10;
                            seg_data_7<=seg_data_7 + 4'd1;
                        end
                        else if(answer>=16'd1 )begin//最后一个个位数，显示完毕
                            answer<=answer - 16'd1;
                            seg_data_8<=seg_data_8 + 4'd1;
                        end
                        else begin
                            if(num1 < num2 && state_o == STATE_MINUS)begin
                                if(seg_data_7)begin
                                    seg_data_en<=8'b0000_0111;
                                    seg_data_6<=4'd10;
                                end
                                else begin
                                    seg_data_en<=8'b0000_0011;
                                    seg_data_7<=4'd10;
                                end
                                
                            end
                            else begin
                                if(seg_data_5)begin
                                    seg_data_en<=8'b0000_1111;
                                end
                                else if(seg_data_6)begin
                                    seg_data_en<=8'b0000_0111;
                                end
                                else if(seg_data_7)begin
                                    seg_data_en<=8'b0000_0011;
                                end
                                else if(seg_data_8)begin
                                    seg_data_en<=8'b0000_0001;
                                end
                            end
                            done_flag <= 1'b1;
                            
                        end
        
        		
        		    end
            		else begin
                    state <= STATE1;
               	    done_flag <= 1'b0;
               	    qidong_state <= 1'b0;
               	    temp<=0;
               	    num1<=0;
               	    num2<=0;
        		    end
        		end
		end
    end
end
    
    
    
    
    
    always@(posedge clk_in or negedge rst_n_in) begin
	if(!rst_n_in) begin	//复位状态下，各寄存器置初值 
	    
        
    end else begin
   
		
    end
    end
endmodule
    
