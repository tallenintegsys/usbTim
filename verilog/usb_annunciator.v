module usb_annunciator (
	input	clk48,
	input	rst,

	// serial out
	input	      inc,
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

localparam DOUT_IDLE 	= 	2'd0;
localparam DOUT_BSY 	= 	2'd1;
localparam DOUT_DONE 	=	2'd2;

localparam DIN_IDLE 	=	2'd0;
localparam DIN_HNIBBLE 	=	2'd1;
localparam DIN_LNIBBLE 	=	2'd2;
localparam DIN_DONE  	=	2'd3;

// status
reg [7:0] status [0:1023];	// DP16KD
reg	[1:0] dout_state = 	DOUT_IDLE; 	// inhibit dout
reg	[9:0] outptr     = 	10'd0;
reg	[9:0] inptr      =	10'd348;
reg	[3:0] nibble     =	4'h0;
reg	[1:0] din_state  =	DIN_IDLE;
reg	rst_state        =	1'd0;

always @(posedge clk48) begin
	if (rst) begin
		dout_state <= DOUT_IDLE;
		din_state <= DIN_IDLE;
		outptr <= 10'd348;
		dout_v <= 1'd1;
		inptr <= 10'd348;
		rst_state <= 1'd1;
	end else begin
		if (rst_state) begin
			outptr <= outptr + 10'd1;
			status[outptr] <= " ";
			if (outptr == 10'h3ff)
				rst_state <= 1'b0;
		end // if (rst_state)

		case (dout_state)
			DOUT_IDLE: begin
				if (inc)
					dout_state <= DOUT_BSY;
			end
			DOUT_BSY: begin
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
						dout <= {endpoint, 4'd0} + "0";
					else
						dout <= {endpoint, 4'd0} + "(";
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

				if (outptr == 10'd500) begin // we're at the bottom of the screen
					outptr <= 10'd4; // back to the top w/o the erase screen
				end else begin
					outptr <= outptr + 10'd1;
				end
				dout_state <= DOUT_DONE;
			end // DOUT_BSY
			DOUT_DONE: begin
				dout_v <= 1'b1;
				if (!inc)
					dout_state <= DOUT_IDLE;
			end // DOUT_DONE
			default:
				dout_state <= DOUT_IDLE;
		endcase

		case (din_state)
			DIN_IDLE: begin
				if (din_v)
					din_state <= DIN_HNIBBLE;
			end
			DIN_HNIBBLE: begin
				nibble <= din[7:4];
				if (nibble < 4'ha) begin
					status[inptr] <= {4'd0, nibble} + "0";
				end else begin
					status[inptr] <= {4'd0, nibble} + "(";
				end
				din_state <= DIN_LNIBBLE;
				inptr <= inptr + 10'd1;
			end
			DIN_LNIBBLE: begin
				nibble <= din[3:0];
				if (nibble < 4'ha) begin
					status[inptr] <= {4'd0, nibble} + "0";
				end else begin
					status[inptr] <= {4'd0, nibble} + "(";
				end
				din_state <= DIN_DONE;
				inptr <= inptr + 10'd1;
			end
			DIN_DONE: begin
				if (inptr == 10'd500)
					inptr <= 10'd348;
				if (!din_v)
					din_state <= DIN_IDLE;
			end
		endcase
	end // rst
end // always

initial begin
`include "status.v"
end
endmodule
