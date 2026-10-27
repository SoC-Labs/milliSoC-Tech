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
//  millisoc_rt_cpu_subsystem       (u_millisoc_rt_cpu_ss)
//  ada_top_sldma350                (u_dma350)
//  millisoc_peripheral_subsystem   (u_millisoc_peripheral_subsystem)
//  millisoc_rt_peripheral_subsystem(u_rt_peripheral)
//  top_ahb_qspi                    (u_ahb_qspi)
//  ROM_wrapper                     (u_ROM_wrapper)
//  nic400_millisoc_main            (u_nic400_millisoc_main)

module millisoc_system(
    input  wire             FCLK,
    input  wire             nPORESET,

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
    output wire [15:0]      P1_FUNC,

    // M85 ITM trace output through the CoreSight TPIU
    output wire             TRACECLK,
    output wire [3:0]       TRACEDATA,
    output wire             TRACECTL
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
apb4_if DEBUG_APB();
apb4_if U85_CFG_APB();

axi4_if #(.DATA_W(128), .ID_W(6), .ADDR_W(40)) U85_SRAM0_AXI();
axi4_if #(.DATA_W(128), .ID_W(6), .ADDR_W(40)) U85_SRAM1_AXI();
axi4_if #(.DATA_W(128), .ID_W(6), .ADDR_W(40)) U85_EXT0_AXI();

axi4_if #(.DATA_W(64), .ID_W(10), .ADDR_W(32)) SRAM_AXI();

qchannel SRAM_qchan_q();
qchannel SRAM_qchan_p();

assign SRAM_qchan_p.qreqn=1'b1;
assign SRAM_qchan_q.qreqn=1'b1;

wire U85_IRQ;
wire U85_APB_pwakeup;
wire U85_AWAKEUP_SRAM0;
wire U85_AWAKEUP_SRAM1;
wire U85_AWAKEUP_EXT0;
wire [1:0] U85_AWDOMAIN_SRAM0;
wire [1:0] U85_ARDOMAIN_SRAM0;
wire [1:0] U85_AWDOMAIN_SRAM1;
wire [1:0] U85_ARDOMAIN_SRAM1;
wire [1:0] U85_AWDOMAIN_EXT0;
wire [1:0] U85_ARDOMAIN_EXT0;

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
axi4_if #(.DATA_W(64), .ID_W(2), .ADDR_W(32)) DEBUG_AXI();

axi3_if #(.DATA_W(64), .ID_W(3), .ADDR_W(32)) CPU_Rx_S_AXI();
axi3_if #(.DATA_W(32), .ID_W(4), .ADDR_W(32)) Rx_PERI_AXI();

// - APB for MHUs
apb4_if RT_MHU_SND();
apb4_if RT_MHU_REC();
apb4_if MX_MHU_SND();
apb4_if MX_MHU_REC();

reg    RT_MHU_SND_pwakeup;
reg    RT_MHU_REC_pwakeup;
reg    MX_MHU_SND_pwakeup;
reg    MX_MHU_REC_pwakeup;

always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET)
        RT_MHU_SND_pwakeup<=1'b0;
    else begin
        if(!RT_MHU_SND_pwakeup && RT_MHU_SND.psel)
            RT_MHU_SND_pwakeup<=1'b1;
        if(RT_MHU_SND_pwakeup && RT_MHU_SND.pready && !RT_MHU_SND.psel)
            RT_MHU_SND_pwakeup<=1'b0;
    end
end

always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET)
        RT_MHU_REC_pwakeup<=1'b0;
    else begin
        if(!RT_MHU_REC_pwakeup && RT_MHU_REC.psel)
            RT_MHU_REC_pwakeup<=1'b1;
        if(RT_MHU_REC_pwakeup && RT_MHU_REC.pready && !RT_MHU_REC.psel)
            RT_MHU_REC_pwakeup<=1'b0;
    end
end

always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET)
        MX_MHU_SND_pwakeup<=1'b0;
    else begin
        if(!MX_MHU_SND_pwakeup && MX_MHU_SND.psel)
            MX_MHU_SND_pwakeup<=1'b1;
        if(MX_MHU_SND_pwakeup && MX_MHU_SND.pready && !MX_MHU_SND.psel)
            MX_MHU_SND_pwakeup<=1'b0;
    end
end

always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET)
        MX_MHU_REC_pwakeup<=1'b0;
    else begin
        if(!MX_MHU_REC_pwakeup && MX_MHU_REC.psel)
            MX_MHU_REC_pwakeup<=1'b1;
        if(MX_MHU_REC_pwakeup && MX_MHU_REC.pready && !MX_MHU_REC.psel)
            MX_MHU_REC_pwakeup<=1'b0;
    end
end

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
wire        ARESETn;
wire        WDOGRESREQ;

