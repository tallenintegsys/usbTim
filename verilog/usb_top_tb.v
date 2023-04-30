`include "usb_top.v"
module uart_top_tb;

reg	clk48;
reg	usr_btn;
wire	rst_n;
wire	rgb_led0_r;     // [0:0]LED,
wire	rgb_led0_g;     // [0:0]LED,
wire	rgb_led0_b;     // [0:0]LED,
wire	usb_d_p;
wire	usb_d_n;
wire	usb_pullup;
wire	gpio_10;

usb_top uut (
	clk48,
	usr_btn,        // SW0,
	rst_n,
	rgb_led0_r,     // [0:0]LED,
	rgb_led0_g,     // [0:0]LED,
	rgb_led0_b,     // [0:0]LED,
	usb_d_p,        // SITE "N1"
	usb_d_n,        // SITE "M2"
	usb_pullup,     // SITE "N2"
	gpio_10         // 0
);

initial begin
	$dumpfile("usb_top_tb.vcd");
	$dumpvars(0, uut);
	#0
	usr_btn = 1'b1;
	clk48 = 1'b0;
	#5
	usr_btn = 0;
	#5
	usr_btn = 1;
	#1100000
	$finish;
end


always begin
	#1
	clk48 = !clk48;
end
endmodule
