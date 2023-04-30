module usb_annunciator (
	input	clk48,
	input	rst,
	input	inc,
	output	reg [7:0] q,
	output reg dv,

	input	tx_en,
	input	tx_j,
	input	tx_se0,
	input	usb_rst,
	input	transaction_active,
	input	[3:0] endpoint,
	input	direction_in,
	input	setup,
	input	data_strobe,
	input	success);

// status
reg	[9:0] ptr = 0;
reg 	[7:0] status [0:1023]; // DP16KD
reg	inhibit = 0;

always @(posedge clk48) begin
	if (rst) begin
		inhibit <= 0;
		ptr <= 0;
		dv <= 1;
	end else begin
		if (inhibit) begin
			if (!inc) begin
				inhibit <= 0;
			end
			dv <= 0;
		end else if (inc) begin
			inhibit <= 1'b1;
			q <= status[ptr];
			dv <= 1'b1;
			ptr <= ptr + 10'd1;
			if (q == "\014") begin
				ptr <= 10'd4; // do it again w/o the erase screen
			end
		end
	end //reset
end // always

initial begin
`include "status.v"
end
endmodule
