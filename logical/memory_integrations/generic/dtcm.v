
module dtcm (
    input  wire         CLK,

    input  wire         D0TCMCS,    // D0 TCM Chip Select
    input  wire [23:3]  D0TCMADDR,  // D0 TCM Address
    input  wire         D0TCMWR,    // D0 TCM Write Enable
    input  wire [ 3:0]  D0TCMBYTEWR,// D0 TCM Byte Write Enable
    input  wire [31:0]  D0TCMWDATA, // D0 TCM Write Data
    output wire [31:0]  D0TCMRDATA, // D0 TCM Read Data

    input  wire         D1TCMCS,    // D1 TCM Chip Select
    input  wire [23:3]  D1TCMADDR,  // D1 TCM Address
    input  wire         D1TCMWR,    // D1 TCM Write Enable
    input  wire [ 3:0]  D1TCMBYTEWR,// D1 TCM Byte Write Enable
    input  wire [31:0]  D1TCMWDATA, // D1 TCM Write Data
    output wire [31:0]  D1TCMRDATA  // D1 TCM Read Data
);

bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm0_ram_0 (
    .clk(CLK),
    .addr_i(D0TCMADDR),
    .rd_o(D0TCMRDATA[7:0]),
    .wd_i(D0TCMWDATA[7:0]),
    .cs_i(D0TCMCS),
    .we_i(D0TCMWR&D0TCMBYTEWR[0])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm0_ram_1 (
    .clk(CLK),
    .addr_i(D0TCMADDR),
    .rd_o(D0TCMRDATA[15:8]),
    .wd_i(D0TCMWDATA[15:8]),
    .cs_i(D0TCMCS),
    .we_i(D0TCMWR&D0TCMBYTEWR[1])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm0_ram_2 (
    .clk(CLK),
    .addr_i(D0TCMADDR),
    .rd_o(D0TCMRDATA[23:16]),
    .wd_i(D0TCMWDATA[23:16]),
    .cs_i(D0TCMCS),
    .we_i(D0TCMWR&D0TCMBYTEWR[2])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm0_ram_3 (
    .clk(CLK),
    .addr_i(D0TCMADDR),
    .rd_o(D0TCMRDATA[31:24]),
    .wd_i(D0TCMWDATA[31:24]),
    .cs_i(D0TCMCS),
    .we_i(D0TCMWR&D0TCMBYTEWR[3])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm1_ram_0 (
    .clk(CLK),
    .addr_i(D1TCMADDR),
    .rd_o(D1TCMRDATA[7:0]),
    .wd_i(D1TCMWDATA[7:0]),
    .cs_i(D1TCMCS),
    .we_i(D1TCMWR&D1TCMBYTEWR[0])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm1_ram_1 (
    .clk(CLK),
    .addr_i(D1TCMADDR),
    .rd_o(D1TCMRDATA[15:8]),
    .wd_i(D1TCMWDATA[15:8]),
    .cs_i(D1TCMCS),
    .we_i(D1TCMWR&D1TCMBYTEWR[1])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm1_ram_2 (
    .clk(CLK),
    .addr_i(D1TCMADDR),
    .rd_o(D1TCMRDATA[23:16]),
    .wd_i(D1TCMWDATA[23:16]),
    .cs_i(D1TCMCS),
    .we_i(D1TCMWR&D1TCMBYTEWR[2])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_dtcm1_ram_3 (
    .clk(CLK),
    .addr_i(D1TCMADDR),
    .rd_o(D1TCMRDATA[31:24]),
    .wd_i(D1TCMWDATA[31:24]),
    .cs_i(D1TCMCS),
    .we_i(D1TCMWR&D1TCMBYTEWR[3])
);


endmodule
