`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitris Christodoulou
// 
// Create Date:    03:05:01 11/25/2018 
// Design Name: 
// Module Name:    vertical_sync 
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
module vertical_sync(reset, clk, vertical_pixel_addr, vga_vsync, read_mem_vertical);
input reset, clk;
output reg [6:0] vertical_pixel_addr;
output reg vga_vsync, read_mem_vertical;

//STATE ENCODING one-hot
parameter   STATE_P = 4'b0001,
				STATE_Q = 4'b0010,
				STATE_R = 4'b0100,
				STATE_S = 4'b1000;

reg [3:0] state;//save current state of waveform
reg [20:0] cycle_counter;//measure cycle in order to create waveform
reg [6:0] vertical_pixel_counter;//measure cycle in order to know which vertical pixel read from memory
reg [12:0] row_loop;//repeat one row five time measure 5*1600. 1600 cycle to complete one row with horizontal_sync
wire [12:0] row_loop_max;

assign row_loop_max = 13'd7999;//repeat 5 rows so 5*1600=8000 clk cycle

always@(posedge reset or posedge clk)
begin
	if (reset)//reset initialize counter
	begin
		state = STATE_P;
		cycle_counter = 21'd0;
		read_mem_vertical = 1'b0;
		vertical_pixel_addr = 7'd0;
		vertical_pixel_counter = 7'd0;
		row_loop = 13'd0;
		vga_vsync = 1'b1;
	end
	else
	begin
		case (state)
			STATE_P://VSYNC Pulse Width - make vsync zero for 3200 times
			begin
				vga_vsync = 1'b0;
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 21'd3200)//if counter take value 3200, go to next state and do counter 0
				begin
					cycle_counter = 21'd0;
					state = STATE_Q;
				end
			end
			STATE_Q://Back Porch - make vsync 1 and count 46400 times in order to take rgb value from memory
			begin
				vga_vsync = 1'b1;
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 21'd46400)//if counter take value 46400, go to next state and do counter 0
				begin
					cycle_counter = 21'd0;
					state = STATE_R;
				end
			end
			STATE_R://Active Video Time - take row, define vertical pixel
			begin
				read_mem_vertical = 1'b1;
				vertical_pixel_addr = vertical_pixel_counter;
				case (row_loop)//repeat pixel 5 time row after go to next row
					row_loop_max:
					begin
						row_loop = 13'd0;
						vertical_pixel_counter = vertical_pixel_counter + 1;
					end
					default:
					begin
						row_loop = row_loop + 1;
					end
				endcase
				
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 21'd768000)//complete vertical-row pixel
				begin
					cycle_counter = 21'd0;
					state = STATE_S;
				end
			end
			STATE_S://Front Porch - count 1600 and make all counter 0
			begin
				cycle_counter = cycle_counter + 1;
				if(cycle_counter == 21'd1)//stop read from memory and init counters
				begin
					read_mem_vertical = 1'b0;
					row_loop = 13'b0;
					vertical_pixel_addr = 7'd0;
					vertical_pixel_counter = 7'd0;
				end
				else if(cycle_counter == 21'd16000)//complete the diplay do all counter zero
				begin
					cycle_counter = 21'd0;
					read_mem_vertical = 1'b0;
					row_loop = 13'b0;
					vertical_pixel_addr = 7'd0;
					vertical_pixel_counter = 7'd0;
					state = STATE_P;
				end
			end
		endcase
	end
end

endmodule
