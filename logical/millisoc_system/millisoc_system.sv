//-----------------------------------------------------------------------------
// milliSoC System
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright � 2021-5, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
// Purpose:
//  Top level system for milliSoC, instantiates all subsystems
//
//-----------------------------------------------------------------------------
// Modules instantiated:
//  millisoc_cpu_ss                 (u_millisoc_cpu_ss)
//  millisoc_sys_ctrl               (u_millisoc_sys_ctrl)
//  ada_top_sldma350                (u_dma350)
//  millisoc_peripheral_subsystem   (u_millisoc_peripheral_subsystem)
//  top_ahb_qspi                    (u_ahb_qspi)
//  ROM_wrapper                     (u_ROM_wrapper)
//  nic400_millisoc_main            (u_nic400_millisoc_main)

module millisoc_system(
    input  wire     FCLK,
    input  wire     nPORESET,

    // QSPI Signals
    output wire             QSPI_SCLK,
    output wire             QSPI_nCS,
    output wire [3:0]       QSPI_IO_o,
    input  wire [3:0]       QSPI_IO_i,
    output wire [3:0]       QSPI_IO_e,

    // UART signals
    input  wire             UARTRXD0,
    output wire             UARTTXD0,
    output wire             UARTTXEN0,
    input  wire             UARTRXD1,
    output wire             UARTTXD1,
    output wire             UARTTXEN1,

    input  wire             UARTRXD0_RT,
    output wire             UARTTXD0_RT,
    output wire             UARTTXEN0_RT,
    input  wire             UARTRXD1_RT,
    output wire             UARTTXD1_RT,
    output wire             UARTTXEN1_RT,

    // DAP-LITE external signals
    input  wire             nTRST,
    input  wire             SWCLKTCK,
    input  wire             SWDITMS,
    input  wire             TDI,
    output wire             TDO,
    output wire             nTDOEN,
    output wire             SWDO,
    output wire             SWDOEN,

    // SPI Bus to Pads
    output wire             SPI_SSn,
    output wire             SPI_SCLK,
    output wire             SPI_MOSI,
    input  wire             SPI_MISO,

    input  wire [15:0]      P0_IN,
    output wire [15:0]      P0_OUT,
    output wire [15:0]      P0_EN,
    output wire [15:0]      P0_FUNC,
    input  wire [15:0]      P1_IN,
    output wire [15:0]      P1_OUT,
    output wire [15:0]      P1_EN,
    output wire [15:0]      P1_FUNC
);


// Internal Wires
// Clocks and resets
wire  HCLK;
wire  PCLK;
wire  HRESETn;
wire  PRESETn;

// - APB for DMA
apb4_if DMA_CFG_APB();
wire    PCLKEN_DMA;

// - AXI from DMA to System Bus
axi4_if #(.DATA_W(64), .ID_W(2), .ADDR_W(32)) DMA_AXI();
wire [3:0]  DMA_awqos;
wire [3:0]  DMA_arqos;

ahb_if #(.DATA_W(32), .ADDR_W(32)) QSPI_AHB(); // - AHB to QSPI
apb4_if QSPI_CFG_APB(); // - APB to QSPI

apb4_if SYS_CTRL_APB();

// - AHB to ROM
ahb_if #(.DATA_W(64), .ADDR_W(32)) ROM_AHB();

// - AHB to peripheral subsystem
ahb_if #(.DATA_W(32), .ADDR_W(32)) PERIPH_AHB();

assign PERIPH_AHB.HSEL=1'b1;
assign PERIPH_AHB.HREADY=1'b1;
// - AHB to CPU
ahb_if #(.DATA_W(64), .ADDR_W(32)) CPU_S_AHB();
ahb_if #(.DATA_W(32), .ADDR_W(32)) CPU_Rx_GIC_AHB();

// - AXI from CPU to NIC400
wire         CPU_ACLKEN;
axi4_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) CPU_AXI();
axi3_if #(.DATA_W(64), .ID_W(4), .ADDR_W(32)) CPU_Rx_AXI();
axi4_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) DEBUG_AXI();

axi3_if #(.DATA_W(64), .ID_W(2), .ADDR_W(32)) CPU_Rx_S_AXI();
axi3_if #(.DATA_W(32), .ID_W(4), .ADDR_W(32)) Rx_PERI_AXI();

// - Resets and clock gates for CPU
wire        CLKEN;
wire        FCLKEN;
wire        HCLKEN;
wire        ETMCLKEN;
wire        ACLK;

wire        nSYSRESET;
wire        SYSRESETREQ;
wire        nDBGETMRESET;
wire        CPUWAIT;
wire        TRACECLKIN;
wire        TRESETn;
wire        ARESETn;
wire        WDOGRESREQ;

// Interrupts
wire [239:0]    Rx_CPU_IRQs;
wire [3:0]      SYS_DMA_DONE_IRQ;
wire            SYS_DMA_COMB_IRQ;
wire            IRQ_QSPI_FINISHED;
wire [55:0]     Rx_PERI_IRQS;

assign Rx_CPU_IRQs[3:0]=   SYS_DMA_DONE_IRQ[3:0];
assign Rx_CPU_IRQs[4]=     SYS_DMA_COMB_IRQ;
assign Rx_CPU_IRQs[5]=     IRQ_QSPI_FINISHED;
assign Rx_CPU_IRQs[61:6]=  Rx_PERI_IRQS;
assign Rx_CPU_IRQs[239:62]=161'd0;

// Tie offs (may be used later)
assign PCLKEN_DMA = 1'b1;
assign CLKEN = 1'b1;
assign FCLKEN = 1'b1;
assign HCLKEN = 1'b1;
assign ETMCLKEN = 1'b1;
assign nDBGETMRESET = nPORESET;
assign TRESETn = nPORESET;
assign CPU_ACLKEN  = 1'b1;
assign HCLK = FCLK;
assign PCLK = FCLK;
assign ACLK = FCLK;
assign HRESETn = nPORESET;
assign PRESETn = nPORESET;
assign ARESETn = nPORESET;

// Permanent Tie offs
assign DMA_AXI.AWLOCK=1'b0;
assign DMA_AXI.ARLOCK=1'b0;

