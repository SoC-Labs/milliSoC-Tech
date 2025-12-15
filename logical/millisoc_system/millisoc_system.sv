
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


    // EXTIO Signals
    input  wire [3:0]       iodata4_i,
    output wire [3:0]       iodata4_o,
    output wire [3:0]       iodata4_e,
    output wire [3:0]       iodata4_t,
    output wire             ioreq1_o,
    output wire             ioreq2_o,
    input  wire             ioack_i,

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
wire        PCLKEN_DMA;
wire [31:0] PADDR_DMA_CFG;
wire [31:0] PWDATA_DMA_CFG;
wire        PWRITE_DMA_CFG;
wire [2:0]  PPROT_DMA_CFG;
wire [3:0]  PSTRB_DMA_CFG;
wire        PENABLE_DMA_CFG;
wire        PSELx_DMA_CFG;
wire [31:0] PRDATA_DMA_CFG;
wire        PSLVERR_DMA_CFG;
wire        PREADY_DMA_CFG;

// - AXI from DMA to System Bus
axi4 #(.DATA_W(64), .ID_W(), .ADDR_W(32)) DMA_AXI();
wire [3:0]  DMA_awqos;
wire [3:0]  DMA_arqos;

// - AHB to QSPI
wire        HSELx_QSPI;
wire [31:0] HADDR_QSPI;
wire [1:0]  HTRANS_QSPI;
wire        HWRITE_QSPI;
wire [2:0]  HSIZE_QSPI;
wire [2:0]  HBURST_QSPI;
wire [3:0]  HPROT_QSPI;
wire [31:0] HWDATA_QSPI;
wire [31:0] HRDATA_QSPI;
wire        HREADYOUT_QSPI;
wire        HREADY_QSPI;
wire        HRESP_QSPI;

// - APB to QSPI
wire [31:0] PADDR_QSPI_CFG;
wire [31:0] PWDATA_QSPI_CFG;
wire        PWRITE_QSPI_CFG;
wire [2:0]  PPROT_QSPI_CFG;
wire [3:0]  PSTRB_QSPI_CFG;
wire        PENABLE_QSPI_CFG;
wire        PSELx_QSPI_CFG;
wire [31:0] PRDATA_QSPI_CFG;
wire        PSLVERR_QSPI_CFG;
wire        PREADY_QSPI_CFG;

// - AHB to ROM
wire        HSELx_ROM;
wire [31:0] HADDR_ROM;
wire [1:0]  HTRANS_ROM;
wire        HWRITE_ROM;
wire [2:0]  HSIZE_ROM;
wire [2:0]  HBURST_ROM;
wire [3:0]  HPROT_ROM;
wire [63:0] HWDATA_ROM;
wire [63:0] HRDATA_ROM;
wire        HREADYOUT_ROM;
wire        HREADY_ROM;
wire        HRESP_ROM;

// - AHB to peripheral subsystem
ahb #(.DATA_W(32), .ADDR_W(32)) ADP_AHB();
ahb #(.DATA_W(32), .ADDR_W(32)) PERIPH_AHB();

assign PERIPH_AHB.HSEL=1'b1;
assign PERIPH_AHB.HREADY=1'b1;
// - AHB to CPU
wire        HSELx_CPU_S;
wire [31:0] HADDR_CPU_S;
wire [1:0]  HTRANS_CPU_S;
wire        HWRITE_CPU_S;
wire [2:0]  HSIZE_CPU_S;
wire [2:0]  HBURST_CPU_S;
wire [3:0]  HPROT_CPU_S;
wire [31:0] HWDATA_CPU_S;
wire [31:0] HRDATA_CPU_S;
wire        HREADYOUT_CPU_S;
wire        HREADY_CPU_S;
wire        HRESP_CPU_S;


