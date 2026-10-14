

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
    output wire [63:0]  HRDATAS,
    input wire          HREADYS,
    input wire          HSELS,
    input wire [ 1:0]   HTRANSS,
    input wire          HWRITES,
    input wire [ 2:0]   HSIZES,
    input wire [ 2:0]   HBURSTS,
    input wire [ 3:0]   HPROTS,
    input wire [31:0]   HADDRS,
    input wire [63:0]   HWDATAS,

    // AXI 
    input wire          ACLKEN,
    output wire         ARVALID,
    output wire [31:0]  ARADDR,
    output wire [ 2:0]  ARID,
    output wire [ 1:0]  ARBURST,
    output wire [ 7:0]  ARLEN,
    output wire [ 2:0]  ARSIZE,
    output wire         ARLOCK,
    output wire [ 3:0]  ARCACHE,
    output wire [ 2:0]  ARPROT,
    output wire         ARMASTER,
    output wire [ 3:0]  ARINNER,
    output wire         ARSHARE,
    input wire          ARREADY,
    output wire         AWVALID,
    output wire [31:0]  AWADDR,
    output wire [ 2:0]  AWID,
    output wire [ 1:0]  AWBURST,
    output wire [ 7:0]  AWLEN,
    output wire [ 2:0]  AWSIZE,
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
    output wire [ 2:0]  WID,
    output wire [63:0]  WDATA,
    output wire [ 7:0]  WSTRB,
    output wire         WLAST,
    input wire          WREADY,
    output wire         BREADY,
    input wire          BVALID,
    input wire [ 2:0]   BID,
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
wire [ 8:0]  ITCMBYTEWR;
wire [ 3:0]  ITCMMASTER;
wire [71:0]  ITCMWDATA;
wire [71:0]  ITCMRDATA;
// - DTCM
wire         D0TCMCS;
wire [22:3]  D0TCMADDR;
wire         D0TCMWR;
wire [ 4:0]  D0TCMBYTEWR;
wire [38:0]  D0TCMWDATA;
wire [38:0]  D0TCMRDATA;
wire [3:0]   D0TCMMASTER;

wire         D1TCMCS;
wire [22:3]  D1TCMADDR;
wire         D1TCMWR;
wire [ 4:0]  D1TCMBYTEWR;
wire [38:0]  D1TCMWDATA;
wire [38:0]  D1TCMRDATA;
wire [3:0]   D1TCMMASTER;

wire         D2TCMCS;
wire [22:3]  D2TCMADDR;
wire         D2TCMWR;
wire [ 4:0]  D2TCMBYTEWR;
wire [38:0]  D2TCMWDATA;
wire [38:0]  D2TCMRDATA;
wire [3:0]   D2TCMMASTER;

wire         D3TCMCS;
wire [22:3]  D3TCMADDR;
wire         D3TCMWR;
wire [ 4:0]  D3TCMBYTEWR;
wire [38:0]  D3TCMWDATA;
wire [38:0]  D3TCMRDATA;
wire [3:0]   D3TCMMASTER;

assign AWID[2]=1'b0;
assign WID[2]=1'b0;

