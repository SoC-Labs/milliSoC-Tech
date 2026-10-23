
module millisoc_chip_pads(
    input  wire         CLK,
    input  wire         nPORST,

    output wire         QSPI_SCLK,
    output wire         QSPI_nCS,
    inout  wire [3:0]   QSPI_IO,

    output wire         UARTTXD0,
    input  wire         UARTRXD0,
    output wire         UARTTXD1,
    input  wire         UARTRXD1,

    output wire         UARTTXD0_RT,
    input  wire         UARTRXD0_RT,
    output wire         UARTTXD1_RT,
    input  wire         UARTRXD1_RT,

    // DAP-LITE (SWD / JTAG debug port)
    input  wire         DAP_nTRST,
    input  wire         DAP_SWCLK,
    inout  wire         DAP_SWDIO,
    input  wire         DAP_TDI,
    output wire         DAP_TDO

);

// QSPI internal Signals
wire             qspi_sclk;
wire             qspi_ncs;
wire [3:0]       qspi_io_o;
wire [3:0]       qspi_io_i;
wire [3:0]       qspi_io_e;
// UART internal signals
wire             uartrxd0;
wire             uarttxd0;
wire             uarttxen0;
wire             uartrxd1;
wire             uarttxd1;
wire             uarttxen1;

wire             uartrxd0_RT;
wire             uarttxd0_RT;
wire             uarttxen0_RT;
wire             uartrxd1_RT;
wire             uarttxd1_RT;
wire             uarttxen1_RT;

// DAP-LITE internal signals
wire             ntrst;
wire             swclktck;
wire             swditms;
wire             tdi;
wire             tdo;
wire             ntdoen;
wire             swdo;
wire             swdoen;
// SPI Bus internal
wire             spi_ssn;
wire             spi_sclk;
wire             spi_mosi;
wire             spi_miso;

wire [15:0]      p0_in;
wire [15:0]      p0_out;
wire [15:0]      p0_en;
wire [15:0]      p0_func;
wire [15:0]      p1_in;
wire [15:0]      p1_out;
wire [15:0]      p1_en;
wire [15:0]      p1_func;

millisoc_system u_millisoc_system(
    .FCLK(CLK),
    .nPORESET(nPORST),
    .QSPI_SCLK(qspi_sclk),
    .QSPI_nCS(qspi_ncs),
    .QSPI_IO_o(qspi_io_o),
    .QSPI_IO_i(qspi_io_i),
    .QSPI_IO_e(qspi_io_e),
    .UARTRXD0(uartrxd0),
    .UARTTXD0(uarttxd0),
    .UARTTXEN0(uarttxen0),
    .UARTRXD1(uartrxd1),
    .UARTTXD1(uarttxd1),
    .UARTTXEN1(uarttxen1),

    .UARTRXD0_RT(uartrxd0_RT),
    .UARTTXD0_RT(uarttxd0_RT),
    .UARTTXEN0_RT(uarttxen0_RT),
    .UARTRXD1_RT(uartrxd1_RT),
    .UARTTXD1_RT(uarttxd1_RT),
    .UARTTXEN1_RT(uarttxen1_RT),

    .nTRST(ntrst),
    .SWCLKTCK(swclktck),
    .SWDITMS(swditms),
    .TDI(tdi),
    .TDO(tdo),
    .nTDOEN(ntdoen),
    .SWDO(swdo),
    .SWDOEN(swdoen),
    .SPI_SSn(spi_ssn),
    .SPI_SCLK(spi_sclk),
    .SPI_MOSI(spi_mosi),
    .SPI_MISO(spi_miso),
    .P0_IN(p0_in),
    .P0_OUT(p0_out),
    .P0_EN(p0_en),
    .P0_FUNC(p0_func),
    .P1_IN(p1_in),
    .P1_OUT(p1_out),
    .P1_EN(p1_en),
    .P1_FUNC(p1_func)
);

millisoc_chip_phy u_millisoc_chip_phy(
    .qspi_sclk(qspi_sclk),
    .qspi_ncs(qspi_ncs),
    .qspi_io_o(qspi_io_o),
    .qspi_io_i(qspi_io_i),
    .qspi_io_e(qspi_io_e),

    .uartrxd0(uartrxd0),
    .uarttxd0(uarttxd0),
    .uarttxen0(uarttxen0),
    .uartrxd1(uartrxd1),
    .uarttxd1(uarttxd1),
    .uarttxen1(uarttxen1),

    .uartrxd0_RT(uartrxd0_RT),
    .uarttxd0_RT(uarttxd0_RT),
    .uarttxen0_RT(uarttxen0_RT),
    .uartrxd1_RT(uartrxd1_RT),
    .uarttxd1_RT(uarttxd1_RT),
    .uarttxen1_RT(uarttxen1_RT),

    .ntrst(ntrst),
    .swclktck(swclktck),
    .swditms(swditms),
    .tdi(tdi),
    .tdo(tdo),
    .ntdoen(ntdoen),
    .swdo(swdo),
    .swdoen(swdoen),

    .spi_ssn(spi_ssn),
    .spi_sclk(spi_sclk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),

    .p0_in(p0_in),
    .p0_out(p0_out),
    .p0_en(p0_en),
    .p0_func(p0_func),
    .p1_in(p1_in),
    .p1_out(p1_out),
    .p1_en(p1_en),
    .p1_func(p1_func),

    .qspi_sclk_pad(QSPI_SCLK),
    .qspi_ncs_pad(QSPI_nCS),
    .qspi_io_pad(QSPI_IO),

    .uart_txd0_pad(UARTTXD0),
    .uart_rxd0_pad(UARTRXD0),
    .uart_txd1_pad(UARTTXD1),
    .uart_rxd1_pad(UARTRXD1),

    .uart_txd0_pad_RT(UARTTXD0_RT),
    .uart_rxd0_pad_RT(UARTRXD0_RT),
    .uart_txd1_pad_RT(UARTTXD1_RT),
    .uart_rxd1_pad_RT(UARTRXD1_RT),

    .dap_ntrst_pad(DAP_nTRST),
    .dap_swclk_pad(DAP_SWCLK),
    .dap_swdio_pad(DAP_SWDIO),
    .dap_tdi_pad(DAP_TDI),
    .dap_tdo_pad(DAP_TDO),
    .dap_ntdoen_pad()

);

endmodule
