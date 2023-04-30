`include "usb_annunciator.v"
module usb_annunciator_tb ();

reg	clk48;
reg	rst;
reg	inc;
wire	[7:0] q;
reg	[3:0] endpoint;

usb_annunciator uut (
	clk48,
	rst,
	inc,
	q,
	dv,

	tx_en,
	tx_j,
	tx_se0,
	usb_rst,
	transaction_active,
	endpoint,
	direction_in,
	setup,
	data_strobe,
	success);

initial begin
	$dumpfile("usb_annunciator_tb.vcd");
	$dumpvars(0, uut);
	#0
	clk48 = 0;
	rst = 1'b1;
	inc = 0;
	#1
	rst = 1'b0;
	#100000
	$finish;
end


always begin
	#1
	clk48 = !clk48;
end
always begin
	#100
	inc = !inc;
end
endmodule