// - AXI from CPU to NIC400
wire         CPU_ACLKEN;
wire         CPU_ARVALID;
wire [31:0]  CPU_ARADDR;
wire [ 2:0]  CPU_ARID;
wire [ 1:0]  CPU_ARBURST;
wire [ 2:0]  CPU_ARLEN;
wire [ 1:0]  CPU_ARSIZE;
wire         CPU_ARLOCK;
wire [ 3:0]  CPU_ARCACHE;
wire [ 2:0]  CPU_ARPROT;
wire         CPU_ARMASTER;
wire [ 3:0]  CPU_ARINNER;
wire         CPU_ARSHARE;
wire         CPU_ARREADY;
wire         CPU_AWVALID;
wire [31:0]  CPU_AWADDR;
wire [ 1:0]  CPU_AWID;
wire [ 1:0]  CPU_AWBURST;
wire [ 2:0]  CPU_AWLEN;
wire [ 1:0]  CPU_AWSIZE;
wire         CPU_AWLOCK;
wire [ 3:0]  CPU_AWCACHE;
wire [ 2:0]  CPU_AWPROT;
wire         CPU_AWMASTER;
wire [ 3:0]  CPU_AWINNER;
wire         CPU_AWSHARE;
wire         CPU_AWSPARSE;
wire         CPU_AWREADY;
wire         CPU_RREADY;
wire         CPU_RVALID;
wire [ 2:0]  CPU_RID;
wire         CPU_RLAST;
wire [63:0]  CPU_RDATA;
wire [ 1:0]  CPU_RRESP;
wire         CPU_WVALID;
wire [ 1:0]  CPU_WID;
wire [63:0]  CPU_WDATA;
wire [ 7:0]  CPU_WSTRB;
wire         CPU_WLAST;
wire         CPU_WREADY;
wire         CPU_BREADY;
wire         CPU_BVALID;
wire [ 1:0]  CPU_BID;
wire [ 1:0]  CPU_BRESP;

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
wire        SWCLKTCK;
wire        TRACECLKIN;
wire        TRESETn;
wire        ARESETn;


// Interrupts
wire [239:0]    CPU_IRQs;
wire [3:0]      SYS_DMA_DONE_IRQ;
wire            SYS_DMA_COMB_IRQ;

assign CPU_IRQs[3:0]=SYS_DMA_DONE_IRQ[3:0];
assign CPU_IRQs[4]=SYS_DMA_COMB_IRQ;
assign CPU_IRQs[239:3]=235'd0;

// Tie offs (may be used later)
assign PCLKEN_DMA = 1'b1;
assign CLKEN = 1'b1;
assign FCLKEN = 1'b1;
assign HCLKEN = 1'b1;
assign ETMCLKEN = 1'b1;
assign nSYSRESET = nPORESET;
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

    .HREADYOUTS(HREADYOUT_CPU_S),
    .HRESPS(HRESP_CPU_S),
    .HRDATAS(HRDATA_CPU_S),
    .HREADYS(HREADY_CPU_S),
    .HSELS(HSELx_CPU_S),
    .HTRANSS(HTRANS_CPU_S),
    .HWRITES(HWRITE_CPU_S),
    .HSIZES(HSIZE_CPU_S),
    .HBURSTS(HBURST_CPU_S),
    .HPROTS(HPROT_CPU_S),
    .HADDRS(HADDR_CPU_S),
    .HWDATAS(HWDATA_CPU_S),

    .ACLKEN(CPU_ACLKEN),
    .ARVALID(CPU_ARVALID),
    .ARADDR(CPU_ARADDR),
    .ARID(CPU_ARID),
    .ARBURST(CPU_ARBURST),
    .ARLEN(CPU_ARLEN),
    .ARSIZE(CPU_ARSIZE),
    .ARLOCK(CPU_ARLOCK),
    .ARCACHE(CPU_ARCACHE),
    .ARPROT(CPU_ARPROT),
    .ARMASTER(CPU_ARMASTER),
    .ARINNER(CPU_ARINNER),
    .ARSHARE(CPU_ARSHARE),
    .ARREADY(CPU_ARREADY),
    .AWVALID(CPU_AWVALID),
    .AWADDR(CPU_AWADDR),
    .AWID(CPU_AWID),
    .AWBURST(CPU_AWBURST),
    .AWLEN(CPU_AWLEN),
    .AWSIZE(CPU_AWSIZE),
    .AWLOCK(CPU_AWLOCK),
    .AWCACHE(CPU_AWCACHE),
    .AWPROT(CPU_AWPROT),
    .AWMASTER(CPU_AWMASTER),
    .AWINNER(CPU_AWINNER),
    .AWSHARE(CPU_AWSHARE),
    .AWSPARSE(CPU_AWSPARSE),
    .AWREADY(CPU_AWREADY),
    .RREADY(CPU_RREADY),
    .RVALID(CPU_RVALID),
    .RID(CPU_RID),
    .RLAST(CPU_RLAST),
    .RDATA(CPU_RDATA),
    .RRESP(CPU_RRESP),
    .WVALID(CPU_WVALID),
    .WID(CPU_WID),
    .WDATA(CPU_WDATA),
    .WSTRB(CPU_WSTRB),
    .WLAST(CPU_WLAST),
    .WREADY(CPU_WREADY),
    .BREADY(CPU_BREADY),
    .BVALID(CPU_BVALID),
    .BID(CPU_BID),
    .BRESP(CPU_BRESP),

    .IRQ(CPU_IRQs)
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

    .psel(PSELx_DMA_CFG),
    .penable(PENABLE_DMA_CFG),
    .pprot(PPROT_DMA_CFG),
    .pwrite(PWRITE_DMA_CFG),
    .paddr(PADDR_DMA_CFG),
    .pwdata(PWDATA_DMA_CFG),
    .pstrb(PSTRB_DMA_CFG),
    .pready(PREADY_DMA_CFG),
    .pslverr(PSLVERR_DMA_CFG),
    .prdata(PRDATA_DMA_CFG),

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

    .ADP_AHB(ADP_AHB),
    .PERIPH_AHB(PERIPH_AHB),

    .UARTRXD0(UARTRXD0),
    .UARTTXD0(UARTTXD0),
    .UARTTXEN0(UARTTXEN0),
    .UARTRXD1(UARTRXD1),
    .UARTTXD1(UARTTXD1),
    .UARTTXEN1(UARTTXEN1),

    .iodata4_i(iodata4_i),
    .iodata4_o(iodata4_o),
    .iodata4_e(iodata4_e),
    .iodata4_t(iodata4_t),
    .ioreq1_o(ioreq1_o),
    .ioreq2_o(ioreq2_o),
    .ioack_i(ioack_i),

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

    .PERI_IRQS()
);

