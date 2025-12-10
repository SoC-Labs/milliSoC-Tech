//-----------------------------------------------------------------------------
// milli SoC CPU Subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
// 
// Copyright � 2021-5, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
// Purpose:
//  CPU subsystem
//-----------------------------------------------------------------------------
// Modules instantiated:
//  CORTEXM7INTEGRATIONMCU  (u_cortexm7integrationmcu)


module millisoc_cpu_ss #(
    parameter BE = 0)(
    input  wire         FCLK,
    input wire          CLKEN,        // Clock enable for CLK clock gate
    input wire          FCLKEN,       // Clock enable for FCLK clock gate
    input wire          HCLKEN,       // Clock enable for HCLK clock gate
    input wire          CLK1EN,       // Clock for dual-redundant CPU
    input wire          FCLK1EN,      // Clock for dual-redundant CPU
    input wire          HCLK1EN,      // Clock for dual-redundant CPU
    input wire          ETMCLKEN,     // Clock enable for ETM clock
    input wire          nSYSRESET,    // Soft reset (non-debug logic only)
    output wire         SYSRESETREQ,  // Request for system reset (nSYSRESET)
    input wire          nPORESET,     // Power-on reset (for the entire processor)
    input wire          nDBGETMRESET, // Soft reset (for ETM only)
    input wire          CPUWAIT,      // Stall processor out of reset
    input wire          SWCLKTCK,     // SW/JTAG DP clock
    input wire          TRACECLKIN,   // TPIU trace port clock
    input wire          TRESETn,      // TPIU trace port reset

    input  wire         PCLKEN_DMA,
    input  wire         PSEL_DMA,
    input  wire         PEN_DMA,
    input  wire         PWRITE_DMA,
    input  wire [11:0]  PADDR_DMA,
    input  wire [31:0]  PWDATA_DMA,
    output wire [31:0]  PRDATA_DMA,

    output wire         HSEL_SYS_BUS,
    output wire [31:0]  HADDR_SYS_BUS,
    output wire [1:0]   HTRANS_SYS_BUS,
    output wire         HWRITE_SYS_BUS,
    output wire [2:0]   HSIZE_SYS_BUS,
    output wire [2:0]   HBURST_SYS_BUS,
    output wire [3:0]   HPROT_SYS_BUS,
    output wire [31:0]  HWDATA_SYS_BUS,
    output wire         HMASTLOCK_SYS_BUS,
    output wire         HREADYMUX_SYS_BUS,
    input  wire [31:0]  HRDATA_SYS_BUS,
    input  wire         HREADYOUT_SYS_BUS,
    input  wire         HRESP_SYS_BUS,

    output wire [ 1:0]  HTRANSP,
    output wire         HWRITEP,
    output wire [ 2:0]  HSIZEP,
    output wire [ 2:0]  HBURSTP,
    output wire [ 3:0]  HPROTP,
    output wire         HMASTERP,
    output wire [31:0]  HADDRP,
    output wire [31:0]  HWDATAP,
    output wire         EXREQP,
    input wire          HREADYP,
    input wire          HRESPP,
    input wire [31:0]   HRDATAP,
    input wire          EXRESPP,

    input wire          ACLKEN,
    output wire         ARVALID,
    output wire [31:0]  ARADDR,
    output wire [ 2:0]  ARID,
    output wire [ 1:0]  ARBURST,
    output wire [ 2:0]  ARLEN,
    output wire [ 1:0]  ARSIZE,
    output wire         ARLOCK,
    output wire [ 3:0]  ARCACHE,
    output wire [ 2:0]  ARPROT,
    output wire         ARMASTER,
    output wire [ 3:0]  ARINNER,
    output wire         ARSHARE,
    input wire          ARREADY,
    output wire         AWVALID,
    output wire [31:0]  AWADDR,
    output wire [ 1:0]  AWID,
    output wire [ 1:0]  AWBURST,
    output wire [ 2:0]  AWLEN,
    output wire [ 1:0]  AWSIZE,
    output wire         AWLOCK,
    output wire [ 3:0]  AWCACHE,
    output wire [ 2:0]  AWPROT,
    output wire         AWMASTER,
    output wire [ 3:0]  AWINNER,
    output wire         AWSHARE,
    output wire         AWSPARSE,
    input wire          AWREADY,
    output wire         RREADY,
    input wire          RVALID,
    input wire [ 2:0]   RID,
    input wire          RLAST,
    input wire [63:0]   RDATA,
    input wire [ 1:0]   RRESP,
    output wire         WVALID,
    output wire [ 1:0]  WID,
    output wire [63:0]  WDATA,
    output wire [ 7:0]  WSTRB,
    output wire         WLAST,
    input wire          WREADY,
    output wire         BREADY,
    input wire          BVALID,
    input wire [ 1:0]   BID,
    input wire [ 1:0]   BRESP

);



