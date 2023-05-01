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
	output 		gpio_10		// serial out
);

wire	usb_tx_se0, usb_tx_j, usb_tx_en;
wire 	rx_j, usb_rst, transaction_active, direction_in, setup, success, usb_dout_v;
wire	[7:0] usb_dout;
reg	[3:0] step = 0;
reg	[7:0] usb_din = 8'h00;
reg	usb_din_v = 0;
wire	[7:0] uart_d;
wire	uart_d_v;
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
wire	[3:0] endpoint;

initial begin
`include "status.v"
end

assign gpio_5 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_6 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : !usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_10 = uart_sout;
assign rst = !usr_btn | !por_n;

usb usb0 (
	.rst_n(!rst),
	.clk_48(clk48),
	.rx_j(gpio_5),
	.rx_se0(!gpio_5 && !gpio_6),
	.tx_j(usb_tx_j),
	.tx_en(usb_tx_en),
	.tx_se0(usb_tx_se0),
	.usb_address(7'h00),
	.usb_rst(usb_rst),
	.transaction_active(transaction_active),
	.endpoint(endpoint),		// output
	.direction_in(direction_in),	// output
	.setup(setup),			// output
	.data_toggle(1'd0),		// input
	.handshake(2'b00),		// input [1:0]
	.data_out(usb_dout),		// output [7:0]
	.data_in(usb_din),		// input [7:0]
	.data_in_valid(usb_din_v),	// input
	.data_strobe(usb_dout_v),	// output
	.success(success));		// output

usb_annunciator usb_annunciator0 (
	.clk48(clk48),
	.rst(rst),

	.inc(uart_done),
	.dout(uart_d),
	.dout_v(uart_d_v),

	.tx_en(usb_tx_en),
	.tx_j(usb_tx_j),
	.tx_se0(usb_tx_se0),
	.usb_rst(usb_rst),
	.transaction_active(transaction_active),
	.endpoint(endpoint),
	.direction_in(direction_in),
	.setup(setup),
	.data_strobe(usb_dout_v),
	.success(success),
	.din(usb_dout),
        .din_v(usb_dout_v));

uart_tx #(.CLKS_PER_BIT(48000000/115200)) uart_tx0 (
	.i_Clock(clk48),
	.i_TX_DV(uart_d_v),
	.i_TX_Byte(uart_d),
	.o_TX_Active(uart_busy),
	.o_TX_Serial(uart_sout),
	.o_TX_Done(uart_done));

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
