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
//  YAMIN_MCU  (u_cortexm55)


module millisoc_cpu_ss #(
    parameter BE = 0)(
    input  wire         FCLK,
    input wire          CLKEN,        // Clock enable for CLK clock gate
    input wire          FCLKEN,       // Clock enable for FCLK clock gate
    input wire          HCLKEN,       // Clock enable for HCLK clock gate
    input wire          ETMCLKEN,     // Clock enable for ETM clock
    input wire          nSYSRESET,    // Soft reset (non-debug logic only)
    output wire         SYSRESETREQ,  // Request for system reset (nSYSRESET)
    input wire          nPORESET,     // Power-on reset (for the entire processor)
    input wire          nDBGETMRESET, // Soft reset (for ETM only)
    input wire          CPUWAIT,      // Stall processor out of reset
    input wire          SWCLKTCK,     // SW/JTAG DP clock
    input wire          TRACECLKIN,   // TPIU trace port clock
    input wire          TRESETn,      // TPIU trace port reset

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

    // AHBS (AMBA3 AHB-LITE)
    output wire         HREADYOUTS,
    output wire         HRESPS,
    output wire [31:0]  HRDATAS,
    input wire          HREADYS,
    input wire          HSELS,
    input wire [ 1:0]   HTRANSS,
    input wire          HWRITES,
    input wire [ 2:0]   HSIZES,
    input wire [ 2:0]   HBURSTS,
    input wire [ 3:0]   HPROTS,
    input wire [31:0]   HADDRS,
    input wire [31:0]   HWDATAS,

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
    input wire [ 1:0]   BRESP,

    input  wire [239:0] IRQ

);



// Internal Wires
// - Timestamp
reg [63:0]   TSVALUEB;
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

