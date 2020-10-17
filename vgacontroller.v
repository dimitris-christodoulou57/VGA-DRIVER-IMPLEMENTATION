`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dimitris Christodoulou
// 
// Create Date:    03:30:06 11/20/2018 
// Design Name: 
// Module Name:    vgacontroller 
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
module vgacontroller(resetbutton, clk, VGA_RED, VGA_GREEN, VGA_BLUE, VGA_HSYNC, VGA_VSYNC);
input resetbutton, clk;
output VGA_RED, VGA_GREEN, VGA_BLUE;
output VGA_HSYNC, VGA_VSYNC;		

wire [6:0] horizontal_memory_addr;
wire [6:0] vertical_memory_addr;
wire read_mem;
wire read_mem_vertical;


mem mem_inst(.RESET(resetbutton), .CLK(clk), .ADDR({vertical_memory_addr, horizontal_memory_addr}), .read_mem(read_mem), .read_mem_vertical(read_mem_vertical), .DO_RED(VGA_RED), .DO_GREEN(VGA_GREEN), .DO_BLUE(VGA_BLUE));				

horizondal_sync horizontal_sync_inst(.reset(resetbutton), .clk(clk), .pixel_addr(horizontal_memory_addr), .vga_hsync(VGA_HSYNC), .read_mem(read_mem));

vertical_sync vertical_sync_inst(.reset(resetbutton), .clk(clk), .vertical_pixel_addr(vertical_memory_addr), .vga_vsync(VGA_VSYNC), .read_mem_vertical(read_mem_vertical));

endmodule
