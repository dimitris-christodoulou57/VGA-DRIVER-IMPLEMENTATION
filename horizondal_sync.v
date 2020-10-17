`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitris Christodoulou
// 
// Create Date:    03:25:09 11/22/2018 
// Design Name: 
// Module Name:    horizondal_sync 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module horizondal_sync(reset, clk, pixel_addr, vga_hsync, read_mem);
input reset, clk;
output reg [6:0] pixel_addr;
output reg vga_hsync, read_mem;

//STATE ENCODING
parameter   STATE_B = 4'b0001,
				STATE_C = 4'b0010,
				STATE_D = 4'b0100,
				STATE_E = 4'b1000;

reg [3:0] state;//save current state of waveform
reg [10:0] cycle_counter;//measure cycle in order to create waveform
reg [6:0] pixel_counter;//measure cycle in order to know which pixel read from memory
reg [3:0] pixel_loop;//repeat one pixel five time in row
wire [3:0] pixel_loop_max;

assign pixel_loop_max = 4'b1001;//need to repeat 5 times pixel 

always@(posedge reset or posedge clk)
begin
	if(reset)//reset initialize counter
	begin
		state = STATE_B;
		cycle_counter = 11'd0;
		pixel_counter = 7'd0;
		pixel_addr = 7'd0;
		pixel_loop = 4'd0;
		vga_hsync = 1'b1;
		read_mem = 1'b1;
	end
	else
	begin
		case (state)
			STATE_B://HSYNC Pulse Width - make hsync zero for 192 times
			begin
				vga_hsync = 1'b0;
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 11'd192)//if counter take value 192, go to next state and do counter 0
				begin
					cycle_counter = 11'd0;
					state = STATE_C;
				end
			end
			STATE_C://Back Porch - make hsync 1 and count 96 times in order to take rgb value from memory
			begin
				vga_hsync = 1'b1;
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 11'd96)//if counter take value 192, go to next state and do counter 0
				begin
					cycle_counter = 11'd0;
					state = STATE_D;
				end
			end
			STATE_D://Display Time - take rgb value from memory
			begin
				read_mem = 1'b1;//read_mem in order to read from memory
				pixel_addr = pixel_counter;
				case (pixel_loop)//repeat pixel 5 time before go to next pixel
					pixel_loop_max:
					begin
						pixel_counter = pixel_counter + 1;
						pixel_loop = 4'd0;
					end
					default:
					begin
						pixel_loop = pixel_loop + 1;
					end
				endcase
				
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 11'd1280)//complete row pixel
				begin
					cycle_counter = 11'd0;
					state = STATE_E;
				end
			end
			STATE_E://Front Porch - count 32 and make all counter 0
			begin
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 11'd1)//init counters
				begin
					read_mem = 1'b0;//read_mem = 0 in order to not take pixel from memory
					pixel_addr = 7'd0;
					pixel_counter = 7'd0;
					pixel_loop = 4'b0;
				end
				if(cycle_counter == 11'd32)//complete the diplay of row
				begin
					cycle_counter = 11'd0;
					pixel_addr = 7'd0;
					pixel_counter = 7'd0;
					pixel_loop = 4'b0;
					state = STATE_B;
				end
			end
		endcase
	end
end


endmodule
