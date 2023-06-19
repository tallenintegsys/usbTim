`timescale 1ns / 1ps

module usb_top (
	input		clk48,
	input		usr_btn,	// SW0,
	output		rst_n,		// "reboot"
	output		rgb_led0_r,	// [0:0]LED,
	output		rgb_led0_g,	// [0:0]LED,
	output		rgb_led0_b,	// [0:0]LED,
	inout		gpio_5,		// usb_d_p
	inout		gpio_6,		// usb_d_n
	output		gpio_10,	// serial out
	output		gpio_a0,
);

wire	usb_tx_se0, usb_tx_j, usb_tx_en;
wire	rx_j, usb_rst, transaction_active, direction_in, setup, success, data_strobe;
wire	[7:0] usb_dout;
reg	[3:0] step = 0;
reg	[7:0] usb_din = 8'h00;
reg	usb_din_v = 0;
wire	[7:0] uart_d;
wire	uart_d_v;
wire	rst;
reg	por_n = 0;

// status
reg	[7:0] uart_d;
wire	uart_dv;
wire	uart_sout;
wire	uart_busy;
wire	uart_done;
wire	[3:0] endpoint;
reg	a0;

assign gpio_5 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_6 = usb_tx_en ? (usb_tx_se0 ? 1'b0 : !usb_tx_j) : 1'bz;	// go hi-z if we're not tx'ing
assign gpio_10 = uart_sout;
assign rst = !usr_btn | !por_n;
assign gpio_a0 = a0;

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
	.data_strobe(data_strobe),	// output
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
	.data_strobe(data_strobe),
	.success(success),
	.din(usb_dout),
	.din_v(data_strobe));

uart_tx #(.CLKS_PER_BIT(48000000/115200)) uart_tx0 (
	.i_Clock(clk48),
	.i_TX_DV(uart_d_v),
	.i_TX_Byte(uart_d),
	.o_TX_Active(uart_busy),
	.o_TX_Serial(uart_sout),
	.o_TX_Done(uart_done));

logic	[8*8-1:0] ep_data [15:0];
reg	[6:0] ep_ptrs [15:0];
reg	[6:0] ep_ptr = 0;
reg	[3:0] ep = 0;
reg	[2:0] state = 0;
always @(posedge clk48) begin
	case (state)
		0: begin
			if (data_strobe) begin
				ep <= endpoint;
				state <= 1;
			end
		end
		1: begin
			ep_ptr <= ep_ptrs[ep];
			state <= 2;
		end
		2: begin
			ep_data[ep] <= {ep_data[ep][7*8-1:0], usb_dout};
			state <= 0;
		end
	endcase
	if (ep_data[0] == 16*8'h8006000100004000) a0 <= 1;
	else a0 <= 0;
end //always

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
end //always
assign rst_n = reset_sr;

endmodule
