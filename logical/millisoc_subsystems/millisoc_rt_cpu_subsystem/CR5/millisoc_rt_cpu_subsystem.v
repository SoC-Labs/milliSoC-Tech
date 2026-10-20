
module millisoc_rt_cpu_subsystem #(
    parameter BE=0,
    parameter GIC_ID_BITS=6) (
    //Clocks and Resets
    input  wire         CLKIN,
    input  wire         nSYSPORESET,
    input  wire         ACPRESETn,

    // AXI Master
    input  wire         ACLKENM0,
    output wire [3:0]   AWIDM0,
    output wire [31:0]  AWADDRM0,
    output wire [3:0]   AWLENM0,
    output wire [2:0]   AWSIZEM0,
    output wire [1:0]   AWBURSTM0,
    output wire [1:0]   AWLOCKM0,
    output wire [3:0]   AWCACHEM0,
    output wire [2:0]   AWPROTM0,
    output wire [3:0]   AWINNERM0,
    output wire         AWSHAREM0,
    output wire         AWUSERPTYM0,
    output wire         AWVALIDM0,
    output wire         AWVPTYM0,
    input  wire         AWREADYM0,
    input  wire         AWRPTYM0,
    output wire [3:0]   WIDM0,
    output wire [63:0]  WDATAM0,
    output wire [7:0]   WSTRBM0,
    output wire         WLASTM0,
    output wire         WVALIDM0,
    output wire         WVPTYM0,
    input  wire         WREADYM0,
    input  wire         WRPTYM0,
    input  wire [3:0]   BIDM0,
    input  wire [1:0]   BRESPM0,
    input  wire         BVALIDM0,
    input  wire         BVPTYM0,
    output wire         BREADYM0,
    output wire         BRPTYM0,
    output wire [3:0]   ARIDM0,
    output wire [31:0]  ARADDRM0,
    output wire [3:0]   ARLENM0,
    output wire [2:0]   ARSIZEM0,
    output wire [1:0]   ARBURSTM0,
    output wire [1:0]   ARLOCKM0,
    output wire [3:0]   ARCACHEM0,
    output wire [2:0]   ARPROTM0,
    output wire [3:0]   ARINNERM0,
    output wire         ARSHAREM0,
    output wire         ARUSERPTYM0,
    output wire         ARVALIDM0,
    output wire         ARVPTYM0,
    input  wire         ARREADYM0,
    input  wire         ARRPTYM0,
    input  wire [3:0]   RIDM0,
    input  wire [63:0]  RDATAM0,
    input  wire [1:0]   RRESPM0,
    input  wire         RLASTM0,
    input  wire         RVALIDM0,
    input  wire         RVPTYM0,
    output wire         RREADYM0,
    output wire         RRPTYM0,
    output wire [3:0]   AWADDRPTYM0,
    output wire [3:0]   AWCTLPTYM0,
    output wire [2:0]   WCTLPTYM0,
    output wire [7:0]   WERRCODEM0,
    input  wire [1:0]   BCTLPTYM0,
    output wire [3:0]   ARADDRPTYM0,
    output wire [3:0]   ARCTLPTYM0,
    input  wire [1:0]   RCTLPTYM0,
    input  wire [7:0]   RERRCODEM0,
    output wire [4:0]   AXIMFATAL0,
    output wire         AXIMCORR0,
    output wire [31:3]  MERRADDR0,

    // AXI-slave
    input  wire         ACLKENS0,
    input  wire [7:0]   AWIDS0,
    input  wire [31:0]  AWADDRS0,
    input  wire [3:0]   AWLENS0,
    input  wire [2:0]   AWSIZES0,
    input  wire [1:0]   AWBURSTS0,
    input  wire [1:0]   AWLOCKS0,
    input  wire [3:0]   AWCACHES0,
    input  wire [2:0]   AWPROTS0,
    input  wire         AWUSERPTYS0,
    input  wire         AWVALIDS0,
    input  wire         AWVPTYS0,
    output wire         AWREADYS0,
    output wire         AWRPTYS0,
    input  wire [7:0]   WIDS0,
    input  wire [63:0]  WDATAS0,
    input  wire [7:0]   WSTRBS0,
    input  wire         WLASTS0,
    input  wire         WVALIDS0,
    input  wire         WVPTYS0,
    output wire         WREADYS0,
    output wire         WRPTYS0,
    output wire [7:0]   BIDS0,
    output wire [1:0]   BRESPS0,
    output wire         BVALIDS0,
    output wire         BVPTYS0,
    input  wire         BREADYS0,
    input  wire         BRPTYS0,
    input  wire [7:0]   ARIDS0,
    input  wire [31:0]  ARADDRS0,
    input  wire [3:0]   ARLENS0,
    input  wire [2:0]   ARSIZES0,
    input  wire [1:0]   ARBURSTS0,
    input  wire [1:0]   ARLOCKS0,
    input  wire [3:0]   ARCACHES0,
    input  wire [2:0]   ARPROTS0,
    input  wire         ARUSERPTYS0,
    input  wire         ARVALIDS0,
    input  wire         ARVPTYS0,
    output wire         ARREADYS0,
    output wire         ARRPTYS0,
    output wire [7:0]   RIDS0,
    output wire [63:0]  RDATAS0,
    output wire [1:0]   RRESPS0,
    output wire         RLASTS0,
    output wire         RVALIDS0,
    output wire         RVPTYS0,
    input  wire         RREADYS0,
    input  wire         RRPTYS0,
    input  wire [3:0]   AWADDRPTYS0,
    input  wire [3:0]   AWCTLPTYS0,
    input  wire [2:0]   WCTLPTYS0,
    input  wire [7:0]   WERRCODES0,
    output wire [1:0]   BCTLPTYS0,
    input  wire [3:0]   ARADDRPTYS0,
    input  wire [3:0]   ARCTLPTYS0,
    output wire [1:0]   RCTLPTYS0,
    output wire [7:0]   RERRCODES0,
    output wire [4:0]   AXISFATAL0,
    output wire         AXISCORR0,
    output wire [22:3]  SERRADDR0,
    output wire [3:0]   SERRCSEL0,

    // Debug APB
    input  wire         DBGNOCLKSTOP,
    input  wire         PCLKENDBG,
    input  wire [31:12] DBGROMADDR,
    input  wire         DBGROMADDRV,
    output wire         DBGNOPWRDWN,

    input  wire         DBGEN0,
    input  wire         NIDEN0,
    input  wire         EDBGRQ0,
    output wire         DBGTRIGGER0,
    output wire         DBGACK0,
    output wire         COMMRX0,
    output wire         COMMTX0,
    input  wire         PSELDBG0,
    input  wire [11:2]  PADDRDBG0,
    input  wire         PADDRDBG310,
    output wire [31:0]  PRDATADBG0,
    input  wire [31:0]  PWDATADBG0,
    input  wire         PENABLEDBG0,
    output wire         PREADYDBG0,
    output wire         PSLVERRDBG0,
    input  wire         PWRITEDBG0,
    input  wire [31:12] DBGSELFADDR0,
    input  wire         DBGSELFADDRV0,
    input  wire         DBGRESTART0,
    output wire         DBGRESTARTED0,
    output wire         DBGRSTREQ0,

    //ETM
    output wire [13:0]  ETMICTL0,
    output wire [31:1]  ETMIA0,
    output wire [11:0]  ETMDCTL0,
    output wire [31:0]  ETMDA0,
    output wire [63:0]  ETMDD0,
    output wire [31:0]  ETMCID0,
    output wire         ETMWFIPENDING0,
    output wire [54:0]  EVNTBUS0,
    input  wire         ETMPWRUP0,
    input  wire         nETMWFIREADY0,
    input  wire [1:0]   ETMEXTOUT0,


    // Floating-point
    output wire         FPIXC0,
    output wire         FPOFC0,
    output wire         FPUFC0,
    output wire         FPIOC0,
    output wire         FPDZC0,
    output wire         FPIDC0,


    // Redundant-Logic
    input  wire [7:0]   DCCMINP,
    output wire [7:0]   DCCMOUT,
    input  wire [7:0]   DCCMINP2,
    output wire [7:0]   DCCMOUT2,

    //Interrupts
    input  wire         INTSYNCEN,
    input  wire         IRQADDRVSYNCEN,


    output wire         nPMUIRQ0,
    input  wire [31:0]  IRQS,
    //

    input  wire         nRESET0,
    input  wire         DBGRESET0n,
    input  wire         PRESETDBG0n,
    input  wire         nCPUHALT0,
    output wire         nCLKSTOPPED0,
    output wire         nWFEPIPESTOPPED0,
    output wire         nWFIPIPESTOPPED0,
    input  wire         EVENTI0,
    output wire         EVENTO0,

    // AXI-PP
    input  wire         ACLKENP0,
    output wire [3:0]   AWIDP0,
    output wire [31:0]  AWADDRP0,
    output wire [3:0]   AWLENP0,
    output wire [2:0]   AWSIZEP0,
    output wire [1:0]   AWBURSTP0,
    output wire [1:0]   AWLOCKP0,
    output wire [3:0]   AWCACHEP0,
    output wire [2:0]   AWPROTP0,
    output wire         AWVALIDP0,
    output wire         AWVPTYP0,
    input  wire         AWREADYP0,
    input  wire         AWRPTYP0,
    output wire [3:0]   AWADDRPTYP0,
    output wire [3:0]   AWCTLPTYP0,
    output wire [3:0]   WIDP0,
    output wire [31:0]  WDATAP0,
    output wire [6:0]   WERRCODEP0,
    output wire [3:0]   WSTRBP0,
    output wire         WLASTP0,
    output wire         WVALIDP0,
    output wire         WVPTYP0,
    input  wire         WREADYP0,
    input  wire         WRPTYP0,
    output wire [2:0]   WCTLPTYP0,
    input  wire [3:0]   BIDP0,
    input  wire [1:0]   BRESPP0,
    input  wire         BVALIDP0,
    input  wire         BVPTYP0,
    output wire         BREADYP0,
    output wire         BRPTYP0,
    input  wire [1:0]   BCTLPTYP0,
    output wire [3:0]   ARIDP0,
    output wire [31:0]  ARADDRP0,
    output wire [3:0]   ARLENP0,
    output wire [2:0]   ARSIZEP0,
    output wire [1:0]   ARBURSTP0,
    output wire [1:0]   ARLOCKP0,
    output wire [3:0]   ARCACHEP0,
    output wire [2:0]   ARPROTP0,
    output wire         ARVALIDP0,
    output wire         ARVPTYP0,
    input  wire         ARREADYP0,
    input  wire         ARRPTYP0,
    output wire [3:0]   ARADDRPTYP0,
    output wire [3:0]   ARCTLPTYP0,
    input  wire [3:0]   RIDP0,
    input  wire [31:0]  RDATAP0,
    input  wire [6:0]   RERRCODEP0,
    input  wire [1:0]   RRESPP0,
    input  wire         RLASTP0,
    input  wire         RVALIDP0,
    input  wire         RVPTYP0,
    output wire         RREADYP0,
    output wire         RRPTYP0,
    input  wire [1:0]   RCTLPTYP0,
    output wire [4:0]   PPXFATAL0,
    output wire         PPXCORR0,


    // GIC AXI
    // AXI read address channel
    input  wire         HSELVIC_GIC,         // VIC slave select
    input  wire  [11:2] HADDR_GIC,           // AHB address bus
    input  wire         HWRITE_GIC,          // AHB operation select
    input  wire         HREADYIN_GIC,        // Transfer done response on AHB from
    input  wire   [3:0] HPROT_GIC,           // AHB protection mode
    input  wire   [1:0] HTRANS_GIC,          // AHB transfer type
    input  wire   [2:0] HSIZE_GIC,           // AHB transfer size
    input  wire  [31:0] HWDATA_GIC,          // AHB write data
    output wire         HREADYOUT_GIC,       // Transfer done response for AHB
    output wire  [1:0]  HRESP_GIC,           // Transfer response to AHB
    output wire [31:0]  HRDATA_GIC,          // Read data to AHB

    // Split/Lock
    input  wire         CLKIN1,
    input  wire         SLSPLIT,
    input  wire         SLRESETn,
    input  wire         SLCLAMP,
    input  wire         SLERRACPn,
    input  wire         SLERRDBGn,

    // Power Modes
    input  wire [7:0]   RAMCONTROL0,
    input  wire [7:0]   RAMCONTROL1
);

