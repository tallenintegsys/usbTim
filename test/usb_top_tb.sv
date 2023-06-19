`include "usb_top.v"
module usb_top_tb;


usb_top uut (
	.clk48,		// input		clk48,
	.usr_btn,	// input		usr_btn,	// SW0,
	.rst_n,		// output		rst_n,		// "reboot"
	.rgb_led0_r,	// output		rgb_led0_r,	// [0:0]LED,
	.rgb_led_g,	// output		rgb_led0_g,	// [0:0]LED,
	.rgb_led0_b,	// output		rgb_led0_b,	// [0:0]LED,
	.gpio_5,	// inout		gpio_5,		// usb_d_p
	.gpio_6,	// inout		gpio_6,		// usb_d_n
	.gpio_10,	// output		gpio_10,	// serial out
	.gpio_a0	// output		gpio_a0,
);

initial begin
	$dumpfile("usb_top.vcd");
	$dumpvars(0, uut);
	//$dumpoff;
	#0
	usr_btn = 1;
	gpio_5 = 0;
	gpio_6 = 1;
	#1
	usr_btn = 0;
	#10

	i_TX_DV <= 1'b0;
	#1000000
	i_TX_Byte <= "B";
	i_TX_DV <= 1'b1;
	#10
	i_TX_DV <= 1'b0;
	#1000000
	$finish;
end

always begin
	#1
	clk48 = !clk_48;
end
endmodule
