// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Segment_scan 
// 
// Author: Step
// 
// Description: Display with Segment tube
// 
// Web: www.stepfpga.com
// 
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
module display(
		input				clk,		
		input				rst_n,	
		input		[3:0]	dat_1,	
		input		[3:0]	dat_2,	
		input		[3:0]	dat_3,	
		input		[3:0]	dat_4,	
		input		[3:0]	dat_5,	
		input		[3:0]	dat_6,
		input		[3:0]	dat_7,	
		input		[3:0]	dat_8,	
		input		[7:0]	dat_en,	
		input		[7:0]	dot_en,	
		output	reg	seg_rck,	
		output	reg	seg_sck,	
		output	reg	seg_din		
	);

localparam	CNT_40KHz = 300;	

localparam	IDLE	=	3'd0;
localparam	MAIN	=	3'd1;
localparam	WRITE	=	3'd2;
localparam	LOW		=	1'b0;
localparam	HIGH	=	1'b1;


reg[6:0] seg [15:0]; 
always @(negedge rst_n) begin
    seg[0]	=	7'h3f;   // 0
    seg[1]	=	7'h06;   // 1
    seg[2]	=	7'h5b;   // 2
    seg[3]	=	7'h4f;   // 3
    seg[4]	=	7'h66;   // 4
    seg[5]	=	7'h6d;   // 5
    seg[6]	=	7'h7d;   // 6
    seg[7]	=	7'h07;   // 7
    seg[8]	=	7'h7f;   // 8
    seg[9]	=	7'h6f;   // 9
	seg[10]	=	7'h40;   // A
    seg[11]	=	7'h7c;   // b
    seg[12]	=	7'h39;   // C
    seg[13]	=	7'h5e;   // d
    seg[14]	=	7'h79;   // E
    seg[15]	=	7'h71;   // F
end 
	

reg [9:0] cnt = 1'b0;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) cnt <= 1'b0;
	else if(cnt>=(CNT_40KHz-1)) cnt <= 1'b0;
	else cnt <= cnt + 1'b1;
end


reg clk_40khz = 1'b0; 
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) clk_40khz <= 1'b0;
	else if(cnt<(CNT_40KHz>>1)) clk_40khz <= 1'b0;
	else clk_40khz <= 1'b1;
end


reg		[15:0]		data;
reg		[2:0]		cnt_main;
reg		[5:0]		cnt_write;
reg		[2:0] 		state = IDLE;
always@(posedge clk_40khz or negedge rst_n) begin
	if(!rst_n) begin
		state <= IDLE;
		cnt_main <= 3'd0; cnt_write <= 6'd0;
		seg_din <= 1'b0; seg_sck <= LOW; seg_rck <= LOW;
	end else begin
		case(state)
			IDLE:begin	
					state <= MAIN;
					cnt_main <= 3'd0; cnt_write <= 6'd0;
					seg_din <= 1'b0; seg_sck <= LOW; seg_rck <= LOW;
				end
			MAIN:begin
					cnt_main <= cnt_main + 1'b1;
					state <= WRITE;		
					case(cnt_main)
						3'd0: data <= {{dot_en[7],seg[dat_1]},dat_en[7]?8'hfe:8'hff};
						3'd1: data <= {{dot_en[6],seg[dat_2]},dat_en[6]?8'hfd:8'hff}; 
						3'd2: data <= {{dot_en[5],seg[dat_3]},dat_en[5]?8'hfb:8'hff}; 
						3'd3: data <= {{dot_en[4],seg[dat_4]},dat_en[4]?8'hf7:8'hff}; 
						3'd4: data <= {{dot_en[3],seg[dat_5]},dat_en[3]?8'hef:8'hff};
						3'd5: data <= {{dot_en[2],seg[dat_6]},dat_en[2]?8'hdf:8'hff}; 
						3'd6: data <= {{dot_en[1],seg[dat_7]},dat_en[1]?8'hbf:8'hff}; 
						3'd7: data <= {{dot_en[0],seg[dat_8]},dat_en[0]?8'h7f:8'hff}; 
						default: data <= {8'h00,8'hff};
					endcase
				end
			WRITE:begin
					if(cnt_write >= 6'd33) cnt_write <= 1'b0;
					else cnt_write <= cnt_write + 1'b1;
					case(cnt_write)
						6'd0:  begin seg_sck <= LOW; seg_din <= data[15]; end		
						6'd1:  begin seg_sck <= HIGH; end							
						6'd2:  begin seg_sck <= LOW; seg_din <= data[14]; end
						6'd3:  begin seg_sck <= HIGH; end
						6'd4:  begin seg_sck <= LOW; seg_din <= data[13]; end
						6'd5:  begin seg_sck <= HIGH; end
						6'd6:  begin seg_sck <= LOW; seg_din <= data[12]; end
						6'd7:  begin seg_sck <= HIGH; end
						6'd8:  begin seg_sck <= LOW; seg_din <= data[11]; end
						6'd9:  begin seg_sck <= HIGH; end
						6'd10: begin seg_sck <= LOW; seg_din <= data[10]; end
						6'd11: begin seg_sck <= HIGH; end
						6'd12: begin seg_sck <= LOW; seg_din <= data[9]; end
						6'd13: begin seg_sck <= HIGH; end
						6'd14: begin seg_sck <= LOW; seg_din <= data[8]; end
						6'd15: begin seg_sck <= HIGH; end
						6'd16: begin seg_sck <= LOW; seg_din <= data[7]; end
						6'd17: begin seg_sck <= HIGH; end
						6'd18: begin seg_sck <= LOW; seg_din <= data[6]; end
						6'd19: begin seg_sck <= HIGH; end
						6'd20: begin seg_sck <= LOW; seg_din <= data[5]; end
						6'd21: begin seg_sck <= HIGH; end
						6'd22: begin seg_sck <= LOW; seg_din <= data[4]; end
						6'd23: begin seg_sck <= HIGH; end
						6'd24: begin seg_sck <= LOW; seg_din <= data[3]; end
						6'd25: begin seg_sck <= HIGH; end
						6'd26: begin seg_sck <= LOW; seg_din <= data[2]; end
						6'd27: begin seg_sck <= HIGH; end
						6'd28: begin seg_sck <= LOW; seg_din <= data[1]; end
						6'd29: begin seg_sck <= HIGH; end
						6'd30: begin seg_sck <= LOW; seg_din <= data[0]; end
						6'd31: begin seg_sck <= HIGH; end
						6'd32: begin seg_rck <= HIGH; end								
						6'd33: begin seg_rck <= LOW; state <= MAIN; end
						default: ;
					endcase
				end
			default: state <= IDLE;
		endcase
	end
end

endmodule