wire [3:0]   AWCSELS0;
wire [3:0]   ARCSELS0;

assign AWCSELS0 = (AWADDRS0[31:24]==8'h80) ? 1'b1: 1'b0;
assign ARCSELS0 = (ARADDRS0[31:24]==8'h80) ? 1'b1: 1'b0;


wire [63:0]  ATCDATAIN0;
wire [13:0]  ATCPARITYIN0;
wire         ATCERROR0;
wire         ATCWAIT0;
wire         ATCLATEERROR0;
wire         ATCRETRY0;
wire         ATCEN00;
wire         ATCEN10;
wire [22:3]  ATCADDR0;
wire         ATCADDRPTY0;
wire [7:0]   ATCBYTEWR0;
wire         ATCWE0;
wire         ATCSEQ0;
wire [63:0]  ATCDATAOUT0;
wire [13:0]  ATCPARITYOUT0;
wire [2:0]   ATCACCTYPE0;

wire [63:0]  B0TCDATAIN0;
wire [13:0]  B0TCPARITYIN0;
wire         B0TCERROR0;
wire         B0TCWAIT0;
wire         B0TCLATEERROR0;
wire         B0TCRETRY0;
wire         B0TCEN00;
wire         B0TCEN10;
wire [22:3]  B0TCADDR0;
wire         B0TCADDRPTY0;
wire [7:0]   B0TCBYTEWR0;
wire         B0TCWE0;
wire         B0TCSEQ0;
wire [63:0]  B0TCDATAOUT0;
wire [13:0]  B0TCPARITYOUT0;
wire [2:0]   B0TCACCTYPE0;

wire [63:0]  B1TCDATAIN0;
wire [13:0]  B1TCPARITYIN0;
wire         B1TCERROR0;
wire         B1TCWAIT0;
wire         B1TCLATEERROR0;
wire         B1TCRETRY0;
wire         B1TCEN00;
wire         B1TCEN10;
wire [22:3]  B1TCADDR0;
wire         B1TCADDRPTY0;
wire [7:0]   B1TCBYTEWR0;
wire         B1TCWE0;
wire         B1TCSEQ0;
wire [63:0]  B1TCDATAOUT0;
wire [13:0]  B1TCPARITYOUT0;
wire [2:0]   B1TCACCTYPE0;

wire         nFIQ0;
wire         nIRQ0;
wire   [31:0] VICVECTADDROUT;  // Vector
wire          VICVECTADDRV;    // Address valid signal
wire          VICIRQACK;
CORTEXR5 u_cortexr5(
    //Clocks and Resets
    .CLKIN(CLKIN),
    .nSYSPORESET(nSYSPORESET),
    .ACPRESETn(ACPRESETn),

    // AXI-master
    .ACLKENM0(ACLKENM0),
    .AWIDM0(AWIDM0),
    .AWADDRM0(AWADDRM0),
    .AWLENM0(AWLENM0),
    .AWSIZEM0(AWSIZEM0),
    .AWBURSTM0(AWBURSTM0),
    .AWLOCKM0(AWLOCKM0),
    .AWCACHEM0(AWCACHEM0),
    .AWPROTM0(AWPROTM0),
    .AWINNERM0(AWINNERM0),
    .AWSHAREM0(AWSHAREM0),
    .AWUSERPTYM0(AWUSERPTYM0),
    .AWVALIDM0(AWVALIDM0),
    .AWVPTYM0(AWVPTYM0),
    .AWREADYM0(AWREADYM0),
    .AWRPTYM0(AWRPTYM0),
    .WIDM0(WIDM0),
    .WDATAM0(WDATAM0),
    .WSTRBM0(WSTRBM0),
    .WLASTM0(WLASTM0),
    .WVALIDM0(WVALIDM0),
    .WVPTYM0(WVPTYM0),
    .WREADYM0(WREADYM0),
    .WRPTYM0(WRPTYM0),
    .BIDM0(BIDM0),
    .BRESPM0(BRESPM0),
    .BVALIDM0(BVALIDM0),
    .BVPTYM0(BVPTYM0),
    .BREADYM0(BREADYM0),
    .BRPTYM0(BRPTYM0),
    .ARIDM0(ARIDM0),
    .ARADDRM0(ARADDRM0),
    .ARLENM0(ARLENM0),
    .ARSIZEM0(ARSIZEM0),
    .ARBURSTM0(ARBURSTM0),
    .ARLOCKM0(ARLOCKM0),
    .ARCACHEM0(ARCACHEM0),
    .ARPROTM0(ARPROTM0),
    .ARINNERM0(ARINNERM0),
    .ARSHAREM0(ARSHAREM0),
    .ARUSERPTYM0(ARUSERPTYM0),
    .ARVALIDM0(ARVALIDM0),
    .ARVPTYM0(ARVPTYM0),
    .ARREADYM0(ARREADYM0),
    .ARRPTYM0(ARRPTYM0),
    .RIDM0(RIDM0),
    .RDATAM0(RDATAM0),
    .RRESPM0(RRESPM0),
    .RLASTM0(RLASTM0),
    .RVALIDM0(RVALIDM0),
    .RVPTYM0(RVPTYM0),
    .RREADYM0(RREADYM0),
    .RRPTYM0(RRPTYM0),
    .AWADDRPTYM0(AWADDRPTYM0),
    .AWCTLPTYM0(AWCTLPTYM0),
    .WCTLPTYM0(WCTLPTYM0),
    .WERRCODEM0(WERRCODEM0),
    .BCTLPTYM0(BCTLPTYM0),
    .ARADDRPTYM0(ARADDRPTYM0),
    .ARCTLPTYM0(ARCTLPTYM0),
    .RCTLPTYM0(RCTLPTYM0),
    .RERRCODEM0(RERRCODEM0),
    .AXIMFATAL0(AXIMFATAL0),
    .AXIMCORR0(AXIMCORR0),
    .MERRADDR0(MERRADDR0),

    // AXI-slave
    .ACLKENS0(ACLKENS0),
    .AWIDS0(AWIDS0),
    .AWADDRS0({8'h00,AWADDRS0[23:0]}),
    .AWLENS0(AWLENS0),
    .AWSIZES0(AWSIZES0),
    .AWBURSTS0(AWBURSTS0),
    .AWLOCKS0(AWLOCKS0),
    .AWCACHES0(AWCACHES0),
    .AWPROTS0(AWPROTS0),
    .AWCSELS0(AWCSELS0),
    .AWUSERPTYS0(AWUSERPTYS0),
    .AWVALIDS0(AWVALIDS0),
    .AWVPTYS0(AWVPTYS0),
    .AWREADYS0(AWREADYS0),
    .AWRPTYS0(AWRPTYS0),
    .WIDS0(WIDS0),
    .WDATAS0(WDATAS0),
    .WSTRBS0(WSTRBS0),
    .WLASTS0(WLASTS0),
    .WVALIDS0(WVALIDS0),
    .WVPTYS0(WVPTYS0),
    .WREADYS0(WREADYS0),
    .WRPTYS0(WRPTYS0),
    .BIDS0(BIDS0),
    .BRESPS0(BRESPS0),
    .BVALIDS0(BVALIDS0),
    .BVPTYS0(BVPTYS0),
    .BREADYS0(BREADYS0),
    .BRPTYS0(BRPTYS0),
    .ARIDS0(ARIDS0),
    .ARADDRS0({8'h00,ARADDRS0[23:0]}),
    .ARLENS0(ARLENS0),
    .ARSIZES0(ARSIZES0),
    .ARBURSTS0(ARBURSTS0),
    .ARLOCKS0(ARLOCKS0),
    .ARCACHES0(ARCACHES0),
    .ARPROTS0(ARPROTS0),
    .ARCSELS0(ARCSELS0),
    .ARUSERPTYS0(ARUSERPTYS0),
    .ARVALIDS0(ARVALIDS0),
    .ARVPTYS0(ARVPTYS0),
    .ARREADYS0(ARREADYS0),
    .ARRPTYS0(ARRPTYS0),
    .RIDS0(RIDS0),
    .RDATAS0(RDATAS0),
    .RRESPS0(RRESPS0),
    .RLASTS0(RLASTS0),
    .RVALIDS0(RVALIDS0),
    .RVPTYS0(RVPTYS0),
    .RREADYS0(RREADYS0),
    .RRPTYS0(RRPTYS0),
    .AWADDRPTYS0(AWADDRPTYS0),
    .AWCTLPTYS0(AWCTLPTYS0),
    .WCTLPTYS0(WCTLPTYS0),
    .WERRCODES0(WERRCODES0),
    .BCTLPTYS0(BCTLPTYS0),
    .ARADDRPTYS0(ARADDRPTYS0),
    .ARCTLPTYS0(ARCTLPTYS0),
    .RCTLPTYS0(RCTLPTYS0),
    .RERRCODES0(RERRCODES0),
    .AXISFATAL0(AXISFATAL0),
    .AXISCORR0(AXISCORR0),
    .SERRADDR0(SERRADDR0),
    .SERRCSEL0(SERRCSEL0),

    // TCM
    .ATCDATAIN0(ATCDATAIN0),
    .ATCPARITYIN0(ATCPARITYIN0),
    .ATCERROR0(ATCERROR0),
    .ATCWAIT0(ATCWAIT0),
    .ATCLATEERROR0(ATCLATEERROR0),
    .ATCRETRY0(ATCRETRY0),
    .ATCEN00(ATCEN00),
    .ATCEN10(ATCEN10),
    .ATCADDR0(ATCADDR0),
    .ATCADDRPTY0(ATCADDRPTY0),
    .ATCBYTEWR0(ATCBYTEWR0),
    .ATCWE0(ATCWE0),
    .ATCSEQ0(ATCSEQ0),
    .ATCDATAOUT0(ATCDATAOUT0),
    .ATCPARITYOUT0(ATCPARITYOUT0),
    .ATCACCTYPE0(ATCACCTYPE0),
    // B-TCM0
    .B0TCDATAIN0(B0TCDATAIN0),
    .B0TCPARITYIN0(B0TCPARITYIN0),
    .B0TCERROR0(B0TCERROR0),
    .B0TCWAIT0(B0TCWAIT0),
    .B0TCLATEERROR0(B0TCLATEERROR0),
    .B0TCRETRY0(B0TCRETRY0),
    .B0TCEN00(B0TCEN00),
    .B0TCEN10(B0TCEN10),
    .B0TCADDR0(B0TCADDR0),
    .B0TCADDRPTY0(B0TCADDRPTY0),
    .B0TCBYTEWR0(B0TCBYTEWR0),
    .B0TCWE0(B0TCWE0),
    .B0TCSEQ0(B0TCSEQ0),
    .B0TCDATAOUT0(B0TCDATAOUT0),
    .B0TCPARITYOUT0(B0TCPARITYOUT0),
    .B0TCACCTYPE0(B0TCACCTYPE0),
    // B-TCM 1
    .B1TCDATAIN0(B1TCDATAIN0),
    .B1TCPARITYIN0(B1TCPARITYIN0),
    .B1TCERROR0(B1TCERROR0),
    .B1TCWAIT0(B1TCWAIT0),
    .B1TCLATEERROR0(B1TCLATEERROR0),
    .B1TCRETRY0(B1TCRETRY0),
    .B1TCEN00(B1TCEN00),
    .B1TCEN10(B1TCEN10),
    .B1TCADDR0(B1TCADDR0),
    .B1TCADDRPTY0(B1TCADDRPTY0),
    .B1TCBYTEWR0(B1TCBYTEWR0),
    .B1TCWE0(B1TCWE0),
    .B1TCSEQ0(B1TCSEQ0),
    .B1TCDATAOUT0(B1TCDATAOUT0),
    .B1TCPARITYOUT0(B1TCPARITYOUT0),
    .B1TCACCTYPE0(B1TCACCTYPE0),

    // Debug-APB
    .DBGNOCLKSTOP(DBGNOCLKSTOP),
    .PCLKENDBG(PCLKENDBG),
    .DBGROMADDR(DBGROMADDR),
    .DBGROMADDRV(DBGROMADDRV),
    .DBGNOPWRDWN(DBGNOPWRDWN),

    .DBGEN0(DBGEN0),
    .NIDEN0(NIDEN0),
    .EDBGRQ0(EDBGRQ0),
    .DBGTRIGGER0(DBGTRIGGER0),
    .DBGACK0(DBGACK0),
    .COMMRX0(COMMRX0),
    .COMMTX0(COMMTX0),
    .PSELDBG0(PSELDBG0),
    .PADDRDBG0(PADDRDBG0),
    .PADDRDBG310(PADDRDBG310),
    .PRDATADBG0(PRDATADBG0),
    .PWDATADBG0(PWDATADBG0),
    .PENABLEDBG0(PENABLEDBG0),
    .PREADYDBG0(PREADYDBG0),
    .PSLVERRDBG0(PSLVERRDBG0),
    .PWRITEDBG0(PWRITEDBG0),
    .DBGSELFADDR0(DBGSELFADDR0),
    .DBGSELFADDRV0(DBGSELFADDRV0),
    .DBGRESTART0(DBGRESTART0),
    .DBGRESTARTED0(DBGRESTARTED0),
    .DBGRSTREQ0(DBGRSTREQ0),

    //ETM
    .ETMICTL0(ETMICTL0),
    .ETMIA0(ETMIA0),
    .ETMDCTL0(ETMDCTL0),
    .ETMDA0(ETMDA0),
    .ETMDD0(ETMDD0),
    .ETMCID0(ETMCID0),
    .ETMWFIPENDING0(ETMWFIPENDING0),
    .EVNTBUS0(EVNTBUS0),
    .ETMPWRUP0(ETMPWRUP0),
    .nETMWFIREADY0(nETMWFIREADY0),
    .ETMEXTOUT0(ETMEXTOUT0),

    //DFT
    .SE0(1'b0),
    .RSTBYPASS0(1'b0),
    .MBTESTON0(1'b0),
    .MBISTDIN0(78'd0),
    .MBISTADDR0(20'd0),
    .MBISTCE0(1'b0),
    .MBISTSEL0(5'd0),
    .MBISTWE0(8'd0),

    .MBISTDOUT0(),
    .nVALIRQ0(),
    .nVALFIQ0(),
    .nVALRESET0(),
    .VALEDBGRQ0(),


    // Control
    .CFGEE(BE),
    .CFGIE(BE),
    .TEINIT(1'b0),
    .PARITYLEVEL(1'b0),
    .GROUPID(4'h0),


    .VINITHI0(1'b1),    // Boot from ROM 0xFFFF0000
    .INITRAMA0(1'b1),
    .INITRAMB0(1'b1),
    .LOCZRAMA0(1'b1),
    .CFGNMFI0(1'b0),
    .CFGATCMSZ0(4'b0101), // 16KB
    .CFGBTCMSZ0(4'b0101), // 16kb
    .PARECCENRAM0(3'b000), // No ECC
    .ERRENRAM0(3'b000), // No enable check on TCM
    .RMWENRAM0(2'b00), // Enable RMW
    .ENTCM1IF0(1'b1), // enable B1TCM
    .SLBTCMSB0(1'b1), // MSB to select B1TCM
    .INITPPX0(1'b1),
    .INITPPH0(1'b0),
    .PPHBASE0(20'h44000),
    .PPHSIZE0(5'b00101), // 16KB
    .PPXBASE0(20'h40000),
    .PPXSIZE0(5'b01000), // 128 KB
    .PPVBASE0(20'h40000),
    .PPVSIZE0(5'b00101),

    // Floating-point
    .FPIXC0(FPIXC0),
    .FPOFC0(FPOFC0),
    .FPUFC0(FPUFC0),
    .FPIOC0(FPIOC0),
    .FPDZC0(FPDZC0),
    .FPIDC0(FPIDC0),


    // Redundant-Logic
    .DCCMINP(DCCMINP),
    .DCCMOUT(DCCMOUT),
    .DCCMINP2(DCCMINP2),
    .DCCMOUT2(DCCMOUT2),

    //Interrupts
    .INTSYNCEN(1'b1),
    .IRQADDRVSYNCEN(1'b1),


    .nFIQ0(nFIQ0),
    .nIRQ0(nIRQ0),
    .IRQADDRV0(VICVECTADDRV),
    .IRQADDR0(VICVECTADDROUT[31:2]),
    .IRQACK0(VICIRQACK),
    .nPMUIRQ0(nPMUIRQ0),

    //

    .nRESET0(nRESET0),
    .DBGRESET0n(DBGRESET0n),
    .PRESETDBG0n(PRESETDBG0n),
    .nCPUHALT0(nCPUHALT0),
    .nCLKSTOPPED0(nCLKSTOPPED0),
    .nWFEPIPESTOPPED0(nWFEPIPESTOPPED0),
    .nWFIPIPESTOPPED0(nWFIPIPESTOPPED0),
    .EVENTI0(EVENTI0),
    .EVENTO0(EVENTO0),

    // AXI-PP
    .ACLKENP0(ACLKENP0),
    .AWIDP0(AWIDP0),
    .AWADDRP0(AWADDRP0),
    .AWLENP0(AWLENP0),
    .AWSIZEP0(AWSIZEP0),
    .AWBURSTP0(AWBURSTP0),
    .AWLOCKP0(AWLOCKP0),
    .AWCACHEP0(AWCACHEP0),
    .AWPROTP0(AWPROTP0),
    .AWVALIDP0(AWVALIDP0),
    .AWVPTYP0(AWVPTYP0),
    .AWREADYP0(AWREADYP0),
    .AWRPTYP0(AWRPTYP0),
    .AWADDRPTYP0(AWADDRPTYP0),
    .AWCTLPTYP0(AWCTLPTYP0),
    .WIDP0(WIDP0),
    .WDATAP0(WDATAP0),
    .WERRCODEP0(WERRCODEP0),
    .WSTRBP0(WSTRBP0),
    .WLASTP0(WLASTP0),
    .WVALIDP0(WVALIDP0),
    .WVPTYP0(WVPTYP0),
    .WREADYP0(WREADYP0),
    .WRPTYP0(WRPTYP0),
    .WCTLPTYP0(WCTLPTYP0),
    .BIDP0(BIDP0),
    .BRESPP0(BRESPP0),
    .BVALIDP0(BVALIDP0),
    .BVPTYP0(BVPTYP0),
    .BREADYP0(BREADYP0),
    .BRPTYP0(BRPTYP0),
    .BCTLPTYP0(BCTLPTYP0),
    .ARIDP0(ARIDP0),
    .ARADDRP0(ARADDRP0),
    .ARLENP0(ARLENP0),
    .ARSIZEP0(ARSIZEP0),
    .ARBURSTP0(ARBURSTP0),
    .ARLOCKP0(ARLOCKP0),
    .ARCACHEP0(ARCACHEP0),
    .ARPROTP0(ARPROTP0),
    .ARVALIDP0(ARVALIDP0),
    .ARVPTYP0(ARVPTYP0),
    .ARREADYP0(ARREADYP0),
    .ARRPTYP0(ARRPTYP0),
    .ARADDRPTYP0(ARADDRPTYP0),
    .ARCTLPTYP0(ARCTLPTYP0),
    .RIDP0(RIDP0),
    .RDATAP0(RDATAP0),
    .RERRCODEP0(RERRCODEP0),
    .RRESPP0(RRESPP0),
    .RLASTP0(RLASTP0),
    .RVALIDP0(RVALIDP0),
    .RVPTYP0(RVPTYP0),
    .RREADYP0(RREADYP0),
    .RRPTYP0(RRPTYP0),
    .RCTLPTYP0(RCTLPTYP0),
    .PPXFATAL0(PPXFATAL0),
    .PPXCORR0(PPXCORR0),


    // Split/Lock
    .CLKIN1(CLKIN1),
    .SLSPLIT(SLSPLIT),
    .SLRESETn(SLRESETn),
    .SLCLAMP(SLCLAMP),
    .SLERRACPn(SLERRACPn),
    .SLERRDBGn(SLERRDBGn),

    // Power Modes
    .RAMCONTROL0(RAMCONTROL0),
    .RAMCONTROL1(RAMCONTROL1)

    //
    // Optional Power State Control Ports
    // NOTE: Implementer may change these port names.
    //       If only one CPU is implemented then
    //       the CPU1 power control ports must be
    //       removed.
    //

    //
    `ifdef ARM_CORTEXR5_PWR_CTL
    ,
    // CPU0 Power Control
    .NORAMCLAMP0n(),
    .RAMCLAMP0n(),
    .NORAMPWRDOWN0(),
    .NORAMPWRDOWNACK0(),
    .RAMPWRDOWN0(),
    .RAMPWRDOWNACK0()

    `endif // ARM_CORTEXR5_PWR_CTL


);


cortexr5_tcm
#(.A_WIDTH                     (20),
    .ECC                         (1'b0)
    )
u_tcm_ram_a
    ( // Outputs
    .stall                       (ATCWAIT0),
    .retry                       (ATCRETRY0),
    .error                       (ATCERROR0),
    .lateerror                   (ATCLATEERROR0),
    .data_in                     (ATCDATAIN0),
    .parity_in                   (ATCPARITYIN0),
    // Inputs
    .clk                         (CLKIN),
    .rstn                        (nSYSPORESET),
    .addr                        (ATCADDR0),
    .cs                          ({ATCEN10,ATCEN00}),
    .we                          (ATCWE0),
    .strb                        (ATCBYTEWR0),
    .data_out                    (ATCDATAOUT0),
    .parity_out                  (ATCPARITYOUT0));

cortexr5_tcm
    #(.A_WIDTH                     (20),
    .ECC                         (1'b0)
    )
u_tcm_ram_b0
    (// Outputs
    .stall                       (B0TCWAIT0),
    .retry                       (B0TCRETRY0),
    .error                       (B0TCERROR0),
    .lateerror                   (B0TCLATEERROR0),
    .data_in                     (B0TCDATAIN0),
    .parity_in                   (B0TCPARITYIN0),
    // Inputs
    .clk                         (CLKIN),
    .rstn                        (nSYSPORESET),
    .addr                        (B0TCADDR0),
    .cs                          ({B0TCEN10,B0TCEN00}),
    .we                          (B0TCWE0),
    .strb                        (B0TCBYTEWR0),
    .data_out                    (B0TCDATAOUT0),
    .parity_out                  (B0TCPARITYOUT0));

cortexr5_tcm
    #(.A_WIDTH                     (20),
    .ECC                         (1'b0)
    )
u_tcm_ram_b1
    (// Outputs
    .stall                       (B1TCWAIT0),
    .retry                       (B1TCRETRY0),
    .error                       (B1TCERROR0),
    .lateerror                   (B1TCLATEERROR0),
    .data_in                     (B1TCDATAIN0),
    .parity_in                   (B1TCPARITYIN0),
    // Inputs
    .clk                         (CLKIN),
    .rstn                        (nSYSPORESET),
    .addr                        (B1TCADDR0),
    .cs                          ({B1TCEN10, B1TCEN00}),
    .we                          (B1TCWE0),
    .strb                        (B1TCBYTEWR0),
    .data_out                    (B1TCDATAOUT0),
    .parity_out                  (B1TCPARITYOUT0));


Vic u_vic(
    .HCLK(CLKIN),
    .HRESETn(nRESET0),
    .HSELVIC(HSELVIC_GIC),
    .HADDR(HADDR_GIC),
    .HWRITE(HWRITE_GIC),
    .HREADYIN(HREADYIN_GIC),
    .HPROT(HPROT_GIC),
    .HTRANS(HTRANS_GIC),
    .HSIZE(HSIZE_GIC),
    .HWDATA(HWDATA_GIC),
    .HREADYOUT(HREADYOUT_GIC),
    .HRESP(HRESP_GIC),
    .HRDATA(HRDATA_GIC),

    .VICINTSOURCE(IRQS),

    .nVICFIQIN(1'b1), // No daisy Chain
    .nVICIRQIN(1'b1), // No daisy Chain
    .VICVECTADDRIN(32'd0), // No daisy Chain
    .VICFIQINREG(1'b0),
    .VICIRQINREG(1'b0),
    .VICIRQACKOUT(),

    .nVICSYNCEN(1'b1),
    .VICIRQACK(VICIRQACK),

    .nVICFIQ(nFIQ0),
    .nVICIRQ(nIRQ0),
    .VICVECTADDROUT(VICVECTADDROUT),
    .VICVECTADDRV(VICVECTADDRV),

    .SCANENABLE(1'b0),
    .SCANINHCLK(1'b0),
    .SCANOUTHCLK()
);

endmodule
