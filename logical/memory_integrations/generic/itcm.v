
module itcm #(parameter ADDR_WIDTH=16)(
    input  wire         CLK,

    input  wire         ITCMCS,       // Chip select/RAM enable
    input  wire [23:3]  ITCMADDR,     // Address
    input  wire         ITCMWR,       // Write/not read
    input  wire [ 7:0]  ITCMBYTEWR,   // Byte strobes
    input  wire [63:0]  ITCMWDATA,    // Write data
    output wire [63:0]  ITCMRDATA    // Read data

);

spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[7:0]),
    .din(ITCMWDATA[7:0]),
    .we(ITCMWR&ITCMBYTEWR[0])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_1 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[15:8]),
    .din(ITCMWDATA[15:8]),
    .we(ITCMWR&ITCMBYTEWR[1])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_2 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[23:16]),
    .din(ITCMWDATA[23:16]),
    .we(ITCMWR&ITCMBYTEWR[2])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_3 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[31:24]),
    .din(ITCMWDATA[31:24]),
    .we(ITCMWR&ITCMBYTEWR[3])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_4 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[39:32]),
    .din(ITCMWDATA[39:32]),
    .we(ITCMWR&ITCMBYTEWR[4])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_5 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[47:40]),
    .din(ITCMWDATA[47:40]),
    .we(ITCMWR&ITCMBYTEWR[5])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_6 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[55:48]),
    .din(ITCMWDATA[55:48]),
    .we(ITCMWR&ITCMBYTEWR[6])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_itcm_ram_7 (
    .clk(CLK),
    .cs(ITCMCS),
    .addr(ITCMADDR[ADDR_WIDTH:3]),
    .dout(ITCMRDATA[63:56]),
    .din(ITCMWDATA[63:56]),
    .we(ITCMWR&ITCMBYTEWR[7])
);


endmodule
