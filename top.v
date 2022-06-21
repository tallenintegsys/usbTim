`default_nettype none

module top (
    input clk48,

    output  rgb_led0_r,
    output  rgb_led0_g,
    output  rgb_led0_b,

    inout   gpio_0, // usb_dp
    inout   gpio_1, // usb_dn
    input   gpio_5, // my button

    output  rst_n,
    input   usr_btn
);

    wire usb_tx_se0, usb_tx_j, usb_tx_en;
    wire data_in, data_in_valid;
    wire usb_rst_n;
    reg [6:0] usb_address = 6'b1110000;
    wire strobe;
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
        .data_in_valid(data_in_valid),
        .data_strobe(strobe)
        );

    assign gpio_0 = usb_tx_en? (usb_tx_se0? 1'b0: usb_tx_j): 1'bz;
    assign gpio_1 = usb_tx_en? (usb_tx_se0? 1'b0: !usb_tx_j): 1'bz;
    assign usb_rst_n = gpio_5;

    reg [2:0] state = 3'b0;

    // Create a 27 bit register
    reg [26:0] counter = 0;

    // Every positive edge increment register by 1
    always @(posedge clk48) begin
        counter <= counter + 1;
    end

    // Output inverted values of counter onto LEDs
    assign rgb_led0_r = ~counter[24];
    assign rgb_led0_b = ~gpio_5; //~counter[26];

    always @(posedge clk48) begin
        case (state)
            0: begin
                data_in <= 8'h01;
                data_in_valid <= 1'b1;
                state <= 1;
            end
            1: begin
                if (strobe) begin
                    data_in_valid <= 1'b0;
                    state <=2;
                end
            end
            2: begin
                data_in <= 8'h02;
                data_in_valid <= 1'b1;
                state <= 1;
            end
            3: begin
                if (strobe) begin
                    data_in_valid <= 1'b0;
                    state <=2;
                end
            end
            4: begin
                data_in <= 8'h03;
                data_in_valid <= 1'b1;
                state <= 1;
            end
            5: begin
                if (strobe) begin
                    data_in_valid <= 1'b0;
                    state <=2;
                end
            end
            default:
                state <= 0;
        endcase
    end

    // Reset logic on button press.
    // this will enter the bootloader
    reg reset_sr = 1'b1;
    always @(posedge clk48) begin
        reset_sr <= {usr_btn};
    end
    assign rst_n = reset_sr;


endmodule
