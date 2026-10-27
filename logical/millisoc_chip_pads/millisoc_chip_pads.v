
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
    output wire         DAP_TDO,

    output wire         TRACECLK,
    output wire [3:0]   TRACEDATA,
    output wire         TRACECTL

);

// QSPI internal Signals
wire             qspi_sclk_soc;
wire             qspi_ncs_soc;
wire [3:0]       qspi_io_o;
wire [3:0]       qspi_io_i;
wire [3:0]       qspi_io_e;
// UART internal signals
wire             uartrxd0_soc;
wire             uarttxd0_soc;
wire             uarttxen0_soc;
wire             uartrxd1_soc;
wire             uarttxd1_soc;
wire             uarttxen1_soc;

wire             uartrxd0_RT_soc;
wire             uarttxd0_RT_soc;
wire             uarttxen0_RT_soc;
wire             uartrxd1_RT_soc;
wire             uarttxd1_RT_soc;
wire             uarttxen1_RT_soc;

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
    .QSPI_SCLK(qspi_sclk_soc),
    .QSPI_nCS(qspi_ncs_soc),
    .QSPI_IO_o(qspi_io_o),
    .QSPI_IO_i(qspi_io_i),
    .QSPI_IO_e(qspi_io_e),
    .UARTRXD0(uartrxd0_soc),
    .UARTTXD0(uarttxd0_soc),
    .UARTTXEN0(uarttxen0_soc),
    .UARTRXD1(uartrxd1_soc),
    .UARTTXD1(uarttxd1_soc),
    .UARTTXEN1(uarttxen1_soc),

    .UARTRXD0_RT(uartrxd0_RT_soc),
    .UARTTXD0_RT(uarttxd0_RT_soc),
    .UARTTXEN0_RT(uarttxen0_RT_soc),
    .UARTRXD1_RT(uartrxd1_RT_soc),
    .UARTTXD1_RT(uarttxd1_RT_soc),
    .UARTTXEN1_RT(uarttxen1_RT_soc),

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
    .P1_FUNC(p1_func),
    .TRACECLK(TRACECLK),
    .TRACEDATA(TRACEDATA),
    .TRACECTL(TRACECTL)
);

millisoc_chip_phy u_millisoc_chip_phy(
    .qspi_sclk(qspi_sclk_soc),
    .qspi_ncs(qspi_ncs_soc),
    .qspi_io_o(qspi_io_o),
    .qspi_io_i(qspi_io_i),
    .qspi_io_e(qspi_io_e),

    .uartrxd0(uartrxd0_soc),
    .uarttxd0(uarttxd0_soc),
    .uarttxen0(uarttxen0_soc),
    .uartrxd1(uartrxd1_soc),
    .uarttxd1(uarttxd1_soc),
    .uarttxen1(uarttxen1_soc),

    .uartrxd0_RT(uartrxd0_RT_soc),
    .uarttxd0_RT(uarttxd0_RT_soc),
    .uarttxen0_RT(uarttxen0_RT_soc),
    .uartrxd1_RT(uartrxd1_RT_soc),
    .uarttxd1_RT(uarttxd1_RT_soc),
    .uarttxen1_RT(uarttxen1_RT_soc),

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
