module usb_annunciator (
	input	clk48,
	input	rst,

	// serial out
	input	inc,
	output	reg [7:0] dout,
	output  reg dout_v,

	// idiot lights
	input	tx_en,
	input	tx_j,
	input	tx_se0,
	input	usb_rst,
	input	transaction_active,
	input	[3:0] endpoint,
	input	direction_in,
	input	setup,
	input	data_strobe,
	input	success,

	input	[7:0] din,
	input	din_v);

// status
reg	[9:0] outptr = 0;
reg 	[7:0] status [0:1023]; // DP16KD
reg	inhibit = 0;
reg	[9:0] inptr = 10'd348;

always @(posedge clk48) begin
	if (rst) begin
		inhibit <= 0;
		outptr <= 0;
		dout_v <= 1'd1;
		inptr <= 10'd348;
	end else begin
		if (inhibit) begin
			if (!inc) begin
				inhibit <= 0;
			end
			dout_v <= 0;
		end else if (inc) begin
			if (tx_en && outptr == 10'd22)
				dout <= "1";
			else if (tx_j && outptr == 10'd54)
				dout <= "1";
			else if (tx_se0 && outptr == 10'd86)
				dout <= "1";
			else if (usb_rst && outptr == 10'd118)
				dout <= "1";
			else if (transaction_active && outptr == 10'd150)
				dout <= "1";
			else if (outptr == 10'd199) begin
				if (endpoint < 4'ha)
					dout <= endpoint + "0";
				else
					dout <= endpoint + "(";
			end
			else if (direction_in && outptr == 10'd214)
				dout <= "1";
			else if (setup && outptr == 10'd246)
				dout <= "1";
			else if (data_strobe && outptr == 10'd278)
				dout <= "1";
			else if (success && outptr == 10'd310)
				dout <= "1";
			else
				dout <= status[outptr];

			if (outptr == 10'd400) begin
				outptr <= 10'd4; // do it again w/o the erase screen
			end else begin
				outptr <= outptr + 10'd1;
				dout_v <= 1'b1;
				inhibit <= 1'b1;
			end
		end // inhibit

		if (din_v) begin
			if (inptr > 10'd400) begin
				inptr <= 10'd348;
			end else begin
				inptr <= inptr + 10'd1;
			end
			status[inptr] <= din;
		end // din_v
	end // rst
end // always

initial begin
`include "status.v"
end
endmodule
