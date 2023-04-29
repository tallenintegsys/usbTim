module usb_annunciator (
	input tx_en,
	input tx_j,
	input tx_se0,
	input usb_rst,
	input transaction_active,
	input [3:0] endpoint,
	input direction_in,
	input setup,
	input data_strobe,
	input success);

reg	[7:0] buffer [0:
reg 	[7:0] hello [0:7]; // = "Ready\n\000";
reg	[2:0] helloptr = 0;

module usb(
    input rst_n,
    input clk_48,

    input rx_j,
    input rx_se0,

    output tx_en,
    output tx_j,
    output tx_se0,

    input[6:0] usb_address,

    output usb_rst,

    output reg transaction_active,
    output reg[3:0] endpoint,
    output reg direction_in,
    output reg setup,
    input data_toggle,

    input[1:0] handshake,
    
    output reg[7:0] data_out,
    input[7:0] data_in,
    input data_in_valid,
    output reg data_strobe,
    output reg success
    );