// Internal Wires
// - Timestamp
reg [63:0]   TSVALUEB;
// - AHBs from DMA
wire         HSEL_M7_AHBS;
wire [31:0]  HADDR_M7_AHBS;
wire [1:0]   HTRANS_M7_AHBS;
wire         HWRITE_M7_AHBS;
wire [2:0]   HSIZE_M7_AHBS;
wire [2:0]   HBURST_M7_AHBS;
wire [3:0]   HPROT_M7_AHBS;
wire [31:0]  HWDATA_M7_AHBS;
wire         HMASTLOCK_M7_AHBS;
wire         HREADYMUX_M7_AHBS;
wire [31:0]  HRDATA_M7_AHBS;
wire         HREADYOUT_M7_AHBS;
wire         HRESP_M7_AHBS;
// - ITCM
wire         ITCMCS;
wire [23:3]  ITCMADDR;
wire         ITCMWR;
wire [ 7:0]  ITCMBYTEWR;
wire [ 3:0]  ITCMMASTER;
wire [63:0]  ITCMWDATA;
wire [63:0]  ITCMRDATA;
// - DTCM
wire         D0TCMCS;
wire [23:3]  D0TCMADDR;
wire         D0TCMWR;
wire [ 3:0]  D0TCMBYTEWR;
wire [31:0]  D0TCMWDATA;
wire [31:0]  D0TCMRDATA;

wire         D1TCMCS;
wire [23:3]  D1TCMADDR;
wire         D1TCMWR;
wire [ 3:0]  D1TCMBYTEWR;
wire [31:0]  D1TCMWDATA;
wire [31:0]  D1TCMRDATA;