// Debug subsystem (Arm CoreSight SoC-400)
wire        DAP_PWUPREQ;
wire        R5_DBG_PSEL;
wire        R5_DBG_PENABLE;
wire        R5_DBG_PWRITE;
wire [11:2] R5_DBG_PADDR;
wire        R5_DBG_PADDR31;
wire [31:0] R5_DBG_PWDATA;
wire [31:0] R5_DBG_PRDATA;
wire        R5_DBG_PREADY;
wire        R5_DBG_PSLVERR;
wire [31:0] M85_DBG_HADDR;
wire [ 1:0] M85_DBG_HTRANS;
wire        M85_DBG_HWRITE;
wire [ 2:0] M85_DBG_HSIZE;
wire [ 6:0] M85_DBG_HPROT;
wire [31:0] M85_DBG_HWDATA;
wire [31:0] M85_DBG_HRDATA;
wire        M85_DBG_HREADY;
wire [ 1:0] M85_DBG_HRESP;
wire        M85_DBG_PSEL;
wire        M85_DBG_PENABLE;
wire        M85_DBG_PWRITE;
wire [19:2] M85_DBG_PADDR;
wire        M85_DBG_PADDR31;
wire [ 2:0] M85_DBG_PPROT;
wire [ 3:0] M85_DBG_PSTRB;
wire [31:0] M85_DBG_PWDATA;
wire [31:0] M85_DBG_PRDATA;
wire        M85_DBG_PREADY;
wire        M85_DBG_PSLVERR;
wire [ 6:0] M85_TRACE_ATID;
wire [ 7:0] M85_TRACE_ATDATA;
wire        M85_TRACE_ATVALID;
wire        M85_TRACE_AFREADY;
wire        M85_TRACE_ATREADY;
wire        M85_TRACE_AFVALID;
wire        M85_TRACE_SYNCREQ;
wire [ 6:0] M85_ETM_TRACE_ATID;
wire [ 7:0] M85_ETM_TRACE_ATDATA;
wire        M85_ETM_TRACE_ATVALID;
wire        M85_ETM_TRACE_AFREADY;
wire        M85_ETM_TRACE_ATREADY;
wire        M85_ETM_TRACE_AFVALID;
wire        M85_ETM_TRACE_SYNCREQ;

wire        R5_DBGACK;
wire        R5_EDBGRQ;
wire [13:0] R5_ETM_ICTL;
wire [31:1] R5_ETM_IA;
wire [11:0] R5_ETM_DCTL;
wire [31:0] R5_ETM_DA;
wire [63:0] R5_ETM_DD;
wire [31:0] R5_ETM_CID;
wire        R5_ETM_WFIPENDING;
wire [54:0] R5_EVNTBUS;
wire        R5_ETM_PWRUP;
wire        R5_ETM_WFIREADY;
wire [1:0]  R5_ETM_EXTOUT;

// Interrupts
wire [63:0]     Rx_CPU_IRQs;
wire [3:0]      SYS_DMA_DONE_IRQ;
wire            SYS_DMA_COMB_IRQ;
wire            IRQ_QSPI_FINISHED;
wire [55:0]     Rx_PERI_IRQS;
wire            Rx_IPC_SND_err;
wire            Rx_IPC_SND_fault;
wire            Rx_IPC_SND_pbx;
wire            Mx_IPC_REC_fst_grp;
wire            Mx_IPC_REC_err;
wire            Mx_IPC_REC_fault;
wire            Mx_IPC_REC_mbx;

assign Rx_CPU_IRQs[1:0]=   SYS_DMA_DONE_IRQ[1:0];
assign Rx_CPU_IRQs[2]=     IRQ_QSPI_FINISHED;
assign Rx_CPU_IRQs[3]=     Rx_IPC_SND_err;
assign Rx_CPU_IRQs[4]=     Rx_IPC_SND_fault;
assign Rx_CPU_IRQs[5]=     Rx_IPC_SND_pbx;
assign Rx_CPU_IRQs[6]=     Mx_IPC_REC_fst_grp;
assign Rx_CPU_IRQs[7]=     Mx_IPC_REC_err;
assign Rx_CPU_IRQs[8]=     Mx_IPC_REC_fault;
assign Rx_CPU_IRQs[9]=     Mx_IPC_REC_mbx;
assign Rx_CPU_IRQs[63:10]= Rx_PERI_IRQS[55:2];

// M class interrupts
wire [239:0]    Mx_CPU_IRQs;
wire [55:0]     Mx_PERI_IRQS;
wire            Mx_IPC_SND_err;
wire            Mx_IPC_SND_fault;
wire            Mx_IPC_SND_pbx;
wire            RT_IPC_REC_fst_grp;
wire            RT_IPC_REC_err;
wire            RT_IPC_REC_fault;
wire            RT_IPC_REC_mbx;

assign Mx_CPU_IRQs[1:0]=    SYS_DMA_DONE_IRQ[3:2];
assign Mx_CPU_IRQs[2]=      Mx_IPC_SND_err;
assign Mx_CPU_IRQs[3]=      Mx_IPC_SND_fault;
assign Mx_CPU_IRQs[4]=      Mx_IPC_SND_pbx;
assign Mx_CPU_IRQs[5]=      RT_IPC_REC_fst_grp;
assign Mx_CPU_IRQs[6]=      RT_IPC_REC_err;
assign Mx_CPU_IRQs[7]=      RT_IPC_REC_fault;
assign Mx_CPU_IRQs[8]=      RT_IPC_REC_mbx;
assign Mx_CPU_IRQs[64:9]=   Mx_PERI_IRQS;

assign Mx_CPU_IRQs[65] = U85_IRQ;
assign Mx_CPU_IRQs[239:66] = 174'd0;

reg U85_APB_pwakeup_reg;
assign U85_APB_pwakeup = U85_APB_pwakeup_reg;

always @(posedge FCLK or negedge nPORESET) begin
    if (!nPORESET)
        U85_APB_pwakeup_reg <= 1'b0;
    else begin
        if (!U85_APB_pwakeup_reg && U85_CFG_APB.psel)
            U85_APB_pwakeup_reg <= 1'b1;
        if (U85_APB_pwakeup_reg && U85_CFG_APB.pready && !U85_CFG_APB.psel)
            U85_APB_pwakeup_reg <= 1'b0;
    end
end

// Tie offs (may be used later)
assign PCLKEN_DMA = 1'b1;
assign CLKEN = 1'b1;
assign FCLKEN = 1'b1;
assign HCLKEN = 1'b1;
assign ETMCLKEN = 1'b1;
assign nDBGETMRESET = nPORESET;
assign TRACECLKIN = FCLK;
assign CPU_ACLKEN  = 1'b1;
assign HCLK = FCLK;
assign PCLK = FCLK;
assign ACLK = FCLK;
assign HRESETn = nPORESET;
assign PRESETn = nPORESET;
assign ARESETn = nPORESET;

