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

// - AXI from CPU to NIC400
wire         CPU_ACLKEN;
axi4_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) CPU_AXI();
axi4_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) CPU_Rx_AXI();
axi4_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) DEBUG_AXI();

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
wire [239:0]    CPU_IRQs;
wire [3:0]      SYS_DMA_DONE_IRQ;
wire            SYS_DMA_COMB_IRQ;
wire            IRQ_QSPI_FINISHED;
wire [71:0]     PERI_IRQS;

assign CPU_IRQs[3:0]=   SYS_DMA_DONE_IRQ[3:0];
assign CPU_IRQs[4]=     SYS_DMA_COMB_IRQ;
assign CPU_IRQs[5]=     IRQ_QSPI_FINISHED;
assign CPU_IRQs[77:6]=  PERI_IRQS;
assign CPU_IRQs[239:78]=161'd0;

// Tie offs (may be used later)
assign PCLKEN_DMA = 1'b1;
assign CLKEN = 1'b1;
assign FCLKEN = 1'b1;
assign HCLKEN = 1'b1;
assign ETMCLKEN = 1'b1;
assign nDBGETMRESET = nPORESET;
assign TRESETn = nPORESET;
assign CPUWAIT = 1'b0;
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
    .nsysreset(nSYSRESET)
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

    .PERI_IRQS(PERI_IRQS)
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

    //.AWID_CPU_Rx(CPU_Rx_AXI.AWID),
    .AWADDR_CPU_Rx(CPU_Rx_AXI.AWADDR),
    .AWLEN_CPU_Rx(CPU_Rx_AXI.AWLEN),
    .AWSIZE_CPU_Rx(CPU_Rx_AXI.AWSIZE),
    .AWBURST_CPU_Rx(CPU_Rx_AXI.AWBURST),
    .AWLOCK_CPU_Rx(CPU_Rx_AXI.AWLOCK),
    .AWCACHE_CPU_Rx(CPU_Rx_AXI.AWCACHE),
    .AWPROT_CPU_Rx(CPU_Rx_AXI.AWPROT),
    .AWVALID_CPU_Rx(CPU_Rx_AXI.AWVALID),
    .AWREADY_CPU_Rx(CPU_Rx_AXI.AWREADY),
    .WDATA_CPU_Rx(CPU_Rx_AXI.WDATA),
    .WSTRB_CPU_Rx(CPU_Rx_AXI.WSTRB),
    .WLAST_CPU_Rx(CPU_Rx_AXI.WLAST),
    .WVALID_CPU_Rx(CPU_Rx_AXI.WVALID),
    .WREADY_CPU_Rx(CPU_Rx_AXI.WREADY),
    //.BID_CPU_Rx(CPU_Rx_AXI.BID),
    .BRESP_CPU_Rx(CPU_Rx_AXI.BRESP),
    .BVALID_CPU_Rx(CPU_Rx_AXI.BVALID),
    .BREADY_CPU_Rx(CPU_Rx_AXI.BREADY),
    //.ARID_CPU_Rx(CPU_Rx_AXI.ARID),
    .ARADDR_CPU_Rx(CPU_Rx_AXI.ARADDR),
    .ARLEN_CPU_Rx(CPU_Rx_AXI.ARLEN),
    .ARSIZE_CPU_Rx(CPU_Rx_AXI.ARSIZE),
    .ARBURST_CPU_Rx(CPU_Rx_AXI.ARBURST),
    .ARLOCK_CPU_Rx(CPU_Rx_AXI.ARLOCK),
    .ARCACHE_CPU_Rx(CPU_Rx_AXI.ARCACHE),
    .ARPROT_CPU_Rx(CPU_Rx_AXI.ARPROT),
    .ARVALID_CPU_Rx(CPU_Rx_AXI.ARVALID),
    .ARREADY_CPU_Rx(CPU_Rx_AXI.ARREADY),
    //.RID_CPU_Rx(CPU_Rx_AXI.RID),
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
assign CPU_Rx_AXI.AWVALID = 1'b0;
assign CPU_Rx_AXI.WREADY = 1'b0;
assign CPU_Rx_AXI.BREADY = 1'b0;
assign CPU_Rx_AXI.ARVALID = 1'b0;
assign CPU_Rx_AXI.RREADY = 1'b0;

assign DEBUG_AXI.AWVALID = 1'b0;
assign DEBUG_AXI.WREADY = 1'b0;
assign DEBUG_AXI.BREADY = 1'b0;
assign DEBUG_AXI.ARVALID = 1'b0;
assign DEBUG_AXI.RREADY = 1'b0;

endmodule