OLYMPUS #(
    .BUSPROT(0)
    ) u_cortexm85 (
    // Clock and Resets
    .CLKIN(FCLK),
    .CLKINDCLS(FCLK),
    .DBGCLK(FCLK),
    .IWICCLK(FCLK),
    .IWICCLKDCLS(FCLK),
    .nSYSRESET(nSYSRESET),
    .nSYSRESETDCLS(nSYSRESET),
    .nPORESET(nPORESET),
    .nPORESETDCLS(nPORESET),
    .nDBGRESET(nDBGETMRESET),
    .nMBISTRESET(nPORESET),
    .nIWICRESET(nSYSRESET),
    .nIWICRESETDCLS(nSYSRESET),

    // AXI inputs
    .DFTCGEN(1'b0),
    .ACLKEN(ACLKEN),
    .ARREADY(ARREADY),
    .RVALID(RVALID),
    .RID(RID),
    .RDATA(RDATA),
    .RLAST(RLAST),
    .RRESP(RRESP),
    .RPOISON(1'b0),
    .AWREADY(AWREADY),
    .WREADY(WREADY),
    .BVALID(BVALID),
    .BID(BID[1:0]),
    .BRESP(BRESP),

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

    // AXI outputs
    .AWAKEUP(),
    .AWAKEUPCHK(),
    .ARVALID(ARVALID),
    .ARID(ARID),
    .ARADDR(ARADDR),
    .ARBURST(ARBURST),
    .ARLEN(ARLEN),
    .ARSIZE(ARSIZE),
    .ARLOCK(ARLOCK),
    .ARCACHE(ARCACHE),
    .ARPROT(ARPROT),
    .ARMASTER(ARMASTER),
    .ARINNER(ARINNER),
    .ARDOMAIN(ARDOMAIN),
    .RREADY(RREADY),
    .AWVALID(AWVALID),
    .AWID(AWID[1:0]),
    .AWADDR(AWADDR),
    .AWBURST(AWBURST),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWLOCK(AWLOCK),
    .AWCACHE(AWCACHE),
    .AWPROT(AWPROT),
    .AWMASTER(AWMASTER),
    .AWINNER(AWINNER),
    .AWDOMAIN(AWDOMAIN),
    .AWSPARSE(AWSPARSE),
    .WVALID(WVALID),
    .WID(WID[1:0]),
    .WSTRB(WSTRB),
    .WDATA(WDATA),
    .WPOISON(WPOISON),
    .WLAST(WLAST),
    .BREADY(BREADY),

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

    // Static values
    .COREECOREVNUM(8'h00),
    .DBGECOREVNUM(28'd0),
    .REVIDRNUM(4'd0),

    // Config and status inputs?
    .CFGITCMSZ(4'b0111),
    .CFGDTCMSZ(4'b0111),
    .CFGPAHBSZ(3'b001), // 64MB
    .CFGMEMALIAS(5'b00000),
    .CFGFPU(1'b1),
    .CFGMVE(2'b10),
    .CFGBIGEND(BE),
    .MPUNSDISABLE(1'b1),
    .MPUSDISABLE(1'b1),
    .SAUDISABLE(1'b1),
    .CFGSSTCALIB(26'h2000000),
    .CFGNSSTCALIB(26'h2000000),
    .CFGPACBTI(1'b0),

    .CFGNOCDECP(1'b0),


    .CPSPRESENT(8'd0),
    .CPNSPRESENT(8'd0),
    .LOCKSVTAIRCR(1'b0),
    .LOCKNSVTOR(1'b0),
    .INITSVTOR(24'hC08000), // Vector table offset
    .INITNSVTOR(24'hC08000), // Vector table offset
    .NIDEN(1'b1),
    .DBGEN(1'b1),
    .SPNIDEN(1'b1),
    .SPIDEN(1'b1),
    .CPUWAIT(CPUWAIT),
    .EDBGRQ(1'b0),
    .DBGRESTART(1'b0),
    .SLEEPHOLDREQn(1'b1),
    .RXEV(1'b0),
    .WICCONTROL(4'b1111),

    .CPREADY(1'b1),
    .CPERROR(1'b1),
    .CPRDATA(),
    // Config and status outputs
    .EWAKEUP(),
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
    .CPSVALID(),
    .CPVALID(),
    .CPFLUSH(),
    .CPWDATA(),
    .EVENTBUS(),

    // Power control
    .COREPSTATE(5'b11000),
    .COREPREQ(1'b1),
    .CLKINQREQn(1'b1),
    .INITL1RSTDIS(1'b0),
    .DFTRSTDISABLE(1'b0),
    
    .COREPACTIVE(),
    .COREPDENY(),
    .COREPACCEPT(),
    .CLKINQACTIVE(),
    .CLKINQACCEPTn(),
    .CLKINQDENY(),
    .CPRESETOUTn(),

    // CTI
    .CTICHIN(),
    .CTICHOUT(),
    .CTIIRQ(),

    .DFTRAMHOLD(1'b0),

    .PWRDBGQREQn(1'b1),
    .DBGCLKQREQn(1'b1),

    .PWRDBGQACTIVE(),
    .PWRDBGQACCEPTn(),
    .PWRDBGQDENY(),
    .DBGCLKQACTIVE(),
    .DBGCLKQACCEPTn(),
    .DBGCLKQDENY(),
    .TRCENA(),

    .DSYNC(),

    .TSVALUEB(TSVALUEB),

    .LOCKDCAIC(1'b0),

    .PREADY(),
    .PRDATA(),
    .PSLVERR(),
    .PREADYCHK(),
    .PRDATACHK(),

    .PSEL(),

    .PENABLE(),
    .PWRITE(),
    .PADDR(),
    .PADDR31(),
    .PPROT(),
    .PSTRB(),
    .PWDATA(),
    .PENABLECHK(),
    .PADDRCHK(),
    .PWDATACHK(),
    .PCTRLCHK(),
    .PSLVERRCHK(),
    .PSTRBCHK(),
    .PSELCHK(),

    .PMCPSEL(),
    .PMCPENABLE(),
    .PMCPADDR(),
    .PMCPWRITE(),
    .PMCPPROT(),
    .PMCPWDATA(),
    .PMCPSTRB(),

    .PMCPREADY(),
    .PMCPRDATA(),
    .PMCPSLVERR(),

    .PMCPSELCHK(),
    .PMCPENABLECHK(),
    .PMCPADDRCHK(),
    .PMCPWDATACHK(),
    .PMCPCTRLCHK(),
    .PMCPSTRBCHK(),

    .PMCPREADYCHK(),
    .PMCPRDATACHK(),
    .PMCPSLVERRCHK(),

    .TSCLKCHANGE(),

    // Interrupts
    .NMI(1'b0),
    .IRQ(IRQ),

    .IWICSENSE(),
    .IWAKEUP(),

    .HREADYP(HREADYP),
    .HRDATAP(HRDATAP),
    .HRESPP(HRESPP),
    .HEXOKAYP(1'b1),
    .HREADYCHKP(),
    .HRDATACHKP(),
    .HRESPCHKP(),

    .PWRDBGWAKEQACTIVE(),
    .PWRCOREWAKEPACTIVE(),
    .HTRANSP(HTRANSP),
    .HADDRP(HADDRP),
    .HMASTERP(HMASTERP),
    .HWRITEP(HWRITEP),
    .HPROTP(HPROTP),
    .HNONSECP(HNONSECP),
    .HBURSTP(HBURSTP),
    .HSIZEP(HSIZEP),
    .HEXCLP(HEXCLP),
    .HWDATAP(HWDATAP),
    .HTRANSCHKP(),
    .HADDRCHKP(),
    .HWDATACHKP(),
    .HCTRLCHK1P(),
    .HCTRLCHK2P(),
    .HPROTCHKP(),
    .DBE(DBE),
    .DMEV0(DMEV0),
    .DMEV1(DMEV1),
    .DMEV2(DMEV2),
    .DMEL0(DMEL0),
    .DMEL1(DMEL1),
    .DMEI0(DMEI0),
    .DMEI1(DMEI1),
    .DFE(DFE),

    .IDAUNSA(1'b0),
    .IDAUNSCA(1'b1),
    .IDAUIDA(8'h00),
    .IDAUIDVA(1'b1),
    .IDAUNCHKA(1'b1),
    .IDAUNSB(1'b0),
    .IDAUNSCB(1'b1),
    .IDAUIDB(8'h00),
    .IDAUIDVB(1'b1),
    .IDAUNCHKB(1'b1),
    .IDAUNSC(1'b0),
    .IDAUNSCC(1'b1),
    .IDAUIDC(8'h00),
    .IDAUIDVC(1'b1),
    .IDAUNCHKC(1'b1),
    .IDAUNSD(1'b0),
    .IDAUNSCD(1'b1),
    .IDAUIDD(8'h00),
    .IDAUIDVD(1'b1),
    .IDAUNCHKD(1'b1),
    .IDAUNSE(1'b0),
    .IDAUNSCE(1'b1),
    .IDAUIDE(8'h00),
    .IDAUIDVE(1'b1),
    .IDAUNCHKE(1'b1),
    .LOCKNSMPU(1'b0),
    .LOCKSMPU(1'b0),
    .LOCKSAU(1'b0),
    .LOCKITGU(1'b0),
    .LOCKDTGU(1'b0),

    .IDAUVALIDA(),
    .IDAUADDRA(),
    .IDAUVALIDB(),
    .IDAUADDRB(),
    .IDAUVALIDC(),
    .IDAUADDRC(),
    .IDAUVALIDD(),
    .IDAUADDRD(),
    .IDAUVALIDE(),
    .IDAUADDRE(),

    .NSSTCLKEN(CLKEN),
    .SSTCLKEN(CLKEN),

    .CURRPRI(),
    .SYSRESETREQ(),

    .PMCTEN(1'b0),
    .PMCTC(1'b0),

    .PMCTE(),
    .PMCTF(),

    .LOCKTCM(1'b0),
    .LOCKPAHB(1'b0),
    .INITECCEN(1'b0),
    .INITTCMEN(2'b11),
    .INITPAHBEN(1'b1),

    .ITCMWAIT(1'b0),
    .ITCMERR(1'b0),
    .ITCMRDATA(ITCMRDATA),
    .D0TCMWAIT(1'b0),
    .D0TCMERR(1'b0),
    .D0TCMRDATA(D0TCMRDATA),
    .D1TCMWAIT(1'b0),
    .D1TCMERR(1'b0),
    .D1TCMRDATA(D1TCMRDATA),
    .D2TCMWAIT(1'b0),
    .D2TCMERR(1'b0),
    .D2TCMRDATA(D2TCMRDATA),
    .D3TCMWAIT(1'b0),
    .D3TCMERR(1'b0),
    .D3TCMRDATA(D3TCMRDATA),
    .HREADYS(HREADYS),
    .HSELS(HSELS),
    .HTRANSS(HTRANSS),
    .HWRITES(HWRITES),
    .HWSTRBS(8'hFF),
    .HADDRS(HADDRS),
    .HSIZES(HSIZES),
    .HBURSTS(HBURSTS),
    .HPROTS(HPROTS),
    .HNONSECS(1'b0),
    .HWDATAS(HWDATAS),
    .HREADYCHKS(),
    .HTRANSCHKS(),
    .HADDRCHKS(),
    .HWDATACHKS(),
    .HWSTRBCHKS(),
    .HPROTCHKS(),
    .HCTRLCHK1S(),
    .HSELCHKS(),

    .ITCMCS(ITCMCS),
    .ITCMADDR(ITCMADDR),
    .ITCMWR(ITCMWR),
    .ITCMBYTEWR(ITCMBYTEWR),
    .ITCMPRIV(ITCMPRIV),
    .ITCMMASTER(ITCMMASTER),
    .ITCMWDATA(ITCMWDATA),

    .D0TCMCS(D0TCMCS),
    .D0TCMADDR(D0TCMADDR),
    .D0TCMWR(D0TCMWR),
    .D0TCMBYTEWR(D0TCMBYTEWR),
    .D0TCMPRIV(D0TCMPRIV),
    .D0TCMMASTER(D0TCMMASTER),
    .D0TCMWDATA(D0TCMWDATA),
    .D1TCMCS(D1TCMCS),
    .D1TCMADDR(D1TCMADDR),
    .D1TCMWR(D1TCMWR),
    .D1TCMBYTEWR(D1TCMBYTEWR),
    .D1TCMPRIV(D1TCMPRIV),
    .D1TCMMASTER(D1TCMMASTER),
    .D1TCMWDATA(D1TCMWDATA),
    .D2TCMCS(D2TCMCS),
    .D2TCMADDR(D2TCMADDR),
    .D2TCMWR(D2TCMWR),
    .D2TCMBYTEWR(D2TCMBYTEWR),
    .D2TCMPRIV(D2TCMPRIV),
    .D2TCMMASTER(D2TCMMASTER),
    .D2TCMWDATA(D2TCMWDATA),
    .D3TCMCS(D3TCMCS),
    .D3TCMADDR(D3TCMADDR),
    .D3TCMWR(D3TCMWR),
    .D3TCMBYTEWR(D3TCMBYTEWR),
    .D3TCMPRIV(D3TCMPRIV),
    .D3TCMMASTER(D3TCMMASTER),
    .D3TCMWDATA(D3TCMWDATA),
    .HREADYOUTS(HREADYOUTS),
    .HRESPS(HRESPS),
    .HRDATAS(HRDATAS),
    .SAHBWABORT(SAHBWABORT),
    .SAHBWABORTCHK(SAHBWABORTCHK),
    .HREADYOUTCHKS(),
    .HRDATACHKS(),
    .HRESPCHKS(),


    .FPIXC(),
    .FPOFC(),
    .FPUFC(),
    .FPIOC(),
    .FPDZC(),
    .FPIDC(),

    .MBISTREQ(1'b0),

    .DCLSCORECTL(12'b010101010101),
    .DCLSIWICCTL(6'b010101),
    .DCLSCORECOMPRES(),
    .DCLSIWICCOMPRES()

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
    .D0TCMBYTEWR(D0TCMBYTEWR[3:0]),
    .D0TCMWDATA(D0TCMWDATA[31:0]),
    .D0TCMRDATA(D0TCMRDATA[31:0]),

    .D1TCMCS(D1TCMCS),
    .D1TCMADDR(D1TCMADDR),
    .D1TCMWR(D1TCMWR),
    .D1TCMBYTEWR(D1TCMBYTEWR[3:0]),
    .D1TCMWDATA(D1TCMWDATA[31:0]),
    .D1TCMRDATA(D1TCMRDATA[31:0])
);

dtcm u_dtcm2 (
    .CLK(FCLK),
    .D0TCMCS(D2TCMCS),
    .D0TCMADDR(D2TCMADDR),
    .D0TCMWR(D2TCMWR),
    .D0TCMBYTEWR(D2TCMBYTEWR[3:0]),
    .D0TCMWDATA(D2TCMWDATA[31:0]),
    .D0TCMRDATA(D2TCMRDATA[31:0]),

    .D1TCMCS(D3TCMCS),
    .D1TCMADDR(D3TCMADDR),
    .D1TCMWR(D3TCMWR),
    .D1TCMBYTEWR(D3TCMBYTEWR[3:0]),
    .D1TCMWDATA(D3TCMWDATA[31:0]),
    .D1TCMRDATA(D3TCMRDATA[31:0])
);


itcm u_itcm (
    .CLK(FCLK),
    .ITCMCS(ITCMCS),
    .ITCMADDR(ITCMADDR),
    .ITCMWR(ITCMWR),
    .ITCMBYTEWR(ITCMBYTEWR[7:0]),
    .ITCMWDATA(ITCMWDATA[63:0]),
    .ITCMRDATA(ITCMRDATA[63:0])
);



endmodule
