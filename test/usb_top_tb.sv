module usb_top_tb;

reg	clk48;
reg	usr_btn;
wire	rst_n;
wire	rgb_led0_r;     // [0:0]LED,
wire	rgb_led0_g;     // [0:0]LED,
wire	rgb_led0_b;     // [0:0]LED,
wire	gpio_5;
wire	gpio_6;
wire     gpio_10;
wire    gpio_a0;

usb_top uut (
	.clk48,		// input		clk48,
	.usr_btn,	// input		usr_btn,	// SW0,
	.rst_n,		// output		rst_n,		// "reboot"
	.rgb_led0_r,	// output		rgb_led0_r,	// [0:0]LED,
	.rgb_led0_g,	// output		rgb_led0_g,	// [0:0]LED,
	.rgb_led0_b,	// output		rgb_led0_b,	// [0:0]LED,
	.gpio_5,	// inout		gpio_5,		// usb_d_p
	.gpio_6,	// inout		gpio_6,		// usb_d_n
	.gpio_10,	// output		gpio_10,	// serial out
	.gpio_a0	// output		gpio_a0,
);

integer file; // file handler
integer status; // file handler
reg     [15:0] r16;
`define NULL 0    

assign gpio_5 = r16[8];
assign gpio_6 = r16[9];

initial begin
	$dumpfile("usb_top_tb.vcd");
	$dumpvars(0, uut);
	file = $fopen("test/raw", "rb");
	if (file == `NULL) begin
		$display("data_file handle was NULL");
		$finish;
	end
	#0
	usr_btn = 1'b1;
	clk48 = 1'b0;
	#5
	usr_btn = 0;
	while (!$feof(file)) begin
		#5
		status = $fread(r16, file);
	//	$display("%x\n", r16);
	//	if (r16[9]) $finish;
//		gpio_5 = r16[8];
//		gpio_6 = r16[9];
	end
	#5
	usr_btn = 1;
	#100
	$finish;
end


always begin
	#1
	clk48 = !clk48;
end
endmodule
