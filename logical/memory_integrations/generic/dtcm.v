
module dtcm #(parameter ADDR_WIDTH=16) (
    input  wire         CLK,

    input  wire         D0TCMCS,    // D0 TCM Chip Select
    input  wire [22:3]  D0TCMADDR,  // D0 TCM Address
    input  wire         D0TCMWR,    // D0 TCM Write Enable
    input  wire [ 3:0]  D0TCMBYTEWR,// D0 TCM Byte Write Enable
    input  wire [31:0]  D0TCMWDATA, // D0 TCM Write Data
    output wire [31:0]  D0TCMRDATA, // D0 TCM Read Data

    input  wire         D1TCMCS,    // D1 TCM Chip Select
    input  wire [22:3]  D1TCMADDR,  // D1 TCM Address
    input  wire         D1TCMWR,    // D1 TCM Write Enable
    input  wire [ 3:0]  D1TCMBYTEWR,// D1 TCM Byte Write Enable
    input  wire [31:0]  D1TCMWDATA, // D1 TCM Write Data
    output wire [31:0]  D1TCMRDATA  // D1 TCM Read Data
);

spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm0_ram_0 (
    .clk(CLK),
    .cs(D0TCMCS),
    .addr(D0TCMADDR[ADDR_WIDTH:3]),
    .dout(D0TCMRDATA[7:0]),
    .din(D0TCMWDATA[7:0]),
    .we(D0TCMWR&D0TCMBYTEWR[0])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm0_ram_1 (
    .clk(CLK),
    .cs(D0TCMCS),
    .addr(D0TCMADDR[ADDR_WIDTH:3]),
    .dout(D0TCMRDATA[15:8]),
    .din(D0TCMWDATA[15:8]),
    .we(D0TCMWR&D0TCMBYTEWR[1])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm0_ram_2 (
    .clk(CLK),
    .cs(D0TCMCS),
    .addr(D0TCMADDR[ADDR_WIDTH:3]),
    .dout(D0TCMRDATA[23:16]),
    .din(D0TCMWDATA[23:16]),
    .we(D0TCMWR&D0TCMBYTEWR[2])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm0_ram_3 (
    .clk(CLK),
    .cs(D0TCMCS),
    .addr(D0TCMADDR[ADDR_WIDTH:3]),
    .dout(D0TCMRDATA[31:24]),
    .din(D0TCMWDATA[31:24]),
    .we(D0TCMWR&D0TCMBYTEWR[3])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm1_ram_0 (
    .clk(CLK),
    .cs(D1TCMCS),
    .addr(D1TCMADDR[ADDR_WIDTH:3]),
    .dout(D1TCMRDATA[7:0]),
    .din(D1TCMWDATA[7:0]),
    .we(D1TCMWR&D1TCMBYTEWR[0])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm1_ram_1 (
    .clk(CLK),
    .cs(D1TCMCS),
    .addr(D1TCMADDR[ADDR_WIDTH:3]),
    .dout(D1TCMRDATA[15:8]),
    .din(D1TCMWDATA[15:8]),
    .we(D1TCMWR&D1TCMBYTEWR[1])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm1_ram_2 (
    .clk(CLK),
    .cs(D1TCMCS),
    .addr(D1TCMADDR[ADDR_WIDTH:3]),
    .dout(D1TCMRDATA[23:16]),
    .din(D1TCMWDATA[23:16]),
    .we(D1TCMWR&D1TCMBYTEWR[2])
);
spram #(
    .ADDR_WIDTH(ADDR_WIDTH-2),
    .DATA_WIDTH(8)
) u_dtcm1_ram_3 (
    .clk(CLK),
    .cs(D1TCMCS),
    .addr(D1TCMADDR[ADDR_WIDTH:3]),
    .dout(D1TCMRDATA[31:24]),
    .din(D1TCMWDATA[31:24]),
    .we(D1TCMWR&D1TCMBYTEWR[3])
);


endmodule
