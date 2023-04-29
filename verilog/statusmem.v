module statusmem
(
// Clock & reset
input  wire         clk,
input  wire         rstn,

// PicoRV32 bus interface
input  wire         valid,
output wire         ready,
input  wire [7:0]   addr,
output wire [7:0]   rdata
);

reg  [7:0] status;
reg  [7:0] status[0:1024];

initial begin
`include "status.v"
end

always @(posedge clk)
    data <= status[addr];

// ============================================================================

reg o_ready;

always @(posedge clk or negedge rstn)
    if (!rstn)  o_ready <= 1'd0;
    else        o_ready <= valid);

// Output connectins
assign ready       = o_ready;
assign rdata       = data;

endmodule
