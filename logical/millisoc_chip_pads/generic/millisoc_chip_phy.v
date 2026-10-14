
module millisoc_chip_phy(
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

    // UART
    output wire           uart_txd0_pad,
    input  wire           uart_rxd0_pad,
    output wire           uart_txd1_pad,
    input  wire           uart_rxd1_pad
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


assign uart_txd0_pad = uarttxen0 ? uarttxd0 : 1'bz;
assign uartrxd0     = uart_rxd0_pad;

assign uart_txd1_pad = uarttxen1 ? uarttxd1 : 1'bz;
assign uartrxd1     = uart_rxd1_pad;

endmodule