millisoc_cpu_ss u_millisoc_cpu_ss (
    .FCLK(FCLK),
    .CLKEN(CLKEN),
    .FCLKEN(FCLKEN),
    .HCLKEN(HCLKEN),
    .ETMCLKEN(ETMCLKEN),
    .nSYSRESET(nSYSRESET),
    .SYSRESETREQ(SYSRESETREQ),
    .nPORESET(nPORESET),
    .nDBGETMRESET(nDBGETMRESET),
    .CPUWAIT(CPUWAIT),
    .SWCLKTCK(SWCLKTCK),
    .TRACECLKIN(TRACECLKIN),
    .TRESETn(TRESETn),

    .HTRANSP(PERIPH_AHB.HTRANS),
    .HWRITEP(PERIPH_AHB.HWRITE),
    .HSIZEP(PERIPH_AHB.HSIZE),
    .HBURSTP(PERIPH_AHB.HBURST),
    .HPROTP(PERIPH_AHB.HPROT),
    .HMASTERP(),
    .HADDRP(PERIPH_AHB.HADDR),
    .HWDATAP(PERIPH_AHB.HWDATA),
    .EXREQP(),
    .HREADYP(PERIPH_AHB.HREADYOUT),
    .HRESPP(PERIPH_AHB.HRESP),
    .HRDATAP(PERIPH_AHB.HRDATA),
    .EXRESPP(),

    .HREADYOUTS(CPU_S_AHB.HREADYOUT),
    .HRESPS(CPU_S_AHB.HRESP),
    .HRDATAS(CPU_S_AHB.HRDATA),
    .HREADYS(CPU_S_AHB.HREADY),
    .HSELS(CPU_S_AHB.HSEL),
    .HTRANSS(CPU_S_AHB.HTRANS),
    .HWRITES(CPU_S_AHB.HWRITE),
    .HSIZES(CPU_S_AHB.HSIZE),
    .HBURSTS(CPU_S_AHB.HBURST),
    .HPROTS(CPU_S_AHB.HPROT),
    .HADDRS(CPU_S_AHB.HADDR),
    .HWDATAS(CPU_S_AHB.HWDATA),

    .ACLKEN(CPU_ACLKEN),
    .ARVALID(CPU_AXI.ARVALID),
    .ARADDR(CPU_AXI.ARADDR),
    .ARID(CPU_AXI.ARID),
    .ARBURST(CPU_AXI.ARBURST),
    .ARLEN(CPU_AXI.ARLEN),
    .ARSIZE(CPU_AXI.ARSIZE),
    .ARLOCK(CPU_AXI.ARLOCK),
    .ARCACHE(CPU_AXI.ARCACHE),
    .ARPROT(CPU_AXI.ARPROT),
    .ARMASTER(),
    .ARINNER(),
    .ARSHARE(),
    .ARREADY(CPU_AXI.ARREADY),
    .AWVALID(CPU_AXI.AWVALID),
    .AWADDR(CPU_AXI.AWADDR),
    .AWID(CPU_AXI.AWID),
    .AWBURST(CPU_AXI.AWBURST),
    .AWLEN(CPU_AXI.AWLEN),
    .AWSIZE(CPU_AXI.AWSIZE),
    .AWLOCK(CPU_AXI.AWLOCK),
    .AWCACHE(CPU_AXI.AWCACHE),
    .AWPROT(CPU_AXI.AWPROT),
    .AWMASTER(),
    .AWINNER(),
    .AWSHARE(),
    .AWSPARSE(),
    .AWREADY(CPU_AXI.AWREADY),
    .RREADY(CPU_AXI.RREADY),
    .RVALID(CPU_AXI.RVALID),
    .RID(CPU_AXI.RID),
    .RLAST(CPU_AXI.RLAST),
    .RDATA(CPU_AXI.RDATA),
    .RRESP(CPU_AXI.RRESP),
    .WVALID(CPU_AXI.WVALID),
    .WID(),
    .WDATA(CPU_AXI.WDATA),
    .WSTRB(CPU_AXI.WSTRB),
    .WLAST(CPU_AXI.WLAST),
    .WREADY(CPU_AXI.WREADY),
    .BREADY(CPU_AXI.BREADY),
    .BVALID(CPU_AXI.BVALID),
    .BID(CPU_AXI.BID),
    .BRESP(CPU_AXI.BRESP),

    .IRQ(CPU_IRQs)
);

millisoc_sys_ctrl u_millisoc_sys_ctrl(
    .pclk(FCLK),
    .nporeset(nPORESET),
    .sys_ctrl_apb(SYS_CTRL_APB),
    .sysresetreq(SYSRESETREQ),
    .watchdogreq(WDOGRESREQ),
    .nsysreset(nSYSRESET),
    .cpu_mx_wait(CPUWAIT)
);

