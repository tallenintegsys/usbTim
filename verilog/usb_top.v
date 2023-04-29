`include "usb.v"
`include "uart_tx.v"
`timescale 1ns / 1ps

module usb_top (
	input		clk48,
	input		usr_btn,	// SW0,
	output 		rst_n,
	output 		rgb_led0_r,	// [0:0]LED,
	output 		rgb_led0_g,	// [0:0]LED,
	output		rgb_led0_b,	// [0:0]LED,
	inout		gpio_5,		// usb_d_p
	inout		gpio_6,		// usb_d_n
	output reg	usb_pullup,	// SITE "N2"
	output 		gpio_10		// 0
);

wire	usb_tx_se0, usb_tx_j, usb_tx_en;
reg	[3:0] step = 0;
reg	[7:0] din;
wire	[7:0] dout;
reg	din_valid;

// status
reg	statusdone = 0;
reg	[7:0] statusptr = 22;
reg 	[7:0] status [30:0];
reg	[7:0] uart_d;
reg	uart_dv = 0;
wire	uart_sout;
wire	uart_busy;
wire	uart_done;

initial begin
`include "status.v"
end

assign gpio_5 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_6 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : !usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
//assign rgb_led0_r = usb_tx_en;
assign gpio_10 = uart_sout;

/*
usb usb0 (
	.rst_n(1'b1),
	.clk_48(clk48),
	.rx_j(usb_d_p),
	.rx_se0(!usb_d_p && !usb_d_n),
	.tx_j(usb_tx_j),
	.tx_en(usb_tx_en),
	.tx_se0(usb_tx_se0),
	.usb_address(7'h00),
	//output usb_rst,
	//output reg transaction_active,
	//output reg[3:0] endpoint,
	//output reg direction_in,
	.setup(rgb_led0_b),
	//input data_toggle,
	//input[1:0] handshake,
	.data_out(dout),
	.data_in(din),
	.data_in_valid(din_valid),
	//output reg data_strobe,
	.success(rgb_led0_g)
);
*/

uart_tx #(.CLKS_PER_BIT(48000000/115200)) uart_tx0 (
	.i_Clock(clk48),
	.i_TX_DV(uart_dv),
	.i_TX_Byte(uart_d),
	.o_TX_Active(uart_busy),
	.o_TX_Serial(uart_sout),
	.o_TX_Done(uart_done)
);

always @(posedge clk48) begin
	if (uart_dv) begin
		uart_dv <= 1'b0;
	end else if (!uart_busy) begin
		if (!statusdone) begin
			uart_d <= status[statusptr];
			statusptr <= statusptr - 1;
			uart_dv <= 1'b1;
			if (uart_d == "\777") begin
				statusdone <= 1'b1;
			end
		end else begin
			uart_d <= dout;
			uart_dv <= 1'b1;
		end
	end
end // always

// Reset logic on button press.
// this will enter the bootloader
reg reset_sr = 1'b1;
always @(posedge clk48) begin
	reset_sr <= {usr_btn};
end
assign rst_n = reset_sr;

endmodule