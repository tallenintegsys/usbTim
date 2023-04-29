`include "uart_tx.v"
module uart_tx_tb;

reg	i_Clock = 0;
reg	i_TX_DV;
reg	[7:0]i_TX_Byte;
wire 	o_TX_Active = 0;
wire 	o_TX_Serial;
wire 	o_TX_Done;

uart_tx #(.CLKS_PER_BIT(48000000/115200)) uut (
	.i_Clock,
	.i_TX_DV,
	.i_TX_Byte,
	.o_TX_Active,
	.o_TX_Serial,
	.o_TX_Done);

initial begin
	$dumpfile("uart_tx.vcd");
	$dumpvars(0, uut);
	//$dumpoff;
	#0
	i_TX_Byte <= "A";
	i_TX_DV <= 1'b1;
	#10
	i_TX_DV <= 1'b0;
	#1000000
	i_TX_Byte <= "B";
	i_TX_DV <= 1'b1;
	#10
	i_TX_DV <= 1'b0;
	#1000000
	$finish;
end

always begin
	#1
	i_Clock = !i_Clock;
end
endmodule