millisoc_rt_cpu_subsystem #(
    .BE(0)
    ) u_millisoc_rt_cpu_ss (
    .CLKIN(FCLK),
    .ACPRESETn(nSYSRESET),
    .nRESET0(nSYSRESET),
    .nSYSPORESET(nPORESET),
    .nCPUHALT0(1'b1),
    .DBGNOCLKSTOP(1'b0),

    .ACLKENM0(1'b1),
    .AWIDM0(CPU_Rx_AXI.AWID),
    .AWADDRM0(CPU_Rx_AXI.AWADDR),
    .AWLENM0(CPU_Rx_AXI.AWLEN),
    .AWSIZEM0(CPU_Rx_AXI.AWSIZE),
    .AWBURSTM0(CPU_Rx_AXI.AWBURST),
    .AWLOCKM0(CPU_Rx_AXI.AWLOCK),
    .AWCACHEM0(CPU_Rx_AXI.AWCACHE),
    .AWPROTM0(CPU_Rx_AXI.AWPROT),
    .AWINNERM0(),
    .AWSHAREM0(),
    .AWVALIDM0(CPU_Rx_AXI.AWVALID),
    .AWREADYM0(CPU_Rx_AXI.AWREADY),
    .WIDM0(CPU_Rx_AXI.WID),
    .WDATAM0(CPU_Rx_AXI.WDATA),
    .WSTRBM0(CPU_Rx_AXI.WSTRB),
    .WLASTM0(CPU_Rx_AXI.WLAST),
    .WVALIDM0(CPU_Rx_AXI.WVALID),
    .WREADYM0(CPU_Rx_AXI.WREADY),
    .BIDM0(CPU_Rx_AXI.BID),
    .BRESPM0(CPU_Rx_AXI.BRESP),
    .BVALIDM0(CPU_Rx_AXI.BVALID),
    .BREADYM0(CPU_Rx_AXI.BREADY),
    .ARIDM0(CPU_Rx_AXI.ARID),
    .ARADDRM0(CPU_Rx_AXI.ARADDR),
    .ARLENM0(CPU_Rx_AXI.ARLEN),
    .ARSIZEM0(CPU_Rx_AXI.ARSIZE),
    .ARBURSTM0(CPU_Rx_AXI.ARBURST),
    .ARLOCKM0(CPU_Rx_AXI.ARLOCK),
    .ARCACHEM0(CPU_Rx_AXI.ARCACHE),
    .ARPROTM0(CPU_Rx_AXI.ARPROT),
    .ARINNERM0(),
    .ARSHAREM0(),
    .ARVALIDM0(CPU_Rx_AXI.ARVALID),
    .ARREADYM0(CPU_Rx_AXI.ARREADY),
    .RIDM0(CPU_Rx_AXI.RID),
    .RDATAM0(CPU_Rx_AXI.RDATA),
    .RRESPM0(CPU_Rx_AXI.RRESP),
    .RLASTM0(CPU_Rx_AXI.RLAST),
    .RVALIDM0(CPU_Rx_AXI.RVALID),
    .RREADYM0(CPU_Rx_AXI.RREADY),

    .AWUSERPTYM0(),
    .AWVPTYM0(),
    .AWRPTYM0(1'b0),
    .WVPTYM0(),
    .WRPTYM0(1'b0),
    .BVPTYM0(1'b0),
    .BRPTYM0(),
    .ARUSERPTYM0(),
    .ARVPTYM0(),
    .ARRPTYM0(1'b0),
    .RVPTYM0(1'b0),
    .RRPTYM0(),
    .AWADDRPTYM0(),
    .AWCTLPTYM0(),
    .WCTLPTYM0(),
    .WERRCODEM0(),
    .BCTLPTYM0(2'b0),
    .ARADDRPTYM0(),
    .ARCTLPTYM0(),
    .RCTLPTYM0(2'b0),
    .RERRCODEM0(8'b0),
    .AXIMFATAL0(),
    .AXIMCORR0(),
    .MERRADDR0(),

    // AXI Subordinate
    .ACLKENS0(1'b1),
    .AWIDS0({6'h00, CPU_Rx_S_AXI.AWID}),
    .AWADDRS0(CPU_Rx_S_AXI.AWADDR),
    .AWLENS0(CPU_Rx_S_AXI.AWLEN),
    .AWSIZES0(CPU_Rx_S_AXI.AWSIZE),
    .AWBURSTS0(CPU_Rx_S_AXI.AWBURST),
    .AWLOCKS0(CPU_Rx_S_AXI.AWLOCK),
    .AWCACHES0(CPU_Rx_S_AXI.AWCACHE),
    .AWPROTS0(CPU_Rx_S_AXI.AWPROT),
    .AWUSERPTYS0(1'b0),
    .AWVALIDS0(CPU_Rx_S_AXI.AWVALID),
    .AWVPTYS0(1'b0),
    .AWREADYS0(CPU_Rx_S_AXI.AWREADY),
    .AWRPTYS0(),
    .WIDS0({6'h00, CPU_Rx_S_AXI.WID}),
    .WDATAS0(CPU_Rx_S_AXI.WDATA),
    .WSTRBS0(CPU_Rx_S_AXI.WSTRB),
    .WLASTS0(CPU_Rx_S_AXI.WLAST),
    .WVALIDS0(CPU_Rx_S_AXI.WVALID),
    .WVPTYS0(1'b0),
    .WREADYS0(CPU_Rx_S_AXI.WREADY),
    .WRPTYS0(),
    .BIDS0(CPU_Rx_S_AXI.BID),
    .BRESPS0(CPU_Rx_S_AXI.BRESP),
    .BVALIDS0(CPU_Rx_S_AXI.BVALID),
    .BVPTYS0(),
    .BREADYS0(CPU_Rx_S_AXI.BREADY),
    .BRPTYS0(1'b0),
    .ARIDS0({6'h00,CPU_Rx_S_AXI.ARID}),
    .ARADDRS0(CPU_Rx_S_AXI.ARADDR),
    .ARLENS0(CPU_Rx_S_AXI.ARLEN),
    .ARSIZES0(CPU_Rx_S_AXI.ARSIZE),
    .ARBURSTS0(CPU_Rx_S_AXI.ARBURST),
    .ARLOCKS0(CPU_Rx_S_AXI.ARLOCK),
    .ARCACHES0(CPU_Rx_S_AXI.ARCACHE),
    .ARPROTS0(CPU_Rx_S_AXI.ARPROT),
    .ARUSERPTYS0(1'b0),
    .ARVALIDS0(CPU_Rx_S_AXI.ARVALID),
    .ARVPTYS0(1'b0),
    .ARREADYS0(CPU_Rx_S_AXI.ARREADY),
    .ARRPTYS0(),
    .RIDS0(CPU_Rx_S_AXI.RID),
    .RDATAS0(CPU_Rx_S_AXI.RDATA),
    .RRESPS0(CPU_Rx_S_AXI.RRESP),
    .RLASTS0(CPU_Rx_S_AXI.RLAST),
    .RVALIDS0(CPU_Rx_S_AXI.RVALID),
    .RVPTYS0(),
    .RREADYS0(CPU_Rx_S_AXI.RREADY),
    .RRPTYS0(1'b0),
    .AWADDRPTYS0(4'b0),
    .AWCTLPTYS0(4'b0),
    .WCTLPTYS0(3'b0),
    .WERRCODES0(8'b0),
    .BCTLPTYS0(),
    .ARADDRPTYS0(4'b0),
    .ARCTLPTYS0(4'b0),
    .RCTLPTYS0(),
    .RERRCODES0(),
    .AXISFATAL0(),
    .AXISCORR0(),
    .SERRADDR0(),
    .SERRCSEL0(),

    // Debug
    .PCLKENDBG(1'b0),
    .DBGROMADDR(20'b0),
    .DBGROMADDRV(1'b0),
    .DBGNOPWRDWN(),

    .DBGEN0(1'b0),
    .NIDEN0(1'b0),
    .EDBGRQ0(1'b0),
    .DBGTRIGGER0(),
    .DBGACK0(),
    .COMMRX0(),
    .COMMTX0(),
    .PSELDBG0(1'b0),
    .PADDRDBG0(10'b0),
    .PADDRDBG310(1'b0),
    .PRDATADBG0(),
    .PWDATADBG0(32'b0),
    .PENABLEDBG0(1'b0),
    .PREADYDBG0(),
    .PSLVERRDBG0(),
    .PWRITEDBG0(1'b0),
    .DBGSELFADDR0(20'b0),
    .DBGSELFADDRV0(1'b0),
    .DBGRESTART0(1'b0),
    .DBGRESTARTED0(),
    .DBGRSTREQ0(),

    // ETM
    .ETMICTL0(),
    .ETMIA0(),
    .ETMDCTL0(),
    .ETMDA0(),
    .ETMDD0(),
    .ETMCID0(),
    .ETMWFIPENDING0(),
    .EVNTBUS0(),
    .ETMPWRUP0(1'b0),
    .nETMWFIREADY0(1'b0),
    .ETMEXTOUT0(2'b0),

    // FPU
    .FPIXC0(),
    .FPOFC0(),
    .FPUFC0(),
    .FPIOC0(),
    .FPDZC0(),
    .FPIDC0(),

    // Redundant-logic
    .DCCMINP(8'd0),
    .DCCMOUT(),
    .DCCMINP2(8'd0),
    .DCCMOUT2(),

    // Interrupts
    .INTSYNCEN(1'b1),
    .IRQADDRVSYNCEN(1'b1),
    .nPMUIRQ0(),
    .IRQS(Rx_CPU_IRQs),

    .DBGRESET0n(nSYSRESET),
    .PRESETDBG0n(nSYSRESET),
    .nCLKSTOPPED0(),
    .nWFEPIPESTOPPED0(),
    .nWFIPIPESTOPPED0(),
    .EVENTI0(1'b0),
    .EVENTO0(),

    // AXI-peripheral
    .ACLKENP0(1'b1),
    .AWIDP0(Rx_PERI_AXI.AWID),
    .AWADDRP0(Rx_PERI_AXI.AWADDR),
    .AWLENP0(Rx_PERI_AXI.AWLEN),
    .AWSIZEP0(Rx_PERI_AXI.AWSIZE),
    .AWBURSTP0(Rx_PERI_AXI.AWBURST),
    .AWLOCKP0(Rx_PERI_AXI.AWLOCK),
    .AWCACHEP0(Rx_PERI_AXI.AWCACHE),
    .AWPROTP0(Rx_PERI_AXI.AWPROT),
    .AWVALIDP0(Rx_PERI_AXI.AWVALID),
    .AWVPTYP0(),
    .AWREADYP0(Rx_PERI_AXI.AWREADY),
    .AWRPTYP0(1'b0),
    .AWADDRPTYP0(),
    .AWCTLPTYP0(),
    .WIDP0(Rx_PERI_AXI.WID),
    .WDATAP0(Rx_PERI_AXI.WDATA),
    .WERRCODEP0(),
    .WSTRBP0(Rx_PERI_AXI.WSTRB),
    .WLASTP0(Rx_PERI_AXI.WLAST),
    .WVALIDP0(Rx_PERI_AXI.WVALID),
    .WVPTYP0(),
    .WREADYP0(Rx_PERI_AXI.WREADY),
    .WRPTYP0(1'b0),
    .WCTLPTYP0(),
    .BIDP0(Rx_PERI_AXI.BID),
    .BRESPP0(Rx_PERI_AXI.BRESP),
    .BVALIDP0(Rx_PERI_AXI.BVALID),
    .BVPTYP0(1'b0),
    .BREADYP0(Rx_PERI_AXI.BREADY),
    .BRPTYP0(),
    .BCTLPTYP0(2'b0),
    .ARIDP0(Rx_PERI_AXI.ARID),
    .ARADDRP0(Rx_PERI_AXI.ARADDR),
    .ARLENP0(Rx_PERI_AXI.ARLEN),
    .ARSIZEP0(Rx_PERI_AXI.ARSIZE),
    .ARBURSTP0(Rx_PERI_AXI.ARBURST),
    .ARLOCKP0(Rx_PERI_AXI.ARLOCK),
    .ARCACHEP0(Rx_PERI_AXI.ARCACHE),
    .ARPROTP0(Rx_PERI_AXI.ARPROT),
    .ARVALIDP0(Rx_PERI_AXI.ARVALID),
    .ARVPTYP0(),
    .ARREADYP0(Rx_PERI_AXI.ARREADY),
    .ARRPTYP0(1'b0),
    .ARADDRPTYP0(),
    .ARCTLPTYP0(),
    .RIDP0(Rx_PERI_AXI.RID),
    .RDATAP0(Rx_PERI_AXI.RDATA),
    .RERRCODEP0(7'b0),
    .RRESPP0(Rx_PERI_AXI.RRESP),
    .RLASTP0(Rx_PERI_AXI.RLAST),
    .RVALIDP0(Rx_PERI_AXI.RVALID),
    .RVPTYP0(1'b0),
    .RREADYP0(Rx_PERI_AXI.RREADY),
    .RRPTYP0(),
    .RCTLPTYP0(2'b0),
    .PPXFATAL0(),
    .PPXCORR0(),

    // VIC AHB interface
    .HSELVIC_GIC(CPU_Rx_GIC_AHB.HSEL),
    .HADDR_GIC(CPU_Rx_GIC_AHB.HADDR[11:2]),
    .HWRITE_GIC(CPU_Rx_GIC_AHB.HWRITE),
    .HREADYIN_GIC(CPU_Rx_GIC_AHB.HREADY),
    .HPROT_GIC(CPU_Rx_GIC_AHB.HPROT),
    .HTRANS_GIC(CPU_Rx_GIC_AHB.HTRANS),
    .HSIZE_GIC(CPU_Rx_GIC_AHB.HSIZE),
    .HWDATA_GIC(CPU_Rx_GIC_AHB.HWDATA),
    .HREADYOUT_GIC(CPU_Rx_GIC_AHB.HREADYOUT),
    .HRESP_GIC(CPU_Rx_GIC_AHB.HRESP),
    .HRDATA_GIC(CPU_Rx_GIC_AHB.HRDATA),

    // Split/lock
    .CLKIN1(1'b0),
    .SLSPLIT(1'b0),
    .SLRESETn(1'b0),
    .SLCLAMP(1'b0),
    .SLERRACPn(1'b0),
    .SLERRDBGn(1'b0),

    // Power Modes
    .RAMCONTROL0(8'd0)
);

ada_top_sldma350 u_dma350 (
    .clk(ACLK),
    .resetn(ARESETn),
    .aclken_m0(1'b1),
    .pclken(PCLKEN_DMA),

    .clk_qreqn(1'b1),
    .clk_qacceptn(),
    .clk_qdeny(),
    .clk_qactive(),

    .preq(1'b0),
    .pstate(4'b1000),
    .paccept(),
    .pdeny(),
    .pactive(),

    .pwakeup(1'b1),
    .pdebug(1'b0),

    .psel(DMA_CFG_APB.psel),
    .penable(DMA_CFG_APB.penable),
    .pprot(DMA_CFG_APB.pprot),
    .pwrite(DMA_CFG_APB.pwrite),
    .paddr(DMA_CFG_APB.paddr[12:0]),
    .pwdata(DMA_CFG_APB.pwdata),
    .pstrb(DMA_CFG_APB.pstrb),
    .pready(DMA_CFG_APB.pready),
    .pslverr(DMA_CFG_APB.pslverr),
    .prdata(DMA_CFG_APB.prdata),

    .awakeup_m0(),

    .awid_m0(DMA_AXI.AWID),
    .awaddr_m0(DMA_AXI.AWADDR),
    .awlen_m0(DMA_AXI.AWLEN),
    .awsize_m0(DMA_AXI.AWSIZE),
    .awburst_m0(DMA_AXI.AWBURST),
    .awcache_m0(DMA_AXI.AWCACHE),
    .awprot_m0(DMA_AXI.AWPROT),
    .awvalid_m0(DMA_AXI.AWVALID),
    .awready_m0(DMA_AXI.AWREADY),

    .awqos_m0(DMA_awqos),

    .arid_m0(DMA_AXI.ARID),
    .araddr_m0(DMA_AXI.ARADDR),
    .arlen_m0(DMA_AXI.ARLEN),
    .arsize_m0(DMA_AXI.ARSIZE),
    .arburst_m0(DMA_AXI.ARBURST),
    .arcache_m0(DMA_AXI.ARCACHE),
    .arprot_m0(DMA_AXI.ARPROT),
    .arvalid_m0(DMA_AXI.ARVALID),
    .arready_m0(DMA_AXI.ARREADY),

    .arqos_m0(DMA_arqos),

    .wdata_m0(DMA_AXI.WDATA),
    .wstrb_m0(DMA_AXI.WSTRB),
    .wlast_m0(DMA_AXI.WLAST),
    .wvalid_m0(DMA_AXI.WVALID),
    .wready_m0(DMA_AXI.WREADY),

    .rid_m0(DMA_AXI.RID),
    .rdata_m0(DMA_AXI.RDATA),
    .rresp_m0(DMA_AXI.RRESP),
    .rlast_m0(DMA_AXI.RLAST),
    .rvalid_m0(DMA_AXI.RVALID),
    .rready_m0(DMA_AXI.RREADY),

    .rpoison_m0(1'b0),

    .bid_m0(DMA_AXI.BID),
    .bresp_m0(DMA_AXI.BRESP),
    .bvalid_m0(DMA_AXI.BVALID),
    .bready_m0(DMA_AXI.BREADY),

    .awdomain_m0(),
    .awinner_m0(),
    .ardomain_m0(),
    .arcmdlink_m0(),
    .arinner_m0(),

    .trig_in_0_req(1'b0),
    .trig_in_0_req_type(),
    .trig_in_0_ack(),
    .trig_in_0_ack_type(),

    .trig_in_1_req(1'b0),
    .trig_in_1_req_type(),
    .trig_in_1_ack(),
    .trig_in_1_ack_type(),

    .trig_in_2_req(1'b0),
    .trig_in_2_req_type(),
    .trig_in_2_ack(),
    .trig_in_2_ack_type(),

    .trig_in_3_req(1'b0),
    .trig_in_3_req_type(),
    .trig_in_3_ack(),
    .trig_in_3_ack_type(),

    .trig_out_0_req(),
    .trig_out_0_ack(1'b0),
    .trig_out_1_req(),
    .trig_out_1_ack(1'b0),
    .trig_out_2_req(),
    .trig_out_2_ack(1'b0),
    .trig_out_3_req(),
    .trig_out_3_ack(1'b0),

    .irq_channel(SYS_DMA_DONE_IRQ),
    .irq_comb_nonsec(SYS_DMA_COMB_IRQ),

    .allch_stop_req_nonsec(1'b0),
    .allch_stop_ack_nonsec(),
    .allch_pause_req_nonsec(1'b0),
    .allch_pause_ack_nonsec(),

    .ch_enabled(),
    .ch_err(),
    .ch_stopped(),
    .ch_paused(),
    .ch_priv(),

    .halt_req(1'b0),
    .restart_req(1'b0),
    .halted(),

    // Boot not used
    .boot_en(1'b0),
    .boot_addr(30'd0),
    .boot_memattr(8'h00),
    .boot_shareattr(2'h0)
);

millisoc_peripheral_subsystem u_millisoc_peripheral_subsystem (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .RT_CLK(),

    .PERIPH_AHB(PERIPH_AHB),

    .UARTRXD0(UARTRXD0),
    .UARTTXD0(UARTTXD0),
    .UARTTXEN0(UARTTXEN0),
    .UARTRXD1(UARTRXD1),
    .UARTTXD1(UARTTXD1),
    .UARTTXEN1(UARTTXEN1),

    .p0_in(P0_IN),
    .p0_out(P0_OUT),
    .p0_en(P0_EN),
    .p0_func(P0_FUNC),
    .p1_in(P1_IN),
    .p1_out(P1_OUT),
    .p1_en(P1_EN),
    .p1_func(P1_FUNC),

    .SPI_SSn(SPI_SSn),
    .SPI_SCLK(SPI_SCLK),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),

    .WDOGRESREQ(WDOGRESREQ),

    .PERI_IRQS()
);

millisoc_rt_peripheral_subsystem u_rt_peripheral(
    .CLK(FCLK),
    .PORESETn(nPORESET),
    .SYSRESETn(nSYSRESET),
    .AXI_PERIPH(Rx_PERI_AXI),

    .UARTRXD0(UARTRXD0_RT),
    .UARTTXD0(UARTTXD0_RT),
    .UARTTXEN0(UARTTXEN0_RT),
    .UARTRXD1(UARTRXD1_RT),
    .UARTTXD1(UARTTXD1_RT),
    .UARTTXEN1(UARTTXEN1_RT),
    .p0_in(),
    .p0_out(),
    .p0_en(),
    .p0_func(),
    .p1_in(),
    .p1_out(),
    .p1_en(),
    .p1_func(),
    .SPI_SSn(),
    .SPI_SCLK(),
    .SPI_MOSI(),
    .SPI_MISO(),
    .WDOGRESREQ(),
    .PERI_IRQS(Rx_PERI_IRQS)
);

top_ahb_qspi u_ahb_qspi(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .HADDR(QSPI_AHB.HADDR),
    .HTRANS(QSPI_AHB.HTRANS),
    .HWRITE(QSPI_AHB.HWRITE),
    .HSIZE(QSPI_AHB.HSIZE),
    .HBURST(QSPI_AHB.HBURST),
    .HPROT(QSPI_AHB.HPROT),
    .HWDATA(QSPI_AHB.HWDATA),
    .HSELx(QSPI_AHB.HSEL),
    .HRDATA(QSPI_AHB.HRDATA),
    .HREADY(QSPI_AHB.HREADY),
    .HREADYOUT(QSPI_AHB.HREADYOUT),
    .HRESP(QSPI_AHB.HRESP),

    .PADDR(QSPI_CFG_APB.paddr[15:0]),
    .PPROT(QSPI_CFG_APB.pprot),
    .PSEL(QSPI_CFG_APB.psel),
    .PENABLE(QSPI_CFG_APB.penable),
    .PWRITE(QSPI_CFG_APB.pwrite),
    .PWDATA(QSPI_CFG_APB.pwdata),
    .PSTRB(QSPI_CFG_APB.pstrb),
    .PRDATA(QSPI_CFG_APB.prdata),
    .PREADY(QSPI_CFG_APB.pready),
    .PSLVERR(QSPI_CFG_APB.pslverr),

    .QSPI_SCLK(QSPI_SCLK),
    .QSPI_nCS(QSPI_nCS),
    .QSPI_IO_o(QSPI_IO_o),
    .QSPI_IO_i(QSPI_IO_i),
    .QSPI_IO_e(QSPI_IO_e),

    .IRQ_QSPI_FINISHED(IRQ_QSPI_FINISHED)
);

ROM_wrapper u_ROM_wrapper(
    .HCLK(FCLK),

    .HSEL(ROM_AHB.HSEL),
    .HADDR(ROM_AHB.HADDR[14:0]),
    .HTRANS(ROM_AHB.HTRANS),
    .HSIZE(ROM_AHB.HSIZE),
    .HWRITE(ROM_AHB.HWRITE),
    .HWDATA(ROM_AHB.HWDATA),
    .HREADY(ROM_AHB.HREADY),
    .HREADYOUT(ROM_AHB.HREADYOUT),
    .HRDATA(ROM_AHB.HRDATA),
    .HRESP(ROM_AHB.HRESP)
);

nic400_millisoc_main u_nic400_millisoc_main (
    .AWID_CPU_Rx_S(CPU_Rx_S_AXI.AWID),
    .AWADDR_CPU_Rx_S(CPU_Rx_S_AXI.AWADDR),
    .AWLEN_CPU_Rx_S(CPU_Rx_S_AXI.AWLEN),
    .AWSIZE_CPU_Rx_S(CPU_Rx_S_AXI.AWSIZE),
    .AWBURST_CPU_Rx_S(CPU_Rx_S_AXI.AWBURST),
    .AWLOCK_CPU_Rx_S(CPU_Rx_S_AXI.AWLOCK),
    .AWCACHE_CPU_Rx_S(CPU_Rx_S_AXI.AWCACHE),
    .AWPROT_CPU_Rx_S(CPU_Rx_S_AXI.AWPROT),
    .AWVALID_CPU_Rx_S(CPU_Rx_S_AXI.AWVALID),
    .AWREADY_CPU_Rx_S(CPU_Rx_S_AXI.AWREADY),
    .WID_CPU_Rx_S(CPU_Rx_S_AXI.WID),
    .WDATA_CPU_Rx_S(CPU_Rx_S_AXI.WDATA),
    .WSTRB_CPU_Rx_S(CPU_Rx_S_AXI.WSTRB),
    .WLAST_CPU_Rx_S(CPU_Rx_S_AXI.WLAST),
    .WVALID_CPU_Rx_S(CPU_Rx_S_AXI.WVALID),
    .WREADY_CPU_Rx_S(CPU_Rx_S_AXI.WREADY),
    .BID_CPU_Rx_S(CPU_Rx_S_AXI.BID),
    .BRESP_CPU_Rx_S(CPU_Rx_S_AXI.BRESP),
    .BVALID_CPU_Rx_S(CPU_Rx_S_AXI.BVALID),
    .BREADY_CPU_Rx_S(CPU_Rx_S_AXI.BREADY),
    .ARID_CPU_Rx_S(CPU_Rx_S_AXI.ARID),
    .ARADDR_CPU_Rx_S(CPU_Rx_S_AXI.ARADDR),
    .ARLEN_CPU_Rx_S(CPU_Rx_S_AXI.ARLEN),
    .ARSIZE_CPU_Rx_S(CPU_Rx_S_AXI.ARSIZE),
    .ARBURST_CPU_Rx_S(CPU_Rx_S_AXI.ARBURST),
    .ARLOCK_CPU_Rx_S(CPU_Rx_S_AXI.ARLOCK),
    .ARCACHE_CPU_Rx_S(CPU_Rx_S_AXI.ARCACHE),
    .ARPROT_CPU_Rx_S(CPU_Rx_S_AXI.ARPROT),
    .ARVALID_CPU_Rx_S(CPU_Rx_S_AXI.ARVALID),
    .ARREADY_CPU_Rx_S(CPU_Rx_S_AXI.ARREADY),
    .RID_CPU_Rx_S(CPU_Rx_S_AXI.RID),
    .RDATA_CPU_Rx_S(CPU_Rx_S_AXI.RDATA),
    .RRESP_CPU_Rx_S(CPU_Rx_S_AXI.RRESP),
    .RLAST_CPU_Rx_S(CPU_Rx_S_AXI.RLAST),
    .RVALID_CPU_Rx_S(CPU_Rx_S_AXI.RVALID),
    .RREADY_CPU_Rx_S(CPU_Rx_S_AXI.RREADY),

    .HSELx_CPU_S(CPU_S_AHB.HSEL),
    .HADDR_CPU_S(CPU_S_AHB.HADDR),
    .HTRANS_CPU_S(CPU_S_AHB.HTRANS),
    .HWRITE_CPU_S(CPU_S_AHB.HWRITE),
    .HSIZE_CPU_S(CPU_S_AHB.HSIZE),
    .HBURST_CPU_S(CPU_S_AHB.HBURST),
    .HPROT_CPU_S(CPU_S_AHB.HPROT),
    .HWDATA_CPU_S(CPU_S_AHB.HWDATA),
    .HRDATA_CPU_S(CPU_S_AHB.HRDATA),
    .HREADYOUT_CPU_S(CPU_S_AHB.HREADYOUT),
    .HREADY_CPU_S(CPU_S_AHB.HREADY),
    .HRESP_CPU_S(CPU_S_AHB.HRESP),

    .HSELx_QSPI(QSPI_AHB.HSEL),
    .HADDR_QSPI(QSPI_AHB.HADDR),
    .HTRANS_QSPI(QSPI_AHB.HTRANS),
    .HWRITE_QSPI(QSPI_AHB.HWRITE),
    .HSIZE_QSPI(QSPI_AHB.HSIZE),
    .HBURST_QSPI(QSPI_AHB.HBURST),
    .HPROT_QSPI(QSPI_AHB.HPROT),
    .HWDATA_QSPI(QSPI_AHB.HWDATA),
    .HRDATA_QSPI(QSPI_AHB.HRDATA),
    .HREADYOUT_QSPI(QSPI_AHB.HREADYOUT),
    .HREADY_QSPI(QSPI_AHB.HREADY),
    .HRESP_QSPI(QSPI_AHB.HRESP),

    .HSELx_ROM(ROM_AHB.HSEL),
    .HADDR_ROM(ROM_AHB.HADDR),
    .HTRANS_ROM(ROM_AHB.HTRANS),
    .HWRITE_ROM(ROM_AHB.HWRITE),
    .HSIZE_ROM(ROM_AHB.HSIZE),
    .HBURST_ROM(ROM_AHB.HBURST),
    .HPROT_ROM(ROM_AHB.HPROT),
    .HWDATA_ROM(ROM_AHB.HWDATA),
    .HRDATA_ROM(ROM_AHB.HRDATA),
    .HREADYOUT_ROM(ROM_AHB.HREADYOUT),
    .HREADY_ROM(ROM_AHB.HREADY),
    .HRESP_ROM(ROM_AHB.HRESP),

    .HSELx_RT_GIC(CPU_Rx_GIC_AHB.HSEL),
    .HADDR_RT_GIC(CPU_Rx_GIC_AHB.HADDR),
    .HTRANS_RT_GIC(CPU_Rx_GIC_AHB.HTRANS),
    .HWRITE_RT_GIC(CPU_Rx_GIC_AHB.HWRITE),
    .HSIZE_RT_GIC(CPU_Rx_GIC_AHB.HSIZE),
    .HBURST_RT_GIC(CPU_Rx_GIC_AHB.HBURST),
    .HPROT_RT_GIC(CPU_Rx_GIC_AHB.HPROT),
    .HWDATA_RT_GIC(CPU_Rx_GIC_AHB.HWDATA),
    .HRDATA_RT_GIC(CPU_Rx_GIC_AHB.HRDATA),
    .HREADYOUT_RT_GIC(CPU_Rx_GIC_AHB.HREADYOUT),
    .HREADY_RT_GIC(CPU_Rx_GIC_AHB.HREADY),
    .HRESP_RT_GIC(CPU_Rx_GIC_AHB.HRESP),

    .PADDR_DMA_CFG(DMA_CFG_APB.paddr),
    .PWDATA_DMA_CFG(DMA_CFG_APB.pwdata),
    .PWRITE_DMA_CFG(DMA_CFG_APB.pwrite),
    .PPROT_DMA_CFG(DMA_CFG_APB.pprot),
    .PSTRB_DMA_CFG(DMA_CFG_APB.pstrb),
    .PENABLE_DMA_CFG(DMA_CFG_APB.penable),
    .PSELx_DMA_CFG(DMA_CFG_APB.psel),
    .PRDATA_DMA_CFG(DMA_CFG_APB.prdata),
    .PSLVERR_DMA_CFG(DMA_CFG_APB.pslverr),
    .PREADY_DMA_CFG(DMA_CFG_APB.pready),

    .PADDR_QSPI_CFG(QSPI_CFG_APB.paddr),
    .PWDATA_QSPI_CFG(QSPI_CFG_APB.pwdata),
    .PWRITE_QSPI_CFG(QSPI_CFG_APB.pwrite),
    .PPROT_QSPI_CFG(QSPI_CFG_APB.pprot),
    .PSTRB_QSPI_CFG(QSPI_CFG_APB.pstrb),
    .PENABLE_QSPI_CFG(QSPI_CFG_APB.penable),
    .PSELx_QSPI_CFG(QSPI_CFG_APB.psel),
    .PRDATA_QSPI_CFG(QSPI_CFG_APB.prdata),
    .PSLVERR_QSPI_CFG(QSPI_CFG_APB.pslverr),
    .PREADY_QSPI_CFG(QSPI_CFG_APB.pready),

    .PADDR_SYS_CTRL(SYS_CTRL_APB.paddr),
    .PWDATA_SYS_CTRL(SYS_CTRL_APB.pwdata),
    .PWRITE_SYS_CTRL(SYS_CTRL_APB.pwrite),
    .PPROT_SYS_CTRL(SYS_CTRL_APB.pprot),
    .PSTRB_SYS_CTRL(SYS_CTRL_APB.pstrb),
    .PENABLE_SYS_CTRL(SYS_CTRL_APB.penable),
    .PSELx_SYS_CTRL(SYS_CTRL_APB.psel),
    .PRDATA_SYS_CTRL(SYS_CTRL_APB.prdata),
    .PSLVERR_SYS_CTRL(SYS_CTRL_APB.pslverr),
    .PREADY_SYS_CTRL(SYS_CTRL_APB.pready),

    .AWID_CPU_Mx(CPU_AXI.AWID),
    .AWADDR_CPU_Mx(CPU_AXI.AWADDR),
    .AWLEN_CPU_Mx(CPU_AXI.AWLEN),
    .AWSIZE_CPU_Mx(CPU_AXI.AWSIZE),
    .AWBURST_CPU_Mx(CPU_AXI.AWBURST),
    .AWLOCK_CPU_Mx(CPU_AXI.AWLOCK),
    .AWCACHE_CPU_Mx(CPU_AXI.AWCACHE),
    .AWPROT_CPU_Mx(CPU_AXI.AWPROT),
    .AWVALID_CPU_Mx(CPU_AXI.AWVALID),
    .AWREADY_CPU_Mx(CPU_AXI.AWREADY),
    .WDATA_CPU_Mx(CPU_AXI.WDATA),
    .WSTRB_CPU_Mx(CPU_AXI.WSTRB),
    .WLAST_CPU_Mx(CPU_AXI.WLAST),
    .WVALID_CPU_Mx(CPU_AXI.WVALID),
    .WREADY_CPU_Mx(CPU_AXI.WREADY),
    .BID_CPU_Mx(CPU_AXI.BID),
    .BRESP_CPU_Mx(CPU_AXI.BRESP),
    .BVALID_CPU_Mx(CPU_AXI.BVALID),
    .BREADY_CPU_Mx(CPU_AXI.BREADY),
    .ARID_CPU_Mx(CPU_AXI.ARID),
    .ARADDR_CPU_Mx(CPU_AXI.ARADDR),
    .ARLEN_CPU_Mx(CPU_AXI.ARLEN),
    .ARSIZE_CPU_Mx(CPU_AXI.ARSIZE),
    .ARBURST_CPU_Mx(CPU_AXI.ARBURST),
    .ARLOCK_CPU_Mx(CPU_AXI.ARLOCK),
    .ARCACHE_CPU_Mx(CPU_AXI.ARCACHE),
    .ARPROT_CPU_Mx(CPU_AXI.ARPROT),
    .ARVALID_CPU_Mx(CPU_AXI.ARVALID),
    .ARREADY_CPU_Mx(CPU_AXI.ARREADY),
    .RID_CPU_Mx(CPU_AXI.RID),
    .RDATA_CPU_Mx(CPU_AXI.RDATA),
    .RRESP_CPU_Mx(CPU_AXI.RRESP),
    .RLAST_CPU_Mx(CPU_AXI.RLAST),
    .RVALID_CPU_Mx(CPU_AXI.RVALID),
    .RREADY_CPU_Mx(CPU_AXI.RREADY),

    .AWID_CPU_Rx(CPU_Rx_AXI.AWID),
    .AWADDR_CPU_Rx(CPU_Rx_AXI.AWADDR),
    .AWLEN_CPU_Rx(CPU_Rx_AXI.AWLEN),
    .AWSIZE_CPU_Rx(CPU_Rx_AXI.AWSIZE),
    .AWBURST_CPU_Rx(CPU_Rx_AXI.AWBURST),
    .AWLOCK_CPU_Rx(CPU_Rx_AXI.AWLOCK),
    .AWCACHE_CPU_Rx(CPU_Rx_AXI.AWCACHE),
    .AWPROT_CPU_Rx(CPU_Rx_AXI.AWPROT),
    .AWVALID_CPU_Rx(CPU_Rx_AXI.AWVALID),
    .AWREADY_CPU_Rx(CPU_Rx_AXI.AWREADY),
    .WID_CPU_Rx(CPU_Rx_AXI.WID),
    .WDATA_CPU_Rx(CPU_Rx_AXI.WDATA),
    .WSTRB_CPU_Rx(CPU_Rx_AXI.WSTRB),
    .WLAST_CPU_Rx(CPU_Rx_AXI.WLAST),
    .WVALID_CPU_Rx(CPU_Rx_AXI.WVALID),
    .WREADY_CPU_Rx(CPU_Rx_AXI.WREADY),
    .BID_CPU_Rx(CPU_Rx_AXI.BID),
    .BRESP_CPU_Rx(CPU_Rx_AXI.BRESP),
    .BVALID_CPU_Rx(CPU_Rx_AXI.BVALID),
    .BREADY_CPU_Rx(CPU_Rx_AXI.BREADY),
    .ARID_CPU_Rx(CPU_Rx_AXI.ARID),
    .ARADDR_CPU_Rx(CPU_Rx_AXI.ARADDR),
    .ARLEN_CPU_Rx(CPU_Rx_AXI.ARLEN),
    .ARSIZE_CPU_Rx(CPU_Rx_AXI.ARSIZE),
    .ARBURST_CPU_Rx(CPU_Rx_AXI.ARBURST),
    .ARLOCK_CPU_Rx(CPU_Rx_AXI.ARLOCK),
    .ARCACHE_CPU_Rx(CPU_Rx_AXI.ARCACHE),
    .ARPROT_CPU_Rx(CPU_Rx_AXI.ARPROT),
    .ARVALID_CPU_Rx(CPU_Rx_AXI.ARVALID),
    .ARREADY_CPU_Rx(CPU_Rx_AXI.ARREADY),
    .RID_CPU_Rx(CPU_Rx_AXI.RID),
    .RDATA_CPU_Rx(CPU_Rx_AXI.RDATA),
    .RRESP_CPU_Rx(CPU_Rx_AXI.RRESP),
    .RLAST_CPU_Rx(CPU_Rx_AXI.RLAST),
    .RVALID_CPU_Rx(CPU_Rx_AXI.RVALID),
    .RREADY_CPU_Rx(CPU_Rx_AXI.RREADY),

    .AWADDR_DEBUG(DEBUG_AXI.AWADDR),
    .AWLEN_DEBUG(DEBUG_AXI.AWLEN),
    .AWSIZE_DEBUG(DEBUG_AXI.AWSIZE),
    .AWBURST_DEBUG(DEBUG_AXI.AWBURST),
    .AWLOCK_DEBUG(DEBUG_AXI.AWLOCK),
    .AWCACHE_DEBUG(DEBUG_AXI.AWCACHE),
    .AWPROT_DEBUG(DEBUG_AXI.AWPROT),
    .AWVALID_DEBUG(DEBUG_AXI.AWVALID),
    .AWREADY_DEBUG(DEBUG_AXI.AWREADY),
    .WDATA_DEBUG(DEBUG_AXI.WDATA),
    .WSTRB_DEBUG(DEBUG_AXI.WSTRB),
    .WLAST_DEBUG(DEBUG_AXI.WLAST),
    .WVALID_DEBUG(DEBUG_AXI.WVALID),
    .WREADY_DEBUG(DEBUG_AXI.WREADY),
    .BRESP_DEBUG(DEBUG_AXI.BRESP),
    .BVALID_DEBUG(DEBUG_AXI.BVALID),
    .BREADY_DEBUG(DEBUG_AXI.BREADY),
    .ARADDR_DEBUG(DEBUG_AXI.ARADDR),
    .ARLEN_DEBUG(DEBUG_AXI.ARLEN),
    .ARSIZE_DEBUG(DEBUG_AXI.ARSIZE),
    .ARBURST_DEBUG(DEBUG_AXI.ARBURST),
    .ARLOCK_DEBUG(DEBUG_AXI.ARLOCK),
    .ARCACHE_DEBUG(DEBUG_AXI.ARCACHE),
    .ARPROT_DEBUG(DEBUG_AXI.ARPROT),
    .ARVALID_DEBUG(DEBUG_AXI.ARVALID),
    .ARREADY_DEBUG(DEBUG_AXI.ARREADY),
    .RDATA_DEBUG(DEBUG_AXI.RDATA),
    .RRESP_DEBUG(DEBUG_AXI.RRESP),
    .RLAST_DEBUG(DEBUG_AXI.RLAST),
    .RVALID_DEBUG(DEBUG_AXI.RVALID),
    .RREADY_DEBUG(DEBUG_AXI.RREADY),


    .AWID_DMA(DMA_AXI.AWID),
    .AWADDR_DMA(DMA_AXI.AWADDR),
    .AWLEN_DMA(DMA_AXI.AWLEN),
    .AWSIZE_DMA(DMA_AXI.AWSIZE),
    .AWBURST_DMA(DMA_AXI.AWBURST),
    .AWLOCK_DMA(DMA_AXI.AWLOCK),
    .AWCACHE_DMA(DMA_AXI.AWCACHE),
    .AWPROT_DMA(DMA_AXI.AWPROT),
    .AWVALID_DMA(DMA_AXI.AWVALID),
    .AWREADY_DMA(DMA_AXI.AWREADY),
    .WDATA_DMA(DMA_AXI.WDATA),
    .WSTRB_DMA(DMA_AXI.WSTRB),
    .WLAST_DMA(DMA_AXI.WLAST),
    .WVALID_DMA(DMA_AXI.WVALID),
    .WREADY_DMA(DMA_AXI.WREADY),
    .BID_DMA(DMA_AXI.BID),
    .BRESP_DMA(DMA_AXI.BRESP),
    .BVALID_DMA(DMA_AXI.BVALID),
    .BREADY_DMA(DMA_AXI.BREADY),
    .ARID_DMA(DMA_AXI.ARID),
    .ARADDR_DMA(DMA_AXI.ARADDR),
    .ARLEN_DMA(DMA_AXI.ARLEN),
    .ARSIZE_DMA(DMA_AXI.ARSIZE),
    .ARBURST_DMA(DMA_AXI.ARBURST),
    .ARLOCK_DMA(DMA_AXI.ARLOCK),
    .ARCACHE_DMA(DMA_AXI.ARCACHE),
    .ARPROT_DMA(DMA_AXI.ARPROT),
    .ARVALID_DMA(DMA_AXI.ARVALID),
    .ARREADY_DMA(DMA_AXI.ARREADY),
    .RID_DMA(DMA_AXI.RID),
    .RDATA_DMA(DMA_AXI.RDATA),
    .RRESP_DMA(DMA_AXI.RRESP),
    .RLAST_DMA(DMA_AXI.RLAST),
    .RVALID_DMA(DMA_AXI.RVALID),
    .RREADY_DMA(DMA_AXI.RREADY),
    .AWQOS_DMA(DMA_awqos),
    .ARQOS_DMA(DMA_arqos),

    .clk0clk(FCLK),
    .clk0clken(1'b1),
    .clk0resetn(nPORESET)
);

// Temporary tie off's for DEBUG AXI and CPU_Rx AXI
assign DEBUG_AXI.AWVALID = 1'b0;
assign DEBUG_AXI.WREADY = 1'b0;
assign DEBUG_AXI.BREADY = 1'b0;
assign DEBUG_AXI.ARVALID = 1'b0;
assign DEBUG_AXI.RREADY = 1'b0;

endmodule