millisoc_ai_subsystem u_millisoc_ai_subsystem (
    .FCLK(FCLK),
    .nRESET(nSYSRESET),
    .PWAKEUP(U85_APB_pwakeup),
    .U85_CFG_APB(U85_CFG_APB),
    .U85_SRAM0_AXI(U85_SRAM0_AXI),
    .U85_SRAM1_AXI(U85_SRAM1_AXI),
    .U85_EXT0_AXI(U85_EXT0_AXI),
    .IRQ(U85_IRQ),
    .AWAKEUPSRAM0(U85_AWAKEUP_SRAM0),
    .AWAKEUPSRAM1(U85_AWAKEUP_SRAM1),
    .AWAKEUPEXT0(U85_AWAKEUP_EXT0),
    .AWDOMAINSRAM0(U85_AWDOMAIN_SRAM0),
    .ARDOMAINSRAM0(U85_ARDOMAIN_SRAM0),
    .AWDOMAINSRAM1(U85_AWDOMAIN_SRAM1),
    .ARDOMAINSRAM1(U85_ARDOMAIN_SRAM1),
    .AWDOMAINEXT0(U85_AWDOMAIN_EXT0),
    .ARDOMAINEXT0(U85_ARDOMAIN_EXT0)
);

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
    .TRACE_ATREADY(M85_TRACE_ATREADY),
    .TRACE_AFVALID(M85_TRACE_AFVALID),
    .TRACE_SYNCREQ(M85_TRACE_SYNCREQ),
    .TRACE_ATID(M85_TRACE_ATID),
    .TRACE_ATDATA(M85_TRACE_ATDATA),
    .TRACE_ATVALID(M85_TRACE_ATVALID),
    .TRACE_AFREADY(M85_TRACE_AFREADY),
    .TRACE_ETM_ATREADY(M85_ETM_TRACE_ATREADY),
    .TRACE_ETM_AFVALID(M85_ETM_TRACE_AFVALID),
    .TRACE_ETM_SYNCREQ(M85_ETM_TRACE_SYNCREQ),
    .TRACE_ETM_ATID(M85_ETM_TRACE_ATID),
    .TRACE_ETM_ATDATA(M85_ETM_TRACE_ATDATA),
    .TRACE_ETM_ATVALID(M85_ETM_TRACE_ATVALID),
    .TRACE_ETM_AFREADY(M85_ETM_TRACE_AFREADY),

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

    // Debug (EPPB) AHB slave port of the Cortex-M85
    .DBG_HADDR(M85_DBG_HADDR),
    .DBG_HTRANS(M85_DBG_HTRANS),
    .DBG_HWRITE(M85_DBG_HWRITE),
    .DBG_HSIZE(M85_DBG_HSIZE),
    .DBG_HPROT(M85_DBG_HPROT),
    .DBG_HWDATA(M85_DBG_HWDATA),
    .DBG_HRDATA(M85_DBG_HRDATA),
    .DBG_HREADY(M85_DBG_HREADY),
    .DBG_HRESP(M85_DBG_HRESP),
    .DBG_PSEL(M85_DBG_PSEL),
    .DBG_PENABLE(M85_DBG_PENABLE),
    .DBG_PWRITE(M85_DBG_PWRITE),
    .DBG_PADDR(M85_DBG_PADDR),
    .DBG_PADDR31(M85_DBG_PADDR31),
    .DBG_PPROT(M85_DBG_PPROT),
    .DBG_PSTRB(M85_DBG_PSTRB),
    .DBG_PWDATA(M85_DBG_PWDATA),
    .DBG_PRDATA(M85_DBG_PRDATA),
    .DBG_PREADY(M85_DBG_PREADY),
    .DBG_PSLVERR(M85_DBG_PSLVERR),

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

    .IRQ(Mx_CPU_IRQs)
);