top_ahb_qspi u_ahb_qspi(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .HADDR(HADDR_QSPI),
    .HTRANS(HTRANS_QSPI),
    .HWRITE(HWRITE_QSPI),
    .HSIZE(HSIZE_QSPI),
    .HBURST(HBURST_QSPI),
    .HPROT(HPROT_QSPI),
    .HWDATA(HWDATA_QSPI),
    .HSELx(HSELx_QSPI),
    .HRDATA(HRDATA_QSPI),
    .HREADY(HREADY_QSPI),
    .HREADYOUT(HREADYOUT_QSPI),
    .HRESP(HRESP_QSPI),

    .PADDR(PADDR_QSPI_CFG[15:0]),
    .PPROT(PPROT_QSPI_CFG),
    .PSEL(PSELx_QSPI_CFG),
    .PENABLE(PENABLE_QSPI_CFG),
    .PWRITE(PWRITE_QSPI_CFG),
    .PWDATA(PWDATA_QSPI_CFG),
    .PSTRB(PSTRB_QSPI_CFG),
    .PRDATA(PRDATA_QSPI_CFG),
    .PREADY(PREADY_QSPI_CFG),
    .PSLVERR(PSLVERR_QSPI_CFG),

    .QSPI_SCLK(QSPI_SCLK),
    .QSPI_nCS(QSPI_nCS),
    .QSPI_IO_o(QSPI_IO_o),
    .QSPI_IO_i(QSPI_IO_i),
    .QSPI_IO_e(QSPI_IO_e),

    .IRQ_QSPI_FINISHED()
);

ROM_wrapper u_ROM_wrapper(
    .HCLK(FCLK),

    .HSEL(HSELx_ROM),
    .HADDR(HADDR_ROM[14:0]),
    .HTRANS(HTRANS_ROM),
    .HSIZE(HSIZE_ROM),
    .HWRITE(HWRITE_ROM),
    .HWDATA(HWDATA_ROM),
    .HREADY(HREADY_ROM),
    .HREADYOUT(HREADYOUT_ROM),
    .HRDATA(HRDATA_ROM),
    .HRESP(HRESP_ROM)
);