// Instantiate the Cortex-M55 Integration MCU
YAMIN_MCU u_cortexm55(
    .CLKIN(),
    .CLKINDCLS(),
    .DBGCLK(),
    .EWICCLK(),
    .TRACECLKIN(),
    .IWICCLK(),
    .IWICCLKDCLS(),
    .SWCLKTCK(),
    .nSYSRESET(),
    .nSYSRESETDCLS(),
    .nPORESET(),
    .nPORESETDCLS(),
    .nDBGRESET(),
    .nEWICRESET(),
    .nMBISTRESET(),
    .nTRESET(),
    .nIWICRESET(),
    .nIWICRESETDCLS(),
    .NTRST(),

    .DFTCGEN(),
    .ACLKEN(),
    .ARREADY(),
    .RVALID(),
    .RID(),
    .RDATA(),
    .RLAST(),
    .RRESP(),
    .RPOISON(),
    .AWREADY(),
    .WREADY(),
    .BVALID(),
    .BID(),
    .BRESP(),
    .ACLKENCHK(),
    .ARREADYCHK(),
    .AWREADYCHK(),
    .RVALIDCHK(),
    .RIDCHK(),
    .RDATACHK(),
    .RLASTCHK(),
    .RRESPCHK(),
    .RPOISONCHK(),
    .WREADYCHK(),
    .BVALIDCHK(),
    .BIDCHK(),
    .BRESPCHK(),

    .AWAKEUP(),
    .ARVALID(),
    .ARID(),
    .ARADDR(),
    .ARBURST(),
    .ARLEN(),
    .ARSIZE(),
    .ARLOCK(),
    .ARCACHE(),
    .ARPROT(),
    .ARMASTER(),
    .ARINNER(),
    .ARDOMAIN(),
    .RREADY(),
    .AWVALID(),
    .AWID(),
    .AWADDR(),
    .AWBURST(),
    .AWLEN(),
    .AWSIZE(),
    .AWLOCK(),
    .AWCACHE(),
    .AWPROT(),
    .AWMASTER(),
    .AWINNER(),
    .AWDOMAIN(),
    .AWSPARSE(),
    .WVALID(),
    .WID(),
    .WSTRB(),
    .WDATA(),
    .WPOISON(),
    .WLAST(),
    .BREADY(),
    .AWAKEUPCHK(),
    .ARVALIDCHK(),
    .ARADDRCHK(),
    .ARIDCHK(),
    .ARLENCHK(),
    .ARUSERCHK(),
    .ARCTLCHK0(),
    .ARCTLCHK1(),
    .ARCTLCHK2(),
    .AWVALIDCHK(),
    .AWADDRCHK(),
    .AWIDCHK(),
    .AWLENCHK(),
    .AWUSERCHK(),
    .AWCTLCHK0(),
    .AWCTLCHK1(),
    .AWCTLCHK2(),
    .RREADYCHK(),
    .WVALIDCHK(),
    .WDATACHK(),
    .WSTRBCHK(),
    .WIDCHK(),
    .WLASTCHK(),
    .WPOISONCHK(),
    .BREADYCHK(),

    .ECOREVNUM(),

    .CFGFPU(),
    .CFGMVE(),
    .CFGNOCDECP(),
    .CPSPRESENT(),
    .CPNSPRESENT(),
    .LOCKSVTAIRCR(),
    .LOCKNSVTOR(),
    .INITSVTOR(),
    .INITNSVTOR(),
    .NIDEN(),
    .DBGEN(),
    .SPNIDEN(),
    .SPIDEN(),
    .DAPEN(),
    .CPUWAIT(),
    .EDBGRQ(),
    .DBGRESTART(),
    .SLEEPHOLDREQn(),
    .RXEV(),
    .WICCONTROL(),
    .CPREADY(),
    .CPERROR(),
    .CPRDATA(),

    .HALTED(),
    .DBGRESTARTED(),
    .LOCKUP(),
    .INTNUM(),
    .CURRPC(),
    .CURRNS(),
    .FAULTSTAT(),
    .SLEEPING(),
    .SLEEPDEEP(),
    .SLEEPHOLDACKn(),
    .TXEV(),
    .CPENABLED(),
    .CPPWRSU(),
    .CPNUM(),
    .CPCDP(),
    .CPMCR(),
    .CPMRC(),
    .CPSIZE(),
    .CPREGS(),
    .CPOPC(),
    .CPPRIV(),
    .CPNSATTR(),
    .CPVALID(),
    .CPWDATA(),
    .EVENTBUS(),

    .COREPSTATE(),
    .COREPREQ(),
    .CLKINQREQn(),
    .INITL1RSTDIS(),
    .DFTRSTDISABLE(),

    .COREPACTIVE(),
    .COREPDENY(),
    .COREPACCEPT(),
    .CLKINQACTIVE(),
    .CLKINQACCEPTn(),
    .CLKINQDENY(),
    .CPRESETOUTn(),

    .CTICHIN(),

    .CTICHOUT(),
    .CTIIRQ(),

    .SWDITMS(),
    .TDI(),
    .CDBGPWRUPACK(),
    .CSYSPWRUPACK(),
    .CDBGRSTACK(),
    .DPTARGETID(),
    .DPINSTANCEID(),
    .CLKQREQN(),

    .TDO(),
    .TDOENN(),
    .SWDO(),
    .SWDOEN(),
    .SWACTIVE(),
    .JTAGACTIVE(),
    .JTAGIR(),
    .JTAGSTATE(),
    .DORMANTSTATE(),
    .CDBGPWRUPREQ(),
    .CSYSPWRUPREQ(),
    .CDBGRSTREQ(),
    .CLKQACCEPTN(),
    .CLKQDENY(),
    .CLKQACTIVE(),

    .DFTRAMHOLD(),

    .PWRDBGQREQn(),
    .DBGCLKQREQn(),
    .PWRDBGQACTIVE(),
    .PWRDBGQACCEPTn(),
    .PWRDBGQDENY(),
    .DBGCLKQACTIVE(),
    .DBGCLKQACCEPTn(),
    .DBGCLKQDENY(),
    .TRCENA(),

    .DSYNC(),

    .TSVALUEB(),

    .EWICCLKQREQn(),
    .EWICCLKQACTIVE(),
    .EWICCLKQACCEPTn(),
    .EWICCLKQDENY(),

    .LOCKDCAIC(),

    .PREADY(),
    .PRDATA(),
    .PSLVERR(),
    .PREADYCHK(),
    .PRDATACHK(),
    .PSLVERRCHK(),
    .PSEL(),
    .PADDR(),
    .PSELCHK(),
    .PENABLE(),
    .PWRITE(),
    .PADDR31(),
    .PPROT(),
    .PWDATA(),
    .PSTRB(),
    .PENABLECHK(),
    .PADDRCHK(),
    .PWDATACHK(),
    .PCTRLCHK(),
    .PSTRBCHK(),

    .PMCPSEL(),
    .PMCPENABLE(),
    .PMCPPROT(),
    .PMCPWRITE(),
    .PMCPADDR(),
    .PMCPWDATA(),
    .PMCPSTRB(),
    .PMCPSELCHK(),
    .PMCPENABLECHK(),
    .PMCPADDRCHK(),
    .PMCPWDATACHK(),
    .PMCPCTRLCHK(),
    .PMCPSTRBCHK(),

    .PMCPREADY(),
    .PMCPSLVERR(),
    .PMCPRDATA(),
    .PMCPREADYCHK(),
    .PMCPRDATACHK(),
    .PMCPSLVERRCHK(),

    .TSCLKCHANGE(),

    .NMI(),
    .IRQ(),

    .IWICSENSE(),
    .IWAKEUP(),

    .EWAKEUP(),

    .CFGBIGEND(),
    .HREADYP(),
    .HRDATAP(),
    .HRESPP(),
    .HEXOKAYP(),
    .HREADYCHKP(),
    .HRDATACHKP(),
    .HRESPCHKP(),

    .PWRDBGWAKEQACTIVE(),
    .HTRANSP(),
    .HADDRP(),
    .HMASTERP(),
    .HWRITEP(),
    .HPROTP(),
    .HNONSECP(),
    .HBURSTP(),
    .HSIZEP(),
    .HEXCLP(),
    .HWDATAP(),
    .HTRANSCHKP(),
    .HADDRCHKP(),
    .HWDATACHKP(),
    .HCTRLCHK1P(),
    .HCTRLCHK2P(),
    .HPROTCHKP(),
    .DBE(),
    .DMEV0(),
    .DMEV1(),
    .DMEV2(),
    .DMEL0(),
    .DMEL1(),
    .DMEI0(),
    .DMEI1(),
    .DFE(),

    .IDAUNSA(),
    .IDAUNSCA(),
    .IDAUIDA(),
    .IDAUIDVA(),
    .IDAUNCHKA(),
    .IDAUNSB(),
    .IDAUNSCB(),
    .IDAUIDB(),
    .IDAUIDVB(),
    .IDAUNCHKB(),
    .IDAUNSC(),
    .IDAUNSCC(),
    .IDAUIDC(),
    .IDAUIDVC(),
    .IDAUNCHKC(),
    .MPUNSDISABLE(),
    .LOCKNSMPU(),
    .MPUSDISABLE(),
    .LOCKSMPU(),
    .SAUDISABLE(),
    .LOCKSAU(),
    .LOCKITGU(),
    .LOCKDTGU(),
    .CFGITCMSZ(),
    .CFGDTCMSZ(),

    .IDAUVALIDA(),
    .IDAUADDRA(),
    .IDAUVALIDB(),
    .IDAUADDRB(),
    .IDAUVALIDC(),
    .IDAUADDRC(),

    .CFGNSSTCALIB(),
    .CFGSSTCALIB(),
    .NSSTCLKEN(),
    .SSTCLKEN(),

    .CURRPRI(),
    .SYSRESETREQ(),

    .PMCTEN(),
    .PMCTC(),

    .PMCTE(),
    .PMCTF(),

    .LOCKTCM(),
    .LOCKPAHB(),
    .CFGPAHBSZ(),
    .CFGMEMALIAS(),
    .INITECCEN(),
    .INITTCMEN(),
    .INITPAHBEN(),
    .REVIDRNUM(),

    .ITCMWAIT(),
    .ITCMERR(),
    .ITCMRDATA(),
    .D0TCMWAIT(),
    .D0TCMERR(),
    .D0TCMRDATA(),
    .D1TCMWAIT(),
    .D1TCMERR(),
    .D1TCMRDATA(),
    .D2TCMWAIT(),
    .D2TCMERR(),
    .D2TCMRDATA(),
    .D3TCMWAIT(),
    .D3TCMERR(),
    .D3TCMRDATA(),
    .HREADYS(),
    .HSELS(),
    .HTRANSS(),
    .HWRITES(),
    .HWSTRBS(),
    .HADDRS(),
    .HSIZES(),
    .HBURSTS(),
    .HPROTS(),
    .HNONSECS(),
    .HWDATAS(),
    .HREADYCHKS(),
    .HTRANSCHKS(),
    .HADDRCHKS(),
    .HWDATACHKS(),
    .HWSTRBCHKS(),
    .HPROTCHKS(),
    .HCTRLCHK1S(),
    .HSELCHKS(),

    .ITCMCS(),
    .ITCMADDR(),
    .ITCMWR(),
    .ITCMBYTEWR(),
    .ITCMPRIV(),
    .ITCMMASTER(),
    .ITCMWDATA(),
    .D0TCMCS(),
    .D0TCMADDR(),
    .D0TCMWR(),
    .D0TCMBYTEWR(),
    .D0TCMPRIV(),
    .D0TCMMASTER(),
    .D0TCMWDATA(),
    .D1TCMCS(),
    .D1TCMADDR(),
    .D1TCMWR(),
    .D1TCMBYTEWR(),
    .D1TCMPRIV(),
    .D1TCMMASTER(),
    .D1TCMWDATA(),
    .D2TCMCS(),
    .D2TCMADDR(),
    .D2TCMWR(),
    .D2TCMBYTEWR(),
    .D2TCMPRIV(),
    .D2TCMMASTER(),
    .D2TCMWDATA(),
    .D3TCMCS(),
    .D3TCMADDR(),
    .D3TCMWR(),
    .D3TCMBYTEWR(),
    .D3TCMPRIV(),
    .D3TCMMASTER(),
    .D3TCMWDATA(),
    .HREADYOUTS(),
    .HRESPS(),
    .HRDATAS(),
    .SAHBWABORT(),
    .SAHBWABORTCHK(),
    .HREADYOUTCHKS(),
    .HRDATACHKS(),
    .HRESPCHKS(),

    .MAXPORTSIZE(),

    .TRACECLK(),
    .TRACEDATA(),
    .TRACESWO(),
    .SWOACTIVE(),
    .TRACEPORTSIZE(),

    .FPIXC(),
    .FPOFC(),
    .FPUFC(),
    .FPIOC(),
    .FPDZC(),
    .FPIDC(),

    .ETB_MEM_CE_N(),
    .ETB_MEM_WE_N(),
    .ETB_MEM_ADDR(),
    .ETB_MEM_D(),
    .ETB_MEM_Q(),

    .TRACECLKINQACTIVE(),
    .TRACECLKINQREQn(),
    .TRACECLKINQACCEPTn(),
    .TRACECLKINQDENY(),

    .MBISTREQ(),

    .DCLSCORECTL(),
    .DCLSIWICCTL(),

    .DCLSCORECOMPRES(),
    .DCLSIWICCOMPRES(),

    .SBIST_TESTSTATUS(),
    .SBIST_TESTID(),
    .SBIST_TESTFMODE(),
    .SBIST_DEADLOCK()
`ifdef ARM_PG_ON
  ,
   // Power control
    .nISOLATECORE(),        // Isolation control for Core
    .nPWRUPCORE_HAMMER(),   // Power control for Core primary low impedance supply
    .nPWRUPCORE_TRICKLE(),  // Power control for Core primary current in-rush limited supply
`ifdef ARM_RET_ON
    .nRETNCORE(),           // Retention control for Core
    .nPWRUPRETNCORE(),      // Power control for Core retention supply
`endif
`ifdef ARM_EPU_PG_ON
    .nISOLATEEPU(),         // Isolation control for EPU
    .nPWRUPEPU_HAMMER(),    // Power control for EPU primary low impedance supply
    .nPWRUPEPU_TRICKLE(),   // Power control for EPU primary current in-rush limited supply
`ifdef ARM_RET_ON
    .nRETNEPU(),            // Retention control for EPU
    .nPWRUPRETNEPU(),       // Power control for EPU retention supply
`endif
`endif
`ifdef ARM_RAMS_PG_ON
    .nISOLATERAMS(),        // Isolation control for RAMS
    .nPWRUPRAMS_HAMMER(),   // Power control for RAMS primary low impedance supply
    .nPWRUPRAMS_TRICKLE(),  // Power control for RAMS primary current in-rush limited supply
`ifdef ARM_RET_ON
    .nRETNRAMS(),           // Retention control for RAMS
    .nPWRUPRETNRAMS(),      // Power control for RAMS retention supply
`endif
`endif
`ifdef ARM_DEBUG_PG_ON
    .nISOLATEDEBUG(),       // Isolation control for Debug
    .nPWRUPDEBUG_HAMMER(),  // Power control for Debug primary low impedance supply
    .nPWRUPDEBUG_TRICKLE()  // Power control for Debug primary current in-rush limited supply
`endif
`endif // ARM_PG_ON

);

// Timestamp generation
always @(posedge FCLK or negedge nPORESET) begin
    if(~nPORESET) begin
        TSVALUEB <= 64'h0;
    end else begin
        TSVALUEB <= TSVALUEB + 64'h1;
    end
end


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