//-----------------------------------------------------------------------------
// Debug subsystem - Arm CoreSight SoC-400
//
//  A single SWJ debug port at the chip boundary fans out to four access
//  ports:
//
//    AP0 : APB-AP -> APB interconnect (CoreSight debug peripherals)
//    AP1 : AXI-AP -> NIC400 "DEBUG" port (system memory and peripherals)
//    AP2 : APB-AP -> Cortex-R5 external debug interface
//    AP3 : AHB-AP -> Cortex-M85 EPPB (core debug registers)
//-----------------------------------------------------------------------------
millisoc_debug_subsystem u_millisoc_debug_subsystem (

    // ---- Clock and reset ----
    .dapclk(FCLK),
    .dapclken(1'b1),
    .dapresetn(nPORESET),
    .poresetn(nPORESET),
    .traceclkin(TRACECLKIN),

    // ---- SWD / JTAG pad interface ----
    .swclktck(SWCLKTCK),
    .swditms(SWDITMS),
    .tdi(TDI),
    .ntrst(nTRST),
    .swdo(SWDO),
    .swdoen(SWDOEN),
    .tdo(TDO),
    .ntdoen(nTDOEN),

    // ---- AP1 : AXI4 master -> NIC400 DEBUG port ----
    .dap_awaddr(DEBUG_AXI.AWADDR),
    .dap_awlen(DEBUG_AXI.AWLEN),
    .dap_awsize(DEBUG_AXI.AWSIZE),
    .dap_awburst(DEBUG_AXI.AWBURST),
    .dap_awlock(DEBUG_AXI.AWLOCK),
    .dap_awcache(DEBUG_AXI.AWCACHE),
    .dap_awprot(DEBUG_AXI.AWPROT),
    .dap_awvalid(DEBUG_AXI.AWVALID),
    .dap_awready(DEBUG_AXI.AWREADY),
    .dap_wdata(DEBUG_AXI.WDATA),
    .dap_wstrb(DEBUG_AXI.WSTRB),
    .dap_wlast(DEBUG_AXI.WLAST),
    .dap_wvalid(DEBUG_AXI.WVALID),
    .dap_wready(DEBUG_AXI.WREADY),
    .dap_bresp(DEBUG_AXI.BRESP),
    .dap_bvalid(DEBUG_AXI.BVALID),
    .dap_bready(DEBUG_AXI.BREADY),
    .dap_araddr(DEBUG_AXI.ARADDR),
    .dap_arlen(DEBUG_AXI.ARLEN),
    .dap_arsize(DEBUG_AXI.ARSIZE),
    .dap_arburst(DEBUG_AXI.ARBURST),
    .dap_arlock(DEBUG_AXI.ARLOCK),
    .dap_arcache(DEBUG_AXI.ARCACHE),
    .dap_arprot(DEBUG_AXI.ARPROT),
    .dap_arvalid(DEBUG_AXI.ARVALID),
    .dap_arready(DEBUG_AXI.ARREADY),
    .dap_rdata(DEBUG_AXI.RDATA),
    .dap_rresp(DEBUG_AXI.RRESP),
    .dap_rlast(DEBUG_AXI.RLAST),
    .dap_rvalid(DEBUG_AXI.RVALID),
    .dap_rready(DEBUG_AXI.RREADY),

    // ---- CPU/system bus APB access to the CoreSight APBIC -----------------
    .sys_paddr(DEBUG_APB.paddr),
    .sys_pwdata(DEBUG_APB.pwdata),
    .sys_psel(DEBUG_APB.psel),
    .sys_penable(DEBUG_APB.penable),
    .sys_pwrite(DEBUG_APB.pwrite),
    .sys_prdata(DEBUG_APB.prdata),
    .sys_pready(DEBUG_APB.pready),
    .sys_pslverr(DEBUG_APB.pslverr),

    // ---- M85 EPPB APB master -> CoreSight APBIC ----------------------------
    .m85_paddr({M85_DBG_PADDR31, 11'b0, M85_DBG_PADDR, 2'b00}),
    .m85_pwdata(M85_DBG_PWDATA),
    .m85_psel(M85_DBG_PSEL),
    .m85_penable(M85_DBG_PENABLE),
    .m85_pwrite(M85_DBG_PWRITE),
    .m85_prdata(M85_DBG_PRDATA),
    .m85_pready(M85_DBG_PREADY),
    .m85_pslverr(M85_DBG_PSLVERR),
    .m85_trace_atid(M85_TRACE_ATID),
    .m85_trace_atdata(M85_TRACE_ATDATA),
    .m85_trace_atvalid(M85_TRACE_ATVALID),
    .m85_trace_afready(M85_TRACE_AFREADY),
    .m85_trace_atready(M85_TRACE_ATREADY),
    .m85_trace_afvalid(M85_TRACE_AFVALID),
    .m85_trace_syncreq(M85_TRACE_SYNCREQ),
    .m85_etm_atid(M85_ETM_TRACE_ATID),
    .m85_etm_atdata(M85_ETM_TRACE_ATDATA),
    .m85_etm_atvalid(M85_ETM_TRACE_ATVALID),
    .m85_etm_afready(M85_ETM_TRACE_AFREADY),
    .m85_etm_atready(M85_ETM_TRACE_ATREADY),
    .m85_etm_afvalid(M85_ETM_TRACE_AFVALID),
    .m85_etm_syncreq(M85_ETM_TRACE_SYNCREQ),
    .traceclk(TRACECLK),
    .tracedata(TRACEDATA),
    .tracectl(TRACECTL),

    // ---- AP2 : APB master -> Cortex-R5 external debug interface ----
    .r5_psel(R5_DBG_PSEL),
    .r5_paddr(R5_DBG_PADDR),
    .r5_paddr31(R5_DBG_PADDR31),
    .r5_penable(R5_DBG_PENABLE),
    .r5_pwrite(R5_DBG_PWRITE),
    .r5_pwdata(R5_DBG_PWDATA),
    .r5_prdata(R5_DBG_PRDATA),
    .r5_pready(R5_DBG_PREADY),
    .r5_pslverr(R5_DBG_PSLVERR),
    .r5_dbgack(R5_DBGACK),
    .r5_edbgrq(R5_EDBGRQ),
    .r5_etm_ictl(R5_ETM_ICTL),
    .r5_etm_ia(R5_ETM_IA),
    .r5_etm_dctl(R5_ETM_DCTL),
    .r5_etm_da(R5_ETM_DA),
    .r5_etm_dd(R5_ETM_DD),
    .r5_etm_cid(R5_ETM_CID),
    .r5_etm_wfipending(R5_ETM_WFIPENDING),
    .r5_evntbus(R5_EVNTBUS),
    .r5_etm_pwrup(R5_ETM_PWRUP),
    .r5_etm_wfiready(R5_ETM_WFIREADY),
    .r5_etm_extout(R5_ETM_EXTOUT),

    // ---- AP3 : AHB master -> Cortex-M85 EPPB ----
    .m85_haddr(M85_DBG_HADDR),
    .m85_htrans(M85_DBG_HTRANS),
    .m85_hwrite(M85_DBG_HWRITE),
    .m85_hsize(M85_DBG_HSIZE),
    .m85_hprot(M85_DBG_HPROT),
    .m85_hwdata(M85_DBG_HWDATA),
    .m85_hrdata(M85_DBG_HRDATA),
    .m85_hready(M85_DBG_HREADY),
    .m85_hresp(M85_DBG_HRESP),

    // ---- Debug power-up request ----
    .dap_pwrupreq(DAP_PWUPREQ)
);

// The AXI access port does not generate AXI IDs, so the IDs on the NIC400
// DEBUG port are tied off.
assign DEBUG_AXI.AWID = 2'b00;
assign DEBUG_AXI.ARID = 2'b00;

mhu320ae_mx u_ipc_mx (
    .clk(FCLK),
    .reset_n(nSYSRESET),

    .dftcgen(1'b0),
    .dftrstdisable(1'b0),
    .dftramhold(1'b0),

    .clkqreqn(1'b1),
    .clkqacceptn(),
    .clkqdeny(),
    .clkqactive(),

    .pwrqreqn(1'b1),
    .pwrqacceptn(),
    .pwrqdeny(),
    .pwrqactive(),

    .paddr_snd(MX_MHU_SND.paddr),
    .pprot_snd(MX_MHU_SND.pprot),
    .pnse_snd(1'b0),
    .psel_snd(MX_MHU_SND.psel),
    .penable_snd(MX_MHU_SND.penable),
    .pwrite_snd(MX_MHU_SND.pwrite),
    .pwdata_snd(MX_MHU_SND.pwdata),
    .pstrb_snd(MX_MHU_SND.pstrb),
    .pready_snd(MX_MHU_SND.pready),
    .prdata_snd(MX_MHU_SND.prdata),
    .pslverr_snd(MX_MHU_SND.pslverr),
    .pwakeup_snd(MX_MHU_SND_pwakeup),

    .paddr_rec(MX_MHU_REC.paddr),
    .pprot_rec(MX_MHU_REC.pprot),
    .pnse_rec(1'b0),
    .psel_rec(MX_MHU_REC.psel),
    .penable_rec(MX_MHU_REC.penable),
    .pwrite_rec(MX_MHU_REC.pwrite),
    .pwdata_rec(MX_MHU_REC.pwdata),
    .pstrb_rec(MX_MHU_REC.pstrb),
    .pready_rec(MX_MHU_REC.pready),
    .prdata_rec(MX_MHU_REC.prdata),
    .pslverr_rec(MX_MHU_REC.pslverr),
    .pwakeup_rec(MX_MHU_REC_pwakeup),

    .mbistreq(1'b0),
    .mbistack(),
    .mbistaddr(),
    .mbistarray(),
    .mbistreaden(),
    .mbistwriteen(),
    .mbistindata(),
    .mbistoutdata(),
    .mbistcfg(),
    .nmbistreset(1'b1),

    .snd_err_int(Mx_IPC_SND_err),
    .snd_fault_int(Mx_IPC_SND_fault),
    .pbx_int(Mx_IPC_SND_pbx),

    .rec_fst_tfr_grp_int(Mx_IPC_REC_fst_grp),
    .rec_err_int(Mx_IPC_REC_err),
    .rec_fault_int(Mx_IPC_REC_fault),
    .mbx_int(Mx_IPC_REC_mbx)
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

wire [4:0]  CPU_Rx_S_BID_unused;
wire [4:0]  CPU_Rx_S_RID_unused;

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
    .AWIDS0({5'h00, CPU_Rx_S_AXI.AWID}),
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
    .WIDS0({5'h00, CPU_Rx_S_AXI.WID}),
    .WDATAS0(CPU_Rx_S_AXI.WDATA),
    .WSTRBS0(CPU_Rx_S_AXI.WSTRB),
    .WLASTS0(CPU_Rx_S_AXI.WLAST),
    .WVALIDS0(CPU_Rx_S_AXI.WVALID),
    .WVPTYS0(1'b0),
    .WREADYS0(CPU_Rx_S_AXI.WREADY),
    .WRPTYS0(),
    .BIDS0({CPU_Rx_S_BID_unused, CPU_Rx_S_AXI.BID}),
    .BRESPS0(CPU_Rx_S_AXI.BRESP),
    .BVALIDS0(CPU_Rx_S_AXI.BVALID),
    .BVPTYS0(),
    .BREADYS0(CPU_Rx_S_AXI.BREADY),
    .BRPTYS0(1'b0),
    .ARIDS0({5'h00,CPU_Rx_S_AXI.ARID}),
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
    .RIDS0({CPU_Rx_S_RID_unused, CPU_Rx_S_AXI.RID}),
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
    // PCLKENDBG must be asserted for the external debug APB interface to
    // accept accesses: with the enable low the R5 does not load the debug
    // read data register and ignores debug writes.  There is no dynamic
    // debug clock gating in this SoC, so the enable is tied high.
    .PCLKENDBG(1'b1),
    .DBGROMADDR(20'b0),
    .DBGROMADDRV(1'b0),
    .DBGNOPWRDWN(),

    .DBGEN0(1'b0),
    // Non-invasive debug is enabled to permit ETM trace; invasive debug stays off.
    .NIDEN0(1'b1),
    .EDBGRQ0(R5_EDBGRQ),
    .DBGTRIGGER0(),
    .DBGACK0(R5_DBGACK),
    .COMMRX0(),
    .COMMTX0(),
    .PSELDBG0(R5_DBG_PSEL),
    .PADDRDBG0(R5_DBG_PADDR),
    .PADDRDBG310(R5_DBG_PADDR31),
    .PRDATADBG0(R5_DBG_PRDATA),
    .PWDATADBG0(R5_DBG_PWDATA),
    .PENABLEDBG0(R5_DBG_PENABLE),
    .PREADYDBG0(R5_DBG_PREADY),
    .PSLVERRDBG0(R5_DBG_PSLVERR),
    .PWRITEDBG0(R5_DBG_PWRITE),
    .DBGSELFADDR0(20'b0),
    .DBGSELFADDRV0(1'b0),
    .DBGRESTART0(1'b0),
    .DBGRESTARTED0(),
    .DBGRSTREQ0(),

    // ETM
    .ETMICTL0(R5_ETM_ICTL),
    .ETMIA0(R5_ETM_IA),
    .ETMDCTL0(R5_ETM_DCTL),
    .ETMDA0(R5_ETM_DA),
    .ETMDD0(R5_ETM_DD),
    .ETMCID0(R5_ETM_CID),
    .ETMWFIPENDING0(R5_ETM_WFIPENDING),
    .EVNTBUS0(R5_EVNTBUS),
    .ETMPWRUP0(R5_ETM_PWRUP),
    .nETMWFIREADY0(R5_ETM_WFIREADY),
    .ETMEXTOUT0(R5_ETM_EXTOUT),

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
    .HADDR_GIC(CPU_Rx_GIC_AHB.HADDR[12:2]),
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

mhu320ae_rt u_ipc_rt (
    .clk(FCLK),
    .reset_n(nSYSRESET),

    .dftcgen(1'b0),
    .dftrstdisable(1'b0),
    .dftramhold(1'b0),

    .clkqreqn(1'b1),
    .clkqacceptn(),
    .clkqdeny(),
    .clkqactive(),

    .pwrqreqn(1'b1),
    .pwrqacceptn(),
    .pwrqdeny(),
    .pwrqactive(),

    .paddr_snd(RT_MHU_SND.paddr),
    .pprot_snd(RT_MHU_SND.pprot),
    .pnse_snd(1'b0),
    .psel_snd(RT_MHU_SND.psel),
    .penable_snd(RT_MHU_SND.penable),
    .pwrite_snd(RT_MHU_SND.pwrite),
    .pwdata_snd(RT_MHU_SND.pwdata),
    .pstrb_snd(RT_MHU_SND.pstrb),
    .pready_snd(RT_MHU_SND.pready),
    .prdata_snd(RT_MHU_SND.prdata),
    .pslverr_snd(RT_MHU_SND.pslverr),
    .pwakeup_snd(RT_MHU_SND_pwakeup),

    .paddr_rec(RT_MHU_REC.paddr),
    .pprot_rec(RT_MHU_REC.pprot),
    .pnse_rec(1'b0),
    .psel_rec(RT_MHU_REC.psel),
    .penable_rec(RT_MHU_REC.penable),
    .pwrite_rec(RT_MHU_REC.pwrite),
    .pwdata_rec(RT_MHU_REC.pwdata),
    .pstrb_rec(RT_MHU_REC.pstrb),
    .pready_rec(RT_MHU_REC.pready),
    .prdata_rec(RT_MHU_REC.prdata),
    .pslverr_rec(RT_MHU_REC.pslverr),
    .pwakeup_rec(RT_MHU_REC_pwakeup),

    .mbistreq(1'b0),
    .mbistack(),
    .mbistaddr(),
    .mbistarray(),
    .mbistreaden(),
    .mbistwriteen(),
    .mbistindata(),
    .mbistoutdata(),
    .mbistcfg(),
    .nmbistreset(1'b1),

    .snd_err_int(Rx_IPC_SND_err),
    .snd_fault_int(Rx_IPC_SND_fault),
    .pbx_int(Rx_IPC_SND_pbx),

    .rec_fst_tfr_grp_int(RT_IPC_REC_fst_grp),
    .rec_err_int(RT_IPC_REC_err),
    .rec_fault_int(RT_IPC_REC_fault),
    .mbx_int(RT_IPC_REC_mbx)
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
    .MHU_REC(RT_MHU_REC),
    .MHU_SND(MX_MHU_SND),

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

    .PERI_IRQS(Mx_PERI_IRQS)
);

millisoc_rt_peripheral_subsystem u_rt_peripheral(
    .CLK(FCLK),
    .PORESETn(nPORESET),
    .SYSRESETn(nSYSRESET),

    .AXI_PERIPH(Rx_PERI_AXI),

    .MHU_SND(RT_MHU_SND),
    .MHU_REC(MX_MHU_REC),

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

millisoc_sram_wrapper #(.ID_W(10)) u_sram_wrapper(
    .ACLK(FCLK),
    .ARESETn(nSYSRESET),
    .SRAM_AXI(SRAM_AXI),
    .AWAKEUP(1'b1),
    .SRAM_qchan_q(SRAM_qchan_q),
    .SRAM_qchan_p(SRAM_qchan_p),
    .cfg_gate_resp(1'b0)
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

    .AWID_SHARED_SRAM(SRAM_AXI.AWID),
    .AWADDR_SHARED_SRAM(SRAM_AXI.AWADDR),
    .AWLEN_SHARED_SRAM(SRAM_AXI.AWLEN),
    .AWSIZE_SHARED_SRAM(SRAM_AXI.AWSIZE),
    .AWBURST_SHARED_SRAM(SRAM_AXI.AWBURST),
    .AWLOCK_SHARED_SRAM(SRAM_AXI.AWLOCK),
    .AWCACHE_SHARED_SRAM(SRAM_AXI.AWCACHE),
    .AWPROT_SHARED_SRAM(SRAM_AXI.AWPROT),
    .AWVALID_SHARED_SRAM(SRAM_AXI.AWVALID),
    .AWREADY_SHARED_SRAM(SRAM_AXI.AWREADY),
    .WDATA_SHARED_SRAM(SRAM_AXI.WDATA),
    .WSTRB_SHARED_SRAM(SRAM_AXI.WSTRB),
    .WLAST_SHARED_SRAM(SRAM_AXI.WLAST),
    .WVALID_SHARED_SRAM(SRAM_AXI.WVALID),
    .WREADY_SHARED_SRAM(SRAM_AXI.WREADY),
    .BID_SHARED_SRAM(SRAM_AXI.BID),
    .BRESP_SHARED_SRAM(SRAM_AXI.BRESP),
    .BVALID_SHARED_SRAM(SRAM_AXI.BVALID),
    .BREADY_SHARED_SRAM(SRAM_AXI.BREADY),
    .ARID_SHARED_SRAM(SRAM_AXI.ARID),
    .ARADDR_SHARED_SRAM(SRAM_AXI.ARADDR),
    .ARLEN_SHARED_SRAM(SRAM_AXI.ARLEN),
    .ARSIZE_SHARED_SRAM(SRAM_AXI.ARSIZE),
    .ARBURST_SHARED_SRAM(SRAM_AXI.ARBURST),
    .ARLOCK_SHARED_SRAM(SRAM_AXI.ARLOCK),
    .ARCACHE_SHARED_SRAM(SRAM_AXI.ARCACHE),
    .ARPROT_SHARED_SRAM(SRAM_AXI.ARPROT),
    .ARVALID_SHARED_SRAM(SRAM_AXI.ARVALID),
    .ARREADY_SHARED_SRAM(SRAM_AXI.ARREADY),
    .RID_SHARED_SRAM(SRAM_AXI.RID),
    .RDATA_SHARED_SRAM(SRAM_AXI.RDATA),
    .RRESP_SHARED_SRAM(SRAM_AXI.RRESP),
    .RLAST_SHARED_SRAM(SRAM_AXI.RLAST),
    .RVALID_SHARED_SRAM(SRAM_AXI.RVALID),
    .RREADY_SHARED_SRAM(SRAM_AXI.RREADY),

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

    .PADDR_DEBUG_S(DEBUG_APB.paddr),
    .PWDATA_DEBUG_S(DEBUG_APB.pwdata),
    .PWRITE_DEBUG_S(DEBUG_APB.pwrite),
    .PPROT_DEBUG_S(DEBUG_APB.pprot),
    .PSTRB_DEBUG_S(DEBUG_APB.pstrb),
    .PENABLE_DEBUG_S(DEBUG_APB.penable),
    .PSELx_DEBUG_S(DEBUG_APB.psel),
    .PRDATA_DEBUG_S(DEBUG_APB.prdata),
    .PSLVERR_DEBUG_S(DEBUG_APB.pslverr),
    .PREADY_DEBUG_S(DEBUG_APB.pready),

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

    .AWID_U85_SRAM0(U85_SRAM0_AXI.AWID),
    .AWADDR_U85_SRAM0(U85_SRAM0_AXI.AWADDR),
    .AWLEN_U85_SRAM0(U85_SRAM0_AXI.AWLEN),
    .AWSIZE_U85_SRAM0(U85_SRAM0_AXI.AWSIZE),
    .AWBURST_U85_SRAM0(U85_SRAM0_AXI.AWBURST),
    .AWLOCK_U85_SRAM0(U85_SRAM0_AXI.AWLOCK),
    .AWCACHE_U85_SRAM0(U85_SRAM0_AXI.AWCACHE),
    .AWPROT_U85_SRAM0(U85_SRAM0_AXI.AWPROT),
    .AWVALID_U85_SRAM0(U85_SRAM0_AXI.AWVALID),
    .AWREADY_U85_SRAM0(U85_SRAM0_AXI.AWREADY),
    .WDATA_U85_SRAM0(U85_SRAM0_AXI.WDATA),
    .WSTRB_U85_SRAM0(U85_SRAM0_AXI.WSTRB),
    .WLAST_U85_SRAM0(U85_SRAM0_AXI.WLAST),
    .WVALID_U85_SRAM0(U85_SRAM0_AXI.WVALID),
    .WREADY_U85_SRAM0(U85_SRAM0_AXI.WREADY),
    .BID_U85_SRAM0(U85_SRAM0_AXI.BID),
    .BRESP_U85_SRAM0(U85_SRAM0_AXI.BRESP),
    .BVALID_U85_SRAM0(U85_SRAM0_AXI.BVALID),
    .BREADY_U85_SRAM0(U85_SRAM0_AXI.BREADY),
    .ARID_U85_SRAM0(U85_SRAM0_AXI.ARID),
    .ARADDR_U85_SRAM0(U85_SRAM0_AXI.ARADDR),
    .ARLEN_U85_SRAM0(U85_SRAM0_AXI.ARLEN),
    .ARSIZE_U85_SRAM0(U85_SRAM0_AXI.ARSIZE),
    .ARBURST_U85_SRAM0(U85_SRAM0_AXI.ARBURST),
    .ARLOCK_U85_SRAM0(U85_SRAM0_AXI.ARLOCK),
    .ARCACHE_U85_SRAM0(U85_SRAM0_AXI.ARCACHE),
    .ARPROT_U85_SRAM0(U85_SRAM0_AXI.ARPROT),
    .ARVALID_U85_SRAM0(U85_SRAM0_AXI.ARVALID),
    .ARREADY_U85_SRAM0(U85_SRAM0_AXI.ARREADY),
    .RID_U85_SRAM0(U85_SRAM0_AXI.RID),
    .RDATA_U85_SRAM0(U85_SRAM0_AXI.RDATA),
    .RRESP_U85_SRAM0(U85_SRAM0_AXI.RRESP),
    .RLAST_U85_SRAM0(U85_SRAM0_AXI.RLAST),
    .RVALID_U85_SRAM0(U85_SRAM0_AXI.RVALID),
    .RREADY_U85_SRAM0(U85_SRAM0_AXI.RREADY),

    .AWID_U85_SRAM1(U85_SRAM1_AXI.AWID),
    .AWADDR_U85_SRAM1(U85_SRAM1_AXI.AWADDR),
    .AWLEN_U85_SRAM1(U85_SRAM1_AXI.AWLEN),
    .AWSIZE_U85_SRAM1(U85_SRAM1_AXI.AWSIZE),
    .AWBURST_U85_SRAM1(U85_SRAM1_AXI.AWBURST),
    .AWLOCK_U85_SRAM1(U85_SRAM1_AXI.AWLOCK),
    .AWCACHE_U85_SRAM1(U85_SRAM1_AXI.AWCACHE),
    .AWPROT_U85_SRAM1(U85_SRAM1_AXI.AWPROT),
    .AWVALID_U85_SRAM1(U85_SRAM1_AXI.AWVALID),
    .AWREADY_U85_SRAM1(U85_SRAM1_AXI.AWREADY),
    .WDATA_U85_SRAM1(U85_SRAM1_AXI.WDATA),
    .WSTRB_U85_SRAM1(U85_SRAM1_AXI.WSTRB),
    .WLAST_U85_SRAM1(U85_SRAM1_AXI.WLAST),
    .WVALID_U85_SRAM1(U85_SRAM1_AXI.WVALID),
    .WREADY_U85_SRAM1(U85_SRAM1_AXI.WREADY),
    .BID_U85_SRAM1(U85_SRAM1_AXI.BID),
    .BRESP_U85_SRAM1(U85_SRAM1_AXI.BRESP),
    .BVALID_U85_SRAM1(U85_SRAM1_AXI.BVALID),
    .BREADY_U85_SRAM1(U85_SRAM1_AXI.BREADY),
    .ARID_U85_SRAM1(U85_SRAM1_AXI.ARID),
    .ARADDR_U85_SRAM1(U85_SRAM1_AXI.ARADDR),
    .ARLEN_U85_SRAM1(U85_SRAM1_AXI.ARLEN),
    .ARSIZE_U85_SRAM1(U85_SRAM1_AXI.ARSIZE),
    .ARBURST_U85_SRAM1(U85_SRAM1_AXI.ARBURST),
    .ARLOCK_U85_SRAM1(U85_SRAM1_AXI.ARLOCK),
    .ARCACHE_U85_SRAM1(U85_SRAM1_AXI.ARCACHE),
    .ARPROT_U85_SRAM1(U85_SRAM1_AXI.ARPROT),
    .ARVALID_U85_SRAM1(U85_SRAM1_AXI.ARVALID),
    .ARREADY_U85_SRAM1(U85_SRAM1_AXI.ARREADY),
    .RID_U85_SRAM1(U85_SRAM1_AXI.RID),
    .RDATA_U85_SRAM1(U85_SRAM1_AXI.RDATA),
    .RRESP_U85_SRAM1(U85_SRAM1_AXI.RRESP),
    .RLAST_U85_SRAM1(U85_SRAM1_AXI.RLAST),
    .RVALID_U85_SRAM1(U85_SRAM1_AXI.RVALID),
    .RREADY_U85_SRAM1(U85_SRAM1_AXI.RREADY),

    .AWID_U85_EXT0(U85_EXT0_AXI.AWID),
    .AWADDR_U85_EXT0(U85_EXT0_AXI.AWADDR),
    .AWLEN_U85_EXT0(U85_EXT0_AXI.AWLEN),
    .AWSIZE_U85_EXT0(U85_EXT0_AXI.AWSIZE),
    .AWBURST_U85_EXT0(U85_EXT0_AXI.AWBURST),
    .AWLOCK_U85_EXT0(U85_EXT0_AXI.AWLOCK),
    .AWCACHE_U85_EXT0(U85_EXT0_AXI.AWCACHE),
    .AWPROT_U85_EXT0(U85_EXT0_AXI.AWPROT),
    .AWVALID_U85_EXT0(U85_EXT0_AXI.AWVALID),
    .AWREADY_U85_EXT0(U85_EXT0_AXI.AWREADY),
    .WDATA_U85_EXT0(U85_EXT0_AXI.WDATA),
    .WSTRB_U85_EXT0(U85_EXT0_AXI.WSTRB),
    .WLAST_U85_EXT0(U85_EXT0_AXI.WLAST),
    .WVALID_U85_EXT0(U85_EXT0_AXI.WVALID),
    .WREADY_U85_EXT0(U85_EXT0_AXI.WREADY),
    .BID_U85_EXT0(U85_EXT0_AXI.BID),
    .BRESP_U85_EXT0(U85_EXT0_AXI.BRESP),
    .BVALID_U85_EXT0(U85_EXT0_AXI.BVALID),
    .BREADY_U85_EXT0(U85_EXT0_AXI.BREADY),
    .ARID_U85_EXT0(U85_EXT0_AXI.ARID),
    .ARADDR_U85_EXT0(U85_EXT0_AXI.ARADDR),
    .ARLEN_U85_EXT0(U85_EXT0_AXI.ARLEN),
    .ARSIZE_U85_EXT0(U85_EXT0_AXI.ARSIZE),
    .ARBURST_U85_EXT0(U85_EXT0_AXI.ARBURST),
    .ARLOCK_U85_EXT0(U85_EXT0_AXI.ARLOCK),
    .ARCACHE_U85_EXT0(U85_EXT0_AXI.ARCACHE),
    .ARPROT_U85_EXT0(U85_EXT0_AXI.ARPROT),
    .ARVALID_U85_EXT0(U85_EXT0_AXI.ARVALID),
    .ARREADY_U85_EXT0(U85_EXT0_AXI.ARREADY),
    .RID_U85_EXT0(U85_EXT0_AXI.RID),
    .RDATA_U85_EXT0(U85_EXT0_AXI.RDATA),
    .RRESP_U85_EXT0(U85_EXT0_AXI.RRESP),
    .RLAST_U85_EXT0(U85_EXT0_AXI.RLAST),
    .RVALID_U85_EXT0(U85_EXT0_AXI.RVALID),
    .RREADY_U85_EXT0(U85_EXT0_AXI.RREADY),

    .PADDR_U85_CFG(U85_CFG_APB.paddr),
    .PWDATA_U85_CFG(U85_CFG_APB.pwdata),
    .PWRITE_U85_CFG(U85_CFG_APB.pwrite),
    .PPROT_U85_CFG(U85_CFG_APB.pprot),
    .PSTRB_U85_CFG(U85_CFG_APB.pstrb),
    .PENABLE_U85_CFG(U85_CFG_APB.penable),
    .PSELx_U85_CFG(U85_CFG_APB.psel),
    .PRDATA_U85_CFG(U85_CFG_APB.prdata),
    .PSLVERR_U85_CFG(U85_CFG_APB.pslverr),
    .PREADY_U85_CFG(U85_CFG_APB.pready),

    .clk0clk(FCLK),
    .clk0clken(1'b1),
    .clk0resetn(nPORESET)
);

endmodule
