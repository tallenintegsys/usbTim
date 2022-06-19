`default_nettype none

module top (
    input clk48,

    output	rgb_led0_r,
    output	rgb_led0_g,
    output	rgb_led0_b,

    inout	gpio_0, // usb_dp
    inout 	gpio_1, // usb_dn

    output	rst_n,
    input	usr_btn
);


    wire usb_tx_se0, usb_tx_j, usb_tx_en;
    usb usb0(
		.clk_48(clk48),
        .rx_j(gpio_0),
        .rx_se0(!gpio_0 && !gpio_1),

        .tx_se0(usb_tx_se0),
        .tx_j(usb_tx_j),
        .tx_en(usb_tx_en));

    assign gpio_0 = usb_tx_en? (usb_tx_se0? 1'b0: usb_tx_j): 1'bz;
    assign gpio_1 = usb_tx_en? (usb_tx_se0? 1'b0: !usb_tx_j): 1'bz;


    // Create a 27 bit register
    reg [26:0] counter = 0;

    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        counter <= counter + 1;
    end

    // Output inverted values of counter onto LEDs
    assign rgb_led0_r = ~counter[24];
    assign rgb_led0_g = 1'b1; //~counter[25];
    assign rgb_led0_b = 1'b1; //~counter[26];

    // Reset logic on button press.
    // this will enter the bootloader
    reg reset_sr = 1'b1;
    always @(posedge clk48) begin
        reset_sr <= {usr_btn};
    end
    assign rst_n = reset_sr;


endmodule
