
module itcm (
    input  wire         CLK,

    input  wire         ITCMCS,       // Chip select/RAM enable
    input  wire [23:3]  ITCMADDR,     // Address
    input  wire         ITCMWR,       // Write/not read
    input  wire [ 7:0]  ITCMBYTEWR,   // Byte strobes
    input  wire [63:0]  ITCMWDATA,    // Write data
    output wire [63:0]  ITCMRDATA    // Read data

);

bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[7:0]),
    .wd_i(ITCMWDATA[7:0]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[0])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_1 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[15:8]),
    .wd_i(ITCMWDATA[15:8]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[1])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_2 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[23:16]),
    .wd_i(ITCMWDATA[23:16]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[2])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_3 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[31:24]),
    .wd_i(ITCMWDATA[31:24]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[3])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_4 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[39:32]),
    .wd_i(ITCMWDATA[39:32]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[4])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_5 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[47:40]),
    .wd_i(ITCMWDATA[47:40]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[5])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_6 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[55:48]),
    .wd_i(ITCMWDATA[55:48]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[6])
);
bit_ram #(
    .addr_bits(21),
    .data_bits(8),
    .reset(0),
    .reset_high(0)
) u_itcm_ram_7 (
    .clk(CLK),
    .addr_i(ITCMADDR),
    .rd_o(ITCMRDATA[63:56]),
    .wd_i(ITCMWDATA[63:56]),
    .cs_i(ITCMCS),
    .we_i(ITCMWR&ITCMBYTEWR[7])
);


endmodule