nic400_millisoc_main u_nic400_millisoc_main (
    .HSELx_CPU_S(HSELx_CPU_S),
    .HADDR_CPU_S(HADDR_CPU_S),
    .HTRANS_CPU_S(HTRANS_CPU_S),
    .HWRITE_CPU_S(HWRITE_CPU_S),
    .HSIZE_CPU_S(HSIZE_CPU_S),
    .HBURST_CPU_S(HBURST_CPU_S),
    .HPROT_CPU_S(HPROT_CPU_S),
    .HWDATA_CPU_S(HWDATA_CPU_S),
    .HRDATA_CPU_S(HRDATA_CPU_S),
    .HREADYOUT_CPU_S(HREADYOUT_CPU_S),
    .HREADY_CPU_S(HREADY_CPU_S),
    .HRESP_CPU_S(HRESP_CPU_S),

    .HSELx_QSPI(HSELx_QSPI),
    .HADDR_QSPI(HADDR_QSPI),
    .HTRANS_QSPI(HTRANS_QSPI),
    .HWRITE_QSPI(HWRITE_QSPI),
    .HSIZE_QSPI(HSIZE_QSPI),
    .HBURST_QSPI(HBURST_QSPI),
    .HPROT_QSPI(HPROT_QSPI),
    .HWDATA_QSPI(HWDATA_QSPI),
    .HRDATA_QSPI(HRDATA_QSPI),
    .HREADYOUT_QSPI(HREADYOUT_QSPI),
    .HREADY_QSPI(HREADY_QSPI),
    .HRESP_QSPI(HRESP_QSPI),

    .HSELx_ROM(HSELx_ROM),
    .HADDR_ROM(HADDR_ROM),
    .HTRANS_ROM(HTRANS_ROM),
    .HWRITE_ROM(HWRITE_ROM),
    .HSIZE_ROM(HSIZE_ROM),
    .HBURST_ROM(),
    .HPROT_ROM(),
    .HWDATA_ROM(HWDATA_ROM),
    .HRDATA_ROM(HRDATA_ROM),
    .HREADYOUT_ROM(HREADYOUT_ROM),
    .HREADY_ROM(HREADY_ROM),
    .HRESP_ROM(HRESP_ROM),

    .PADDR_DMA_CFG(PADDR_DMA_CFG),
    .PWDATA_DMA_CFG(PWDATA_DMA_CFG),
    .PWRITE_DMA_CFG(PWRITE_DMA_CFG),
    .PPROT_DMA_CFG(PPROT_DMA_CFG),
    .PSTRB_DMA_CFG(PSTRB_DMA_CFG),
    .PENABLE_DMA_CFG(PENABLE_DMA_CFG),
    .PSELx_DMA_CFG(PSELx_DMA_CFG),
    .PRDATA_DMA_CFG(PRDATA_DMA_CFG),
    .PSLVERR_DMA_CFG(PSLVERR_DMA_CFG),
    .PREADY_DMA_CFG(PREADY_DMA_CFG),

    .PADDR_QSPI_CFG(PADDR_QSPI_CFG),
    .PWDATA_QSPI_CFG(PWDATA_QSPI_CFG),
    .PWRITE_QSPI_CFG(PWRITE_QSPI_CFG),
    .PPROT_QSPI_CFG(PPROT_QSPI_CFG),
    .PSTRB_QSPI_CFG(PSTRB_QSPI_CFG),
    .PENABLE_QSPI_CFG(PENABLE_QSPI_CFG),
    .PSELx_QSPI_CFG(PSELx_QSPI_CFG),
    .PRDATA_QSPI_CFG(PRDATA_QSPI_CFG),
    .PSLVERR_QSPI_CFG(PSLVERR_QSPI_CFG),
    .PREADY_QSPI_CFG(PREADY_QSPI_CFG),

    .HADDR_ADP(ADP_AHB.HADDR),
    .HTRANS_ADP(ADP_AHB.HTRANS),
    .HWRITE_ADP(ADP_AHB.HWRITE),
    .HSIZE_ADP(ADP_AHB.HSIZE),
    .HBURST_ADP(ADP_AHB.HBURST),
    .HPROT_ADP(ADP_AHB.HPROT),
    .HWDATA_ADP(ADP_AHB.HWDATA),
    .HRDATA_ADP(ADP_AHB.HRDATA),
    .HREADY_ADP(ADP_AHB.HREADY),
    .HRESP_ADP(ADP_AHB.HRESP),

    .AWID_CM7(CPU_AWID),
    .AWADDR_CM7(CPU_AWADDR),
    .AWLEN_CM7(CPU_AWLEN),
    .AWSIZE_CM7(CPU_AWSIZE),
    .AWBURST_CM7(CPU_AWBURST),
    .AWLOCK_CM7(CPU_AWLOCK),
    .AWCACHE_CM7(CPU_AWCACHE),
    .AWPROT_CM7(CPU_AWPROT),
    .AWVALID_CM7(CPU_AWVALID),
    .AWREADY_CM7(CPU_AWREADY),
    .WDATA_CM7(CPU_WDATA),
    .WSTRB_CM7(CPU_WSTRB),
    .WLAST_CM7(CPU_WLAST),
    .WVALID_CM7(CPU_WVALID),
    .WREADY_CM7(CPU_WREADY),
    .BID_CM7(CPU_BID),
    .BRESP_CM7(CPU_BRESP),
    .BVALID_CM7(CPU_BVALID),
    .BREADY_CM7(CPU_BREADY),
    .ARID_CM7(CPU_ARID),
    .ARADDR_CM7(CPU_ARADDR),
    .ARLEN_CM7(CPU_ARLEN),
    .ARSIZE_CM7(CPU_ARSIZE),
    .ARBURST_CM7(CPU_ARBURST),
    .ARLOCK_CM7(CPU_ARLOCK),
    .ARCACHE_CM7(CPU_ARCACHE),
    .ARPROT_CM7(CPU_ARPROT),
    .ARVALID_CM7(CPU_ARVALID),
    .ARREADY_CM7(CPU_ARREADY),
    .RID_CM7(CPU_RID),
    .RDATA_CM7(CPU_RDATA),
    .RRESP_CM7(CPU_RRESP),
    .RLAST_CM7(CPU_RLAST),
    .RVALID_CM7(CPU_RVALID),
    .RREADY_CM7(CPU_RREADY),

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

endmodule
