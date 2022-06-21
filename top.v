`default_nettype none

module top (
    input clk48,

    output	rgb_led0_r,
    output	rgb_led0_g,
    output	rgb_led0_b,

    inout	gpio_0, // usb_dp
    inout 	gpio_1, // usb_dn
	input	gpio_5, // my button

    output	rst_n,
    input	usr_btn
);

    wire usb_tx_se0, usb_tx_j, usb_tx_en;
	wire data_in, data_in_valid;
	wire usb_rst_n;
	reg [6:0] usb_address = 6'b101010;
    usb usb0(
		.rst_n(usb_rst_n),
		.clk_48(clk48),
        .rx_j(gpio_0),
        .rx_se0(!gpio_0 && !gpio_1),
		.usb_address(usb_address),

        .tx_se0(usb_tx_se0),
        .tx_j(usb_tx_j),
        .tx_en(usb_tx_en),
	
		.data_in(data_in),
		.data_in_valid(data_in_valid)
		);

    assign gpio_0 = usb_tx_en? (usb_tx_se0? 1'b0: usb_tx_j): 1'bz;
    assign gpio_1 = usb_tx_en? (usb_tx_se0? 1'b0: !usb_tx_j): 1'bz;
	assign usb_rst_n = gpio_5;


	reg [4*7:0] str = "Tim\0";

    // Create a 27 bit register
    reg [26:0] counter = 0;

    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        counter <= counter + 1;
    end

    // Output inverted values of counter onto LEDs
    assign rgb_led0_r = ~counter[24];
    assign rgb_led0_b = ~gpio_5; //~counter[26];
	
	always @(posedge counter[23]) begin
		if (counter[24]) begin
			data_in <= str[4*7:3*7+1];
			data_in_valid <= 1'b1;
			rgb_led0_g = 1'b0; //on
		end else begin
			data_in_valid <= 1'b0;
			rgb_led0_g = 1'b1; //off
		end
	end

    // Reset logic on button press.
    // this will enter the bootloader
    reg reset_sr = 1'b1;
    always @(posedge clk48) begin
        reset_sr <= {usr_btn};
    end
    assign rst_n = reset_sr;


endmodule
