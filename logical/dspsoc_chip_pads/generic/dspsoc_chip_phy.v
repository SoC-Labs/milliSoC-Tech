
module dspsoc_chip_phy(
    // QSPI Signals
    input  wire             qspi_sclk,
    input  wire             qspi_ncs,
    input  wire [3:0]       qspi_io_o,
    output wire [3:0]       qspi_io_i,
    input  wire [3:0]       qspi_io_e,

    // UART signals
    output wire             uartrxd0,
    input  wire             uarttxd0,
    input  wire             uarttxen0,
    output wire             uartrxd1,
    input  wire             uarttxd1,
    input  wire             uarttxen1,


    // EXTIO Signals
    output wire [3:0]       iodata4_i,
    input  wire [3:0]       iodata4_o,
    input  wire [3:0]       iodata4_e,
    input  wire [3:0]       iodata4_t,
    input  wire             ioreq1_o,
    input  wire             ioreq2_o,
    output wire             ioack_i,

    // DAP-LITE signals
    output wire             ntrst,
    output wire             swclktck,
    output wire             swditms,
    output wire             tdi,
    input  wire             tdo,
    input  wire             ntdoen,
    input  wire             swdo,
    input  wire             swdoen,

    // SPI Bus to Pads
    input  wire             spi_ssn,
    input  wire             spi_sclk,
    input  wire             spi_mosi,
    output wire             spi_miso,

    output wire [15:0]      p0_in,
    input  wire [15:0]      p0_out,
    input  wire [15:0]      p0_en,
    input  wire [15:0]      p0_func,
    output wire [15:0]      p1_in,
    input  wire [15:0]      p1_out,
    input  wire [15:0]      p1_en,
    input  wire [15:0]      p1_func,

    // QSPI to Pads
    output wire           qspi_sclk_pad,
    output wire           qspi_ncs_pad,
    inout  wire [3:0]     qspi_io_pad,

    // EXTIO to pads
    inout  wire [3:0]     iodata4_pad,
    output wire           ioreq1_pad,
    output wire           ioreq2_pad,
    input  wire           ioack_pad


);

assign  qspi_sclk_pad = qspi_sclk;
assign  qspi_ncs_pad  = qspi_ncs;
genvar i;
generate
    for (i=0; i<4; i=i+1) begin : g_qspi_io_loop
        assign qspi_io_pad[i] = qspi_io_e[i] ? qspi_io_o[i] : 1'bz;
        assign qspi_io_i[i]   = qspi_io_pad[i];
    end
endgenerate

assign ioreq1_pad = ioreq1_o;
assign ioreq2_pad = ioreq2_o;
assign ioack_i   = ioack_pad;
genvar j;
generate
    for (j=0; j<4; j=j+1) begin : g_extio_loop
        assign iodata4_pad[j] = iodata4_e[j] ? iodata4_o[j] : 1'bz;
        assign iodata4_i[j]   = iodata4_pad[j];
    end
endgenerate


endmodule