// Instantiate the Cortex-M7 Integration MCU
CORTEXM7INTEGRATIONMCU #(
    .SWMD(0),
    .BASEADDR(32'hE00FD003), //ROmtable baseaddress
    .TARGETID(32'h00000000),
    .JEPID(7'h00),
    .JEPCONT(4'h0),
    .PARTNUM(12'h000)
)
    u_cortexm7integrationmcu (
    // Clocks and resets
    .CLKIN(FCLK),
    .CLKEN(CLKEN),
    .FCLKEN(FCLKEN),
    .HCLKEN(HCLKEN),
    .CLK1EN(CLK1EN),
    .FCLK1EN(FCLK1EN),
    .HCLK1EN(HCLK1EN),
    .ETMCLKEN(ETMCLKEN),
    .STCLKEN(1'b0), // No alt reference clock for systick
    .nSYSRESET(nSYSRESET),
    .SYSRESETREQ(SYSRESETREQ),
    .nPORESET(nPORESET),
    .nDBGETMRESET(nDBGETMRESET),
    .CPUWAIT(CPUWAIT),
    .SWCLKTCK(SWCLKTCK),
    .TRACECLKIN(TRACECLKIN),
    .TRESETn(TRESETn),
    // STATIC CONFIGURATION PINS
    .CFGBIGEND(BE),
    .CFGITCMSZ(4'b0111), // default 64kB
    .CFGDTCMSZ(4'b0111), // default 64kB
    .CFGAHBPSZ(3'b001), // default 64MB
    .CFGSTCALIB(26'h2000000), // No alt reference clock
    // RESET CONFIGURATION PINS
    .INITTCMEN(2'b10), // Enable DTCM
    .INITRMWEN(2'b11), // Enable read-modify-write for both TCMs   
    .INITRETRYEN(2'b00), // Disable retry
    .INITAHBPEN(1'b1), // Enable AHB port
    .INITVTOR(24'hC08000), // Vector table offset
    // ITCM
    .ITCMCS(ITCMCS),
    .ITCMADDR(ITCMADDR),
    .ITCMWR(ITCMWR),
    .ITCMBYTEWR(ITCMBYTEWR),
    .ITCMPRIV(),
    .ITCMMASTER(),
    .ITCMWDATA(ITCMWDATA),
    .ITCMMBISTIN(),
    .ITCMWAIT(1'b0),
    .ITCMERR(1'b0),
    .ITCMRDATA(ITCMRDATA),
    .ITCMRETRY(1'b0),
    .ITCMMBISTOUT(8'h00),
    // DTCM
    .D0TCMCS(D0TCMCS),
    .D0TCMADDR(D0TCMADDR),
    .D0TCMWR(D0TCMWR),
    .D0TCMBYTEWR(D0TCMBYTEWR),
    .D0TCMPRIV(),
    .D0TCMMASTER(),
    .D0TCMWDATA(D0TCMWDATA),
    .D0TCMMBISTIN(),
    .D0TCMWAIT(1'b0),
    .D0TCMERR(1'b0),
    .D0TCMRDATA(D0TCMRDATA),
    .D0TCMRETRY(1'b0),
    .D0TCMMBISTOUT(7'h00),
    .D1TCMCS(D1TCMCS),
    .D1TCMADDR(D1TCMADDR),
    .D1TCMWR(D1TCMWR),
    .D1TCMBYTEWR(D1TCMBYTEWR),
    .D1TCMPRIV(),
    .D1TCMMASTER(),
    .D1TCMWDATA(D1TCMWDATA),
    .D1TCMMBISTIN(),
    .D1TCMWAIT(1'b0),
    .D1TCMERR(1'b0),
    .D1TCMRDATA(D1TCMRDATA),
    .D1TCMRETRY(1'b0),
    .D1TCMMBISTOUT(7'h00),
    // AXIM
    .ACLKEN(ACLKEN),
    .ARVALID(ARVALID),
    .ARADDR(ARADDR),
    .ARID(ARID),
    .ARBURST(ARBURST),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARLOCK(ARLOCK),
    .ARCACHE(ARCACHE),
    .ARPROT(ARPROT),
    .ARMASTER(ARMASTER),
    .ARINNER(ARINNER),
    .ARSHARE(ARSHARE),
    .ARREADY(ARREADY),
    .AWVALID(AWVALID),
    .AWADDR(AWADDR),
    .AWID(AWID),
    .AWBURST(AWBURST),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWLOCK(AWLOCK),
    .AWCACHE(AWCACHE),
    .AWPROT(AWPROT),
    .AWMASTER(AWMASTER),
    .AWINNER(AWINNER),
    .AWSHARE(AWSHARE),
    .AWSPARSE(AWSPARSE),
    .AWREADY(AWREADY),
    .RREADY(RREADY),
    .RVALID(RVALID),
    .RID(RID),
    .RLAST(RLAST),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .WVALID(WVALID),
    .WID(WID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WLAST(WLAST),
    .WREADY(WREADY),
    .BREADY(BREADY),
    .BVALID(BVALID),
    .BID(BID),
    .BRESP(BRESP),
    // AHBP
    .HTRANSP(HTRANSP),
    .HWRITEP(HWRITEP),
    .HSIZEP(HSIZEP),
    .HBURSTP(HBURSTP),
    .HPROTP(HPROTP),
    .HMASTERP(HMASTERP),
    .HADDRP(HADDRP),
    .HWDATAP(HWDATAP),
    .EXREQP(EXREQP),
    .HREADYP(HREADYP),
    .HRESPP(HRESPP),
    .HRDATAP(HRDATAP),
    .EXRESPP(EXRESPP),
    // AHBs
    .HREADYOUTS(HREADYOUT_M7_AHBS),
    .HRESPS(HRESP_M7_AHBS),
    .HRDATAS(HRDATA_M7_AHBS),
    .AHBSRDY(),
    .WABORTS(),
    .AHBSPRI(1'b1),
    .HREADYS(HREADYMUX_M7_AHBS),
    .HSELS(HSEL_M7_AHBS),
    .HTRANSS(HTRANS_M7_AHBS),
    .HWRITES(HWRITE_M7_AHBS),
    .HSIZES(HSIZE_M7_AHBS),
    .HBURSTS(HBURST_M7_AHBS),
    .HPROTS(HPROT_M7_AHBS),
    .HADDRS(HADDR_M7_AHBS),
    .HWDATAS(HWDATA_M7_AHBS),
    // EPPB
    .PENABLE(),
    .PSEL(),
    .PADDR(),
    .PADDR31(),
    .PWRITE(),
    .PWDATA(),
    .PREADY(),
    .PSLVERR(),
    .PRDATA(),
    // Timestamp
    .TSVALUEB(TSVALUEB),
    .TSCLKCHANGE(1'b0),
    // Debug
    .HALTED(),
    .DBGRESTARTED(),
    .DBGEN(1'b1),
    .NIDEN(1'b1),
    .EDBGRQ(1'b0),
    .DBGRESTART(1'b0),
    // Debug Protection
    .IADDR(),
    .IADBGPROT(1'b0),
    // Interrupts
    .IRQ(240'd0),
    .NMI(1'b0),
    // POWER CONTROL AND SLEEP
    .SLEEPING(),
    .SLEEPDEEP(),
    .GATEHCLK(),
    .SLEEPHOLDACKn(),
    .SLEEPHOLDREQn(1'b1),
    .WAKEUP(),
    .WICSENSE(),
    .WICENREQ(1'b0),
    .WICENACK(),
    .ETMPWRUPREQ(),
    // EVENTS AND ERRORS
    .LOCKUP(),
    .TXEV(),
    .ICERR(),
    .DCERR(),
    .ICDET(),
    .DCDET(),
    .RXEV(1'b0),
    // FPU EXCEPTION FLAGS
    .FPIXC(),
    .FPIDC(),
    .FPOFC(),
    .FPUFC(),
    .FPDZC(),
    .FPIOC(),
    // CROSS TRIGGER INTERFACE
    .CTICHIN(4'h0),
    .CTICHOUT(),
    .CTIIRQ(),
    // MBIST INTERFACE
    .MBISTACK(),
    .MBISTOUTDATA(),
    .MBISTIMPERR(),
    .nMBISTRESET(nPORESET),
    .MBISTREQ(1'b0),
    .MBISTADDR(),
    .MBISTINDATA(),
    .MBISTWRITEEN(1'b0),
    .MBISTREADEN(1'b0),
    .MBISTARRAY(),
    .MBISTBE(),
    .MBISTCFG(),
    // DEBUG ACCESS PORT
    .DAPEN(1'b0),
    .CFGJTAGnSW(),
    .CDBGPWRUPREQ(),
    .CDBGPWRUPACK(),
    .INSTANCEID(),
    // JTAG
    .nTRST(),
    .TDI(),
    .TDO(),
    .nTDOEN(),
    // SWD INTERFACE
    .SWDITMS(),
    .SWDO(),
    .SWDOEN(),
    // TPIU
    .MAXPORTSIZE(2'b11),
    .TRACECLK(),
    .TRACEDATA(),
    .TRACESWO(),
    .SWOACTIVE(),
    // ECO Rev Number
    .ECOREVNUM(36'd0),
    // Dual redundant CPU comparison control
    .DCCMINP(8'h00),
    .DCCMOUT(),
    .DCCMINP2(8'h00),
    .DCCMOUT2(),
    // DFT
    .DFTSE(1'b0),
    .DFTRSTDISABLE(1'b0),
    .DFTRAMHOLD(1'b0),
    // Control Wires
    .CTLPPBLOCK(4'h0)
);

// Timestamp generation
always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET) begin
        TSVALUEB <= 64'h0;
    end else begin
        TSVALUEB <= TSVALUEB + 64'h1;
    end
end

millisoc_cpu_dma u_millisoc_cpu_dma (
    .HCLK(FCLK),
    .HRESETn(),

    .PCLKEN_DMA(PCLKEN_DMA),
    .PSEL_DMA(PSEL_DMA),
    .PEN_DMA(PEN_DMA),
    .PWRITE_DMA(PWRITE_DMA),
    .PADDR_DMA(PADDR_DMA),
    .PWDATA_DMA(PWDATA_DMA),
    .PRDATA_DMA(PRDATA_DMA),

    .HSEL_M7_AHBS(HSEL_M7_AHBS),
    .HADDR_M7_AHBS(HADDR_M7_AHBS),
    .HTRANS_M7_AHBS(HTRANS_M7_AHBS),
    .HWRITE_M7_AHBS(HWRITE_M7_AHBS),
    .HSIZE_M7_AHBS(HSIZE_M7_AHBS),
    .HBURST_M7_AHBS(HBURST_M7_AHBS),
    .HPROT_M7_AHBS(HPROT_M7_AHBS),
    .HWDATA_M7_AHBS(HWDATA_M7_AHBS),
    .HMASTLOCK_M7_AHBS(HMASTLOCK_M7_AHBS),
    .HREADYMUX_M7_AHBS(HREADYMUX_M7_AHBS),
    .HRDATA_M7_AHBS(HRDATA_M7_AHBS),
    .HREADYOUT_M7_AHBS(HREADYOUT_M7_AHBS),
    .HRESP_M7_AHBS(HRESP_M7_AHBS),

    .HSEL_SYS_BUS(HSEL_SYS_BUS),
    .HADDR_SYS_BUS(HADDR_SYS_BUS),
    .HTRANS_SYS_BUS(HTRANS_SYS_BUS),
    .HWRITE_SYS_BUS(HWRITE_SYS_BUS),
    .HSIZE_SYS_BUS(HSIZE_SYS_BUS),
    .HBURST_SYS_BUS(HBURST_SYS_BUS),
    .HPROT_SYS_BUS(HPROT_SYS_BUS),
    .HWDATA_SYS_BUS(HWDATA_SYS_BUS),
    .HMASTLOCK_SYS_BUS(HMASTLOCK_SYS_BUS),
    .HREADYMUX_SYS_BUS(HREADYMUX_SYS_BUS),
    .HRDATA_SYS_BUS(HRDATA_SYS_BUS),
    .HREADYOUT_SYS_BUS(HREADYOUT_SYS_BUS),
    .HRESP_SYS_BUS(HRESP_SYS_BUS)
);

dtcm u_dtcm (
    .CLK(FCLK),
    .D0TCMCS(D0TCMCS),
    .D0TCMADDR(D0TCMADDR),
    .D0TCMWR(D0TCMWR),
    .D0TCMBYTEWR(D0TCMBYTEWR),
    .D0TCMWDATA(D0TCMWDATA),
    .D0TCMRDATA(D0TCMRDATA),

    .D1TCMCS(D1TCMCS),
    .D1TCMADDR(D1TCMADDR),
    .D1TCMWR(D1TCMWR),
    .D1TCMBYTEWR(D1TCMBYTEWR),
    .D1TCMWDATA(D1TCMWDATA),
    .D1TCMRDATA(D1TCMRDATA)
);

itcm u_itcm (
    .CLK(FCLK),
    .ITCMCS(ITCMCS),
    .ITCMADDR(ITCMADDR),
    .ITCMWR(ITCMWR),
    .ITCMBYTEWR(ITCMBYTEWR),
    .ITCMWDATA(ITCMWDATA),
    .ITCMRDATA(ITCMRDATA)
);

endmodule
