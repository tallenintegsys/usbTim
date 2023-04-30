`include "uart_tx.v"
`include "usb_annunciator.v"
`include "usb.v"
`timescale 1ns / 1ps

module usb_top (
	input		clk48,
	input		usr_btn,	// SW0,
	output 		rst_n,		// "reboot"
	output 		rgb_led0_r,	// [0:0]LED,
	output 		rgb_led0_g,	// [0:0]LED,
	output		rgb_led0_b,	// [0:0]LED,
	inout		gpio_5,		// usb_d_p
	inout		gpio_6,		// usb_d_n
	output reg	usb_pullup,	// SITE "N2"
	output 		gpio_10		// serial out
);

wire	usb_tx_se0, usb_tx_j, usb_tx_en;
wire 	rx_j, usb_rst, tx_se0, transaction_active, direction_in, setup, data_strobe, success;
reg	[3:0] step = 0;
reg	[7:0] din;
wire	[7:0] dout;
reg	din_valid;
wire	rst;
reg	por_n = 0;

// status
reg	[9:0] statusptr = 0;
reg 	[7:0] status [0:1023]; // DP16KD
reg	[7:0] uart_d;
wire	uart_dv;
wire	uart_sout;
wire	uart_busy;
wire	uart_done;
reg	[3:0] endpoint;

initial begin
`include "status.v"
end

assign gpio_5 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_6 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : !usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_10 = uart_sout;
assign rst = !usr_btn | !por_n;

usb usb0 (
	.rst_n(1'b1),
	.clk_48(clk48),
	.rx_j(rx_j),
	.rx_se0(!gpio_5 && !gpio_6),
	.tx_j(usb_tx_j),
	.tx_en(usb_tx_en),
	.tx_se0(usb_tx_se0),
	.usb_address(7'h00),
	.usb_rst(usb_rst),
	.transaction_active(transaction_active),
	.endpoint(endpoint),
	.direction_in(direction_in),
	.setup(setup),
	//input data_toggle,
	//input[1:0] handshake,
	.data_out(dout),
	.data_in(din),
	.data_in_valid(din_valid),
	.data_strobe(data_strobe),
	.success(success)
);

usb_annunciator usb_annunciator0 (
	.clk48(clk48),
	.rst(rst),
	.inc(uart_done),
	.q(uart_d),
	.dv(uart_dv),

	.tx_en(usb_tx_en),
	.tx_j(usb_tx_j),
	.tx_se0(tx_se0),
	.usb_rst(usb_rst),
	.transaction_active(transaction_active),
	.endpoint(endpoint),
	.direction_in(direction_in),
	.setup(setup),
	.data_strobe(data_strobe),
	.success(success));

uart_tx #(.CLKS_PER_BIT(48000000/115200)) uart_tx0 (
	.i_Clock(clk48),
	.i_TX_DV(uart_dv),
	.i_TX_Byte(uart_d),
	.o_TX_Active(uart_busy),
	.o_TX_Serial(uart_sout),
	.o_TX_Done(uart_done)
);

// Reset logic on button press.
// this will enter the bootloader
reg [15:0] count = 16'hffff;
reg reset_sr = 1'b1;
reg [23:0] rcount = 24'hffffff;
always @(posedge clk48) begin
	if (count)
		count <= count - 16'd1;
	else
		por_n <= 1;

	if (!usr_btn)
		rcount <= rcount - 24'b1;
	else
		rcount <= 24'hffffff;

	if (rcount == 24'h000000)
		reset_sr <= {usr_btn};
end
assign rst_n = reset_sr;

endmodule
