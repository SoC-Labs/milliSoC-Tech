
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

    output wire             uartrxd0_RT,
    input  wire             uarttxd0_RT,
    input  wire             uarttxen0_RT,
    output wire             uartrxd1_RT,
    input  wire             uarttxd1_RT,
    input  wire             uarttxen1_RT,


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
    input  wire           uart_rxd1_pad,

    output wire           uart_txd0_pad_RT,
    input  wire           uart_rxd0_pad_RT,
    output wire           uart_txd1_pad_RT,
    input  wire           uart_rxd1_pad_RT,

    // DAP-LITE to Pads
    input  wire           dap_ntrst_pad,
    output wire           dap_swclk_pad,
    inout  wire           dap_swdio_pad,
    output wire           dap_tdi_pad,
    output wire           dap_tdo_pad,
    output wire           dap_ntdoen_pad

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

assign uart_txd0_pad_RT = uarttxen0_RT ? uarttxd0_RT : 1'bz;
assign uartrxd0_RT     = uart_rxd0_pad_RT;

assign uart_txd1_pad_RT = uarttxen1_RT ? uarttxd1_RT : 1'bz;
assign uartrxd1_RT     = uart_rxd1_pad_RT;

// DAP-LITE pad interface.
//
//  SWDIO is a bidirectional pad: it carries the SWD data in / out in SW-DP
//  mode and the JTAG TMS signal in JTAG-DP mode.  The debug port drives the
//  pad only while its SW data out enable is asserted, and always reads the
//  pin value back onto the SWD data in / JTAG TMS input.
assign ntrst            = dap_ntrst_pad;
assign swclktck        = dap_swclk_pad;
assign tdi              = dap_tdi_pad;
// ntdoen is an active low output enable: the SoC-400 drives TDO while
// ntdoen is low and releases the pad while ntdoen is high.
assign dap_tdo_pad      = ntdoen ? 1'bz : tdo;
assign dap_ntdoen_pad   = ntdoen;
assign dap_swdio_pad    = swdoen ? swdo : 1'bz;
assign swditms          = dap_swdio_pad;

endmodule
