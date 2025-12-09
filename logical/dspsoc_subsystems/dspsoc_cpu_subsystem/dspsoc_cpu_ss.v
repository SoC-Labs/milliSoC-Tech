//-----------------------------------------------------------------------------
// DSP SoC CPU Subsystem
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


module dspsoc_cpu_ss(

);



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
    // Ports would be connected here
    .CLKIN(),
    .CLKEN(),
    .FCLKEN(),
    .HCLKEN(),
    .CLK1EN(),
    .FCLK1EN(),
    .HCLK1EN(),
    .ETMCLKEN(),
    .STCLKEN(),
    .nSYSRESET(),
    .SYSRESETREQ(),
    .nPORESET(),
    .nDBGETMRESET(),
    .CPUWAIT(),
    .SWCLKTCK(),
    .TRACECLKIN(),
    .TRESETn(),
    // STATIC CONFIGURATION PINS
    .CFGBIGEND(),
    .CFGITCMSZ(),
    .CFGDTCMSZ(),
    .CFGAHBPSZ(),
    .CFGSTCALIB(),
    // RESET CONFIGURATION PINS
    .INITTCMEN(),
    .INITRMWEN(),
    .INITRETRYEN(),
    .INITAHBPEN(),
    .INITVTOR(),
    // ITCM
    .ITCMCS(),
    .ITCMADDR(),
    .ITCMWR(),
    .ITCMBYTEWR(),
    .ITCMPRIV(),
    .ITCMMASTER(),
    .ITCMWDATA(),
    .ITCMMBISTIN(),
    .ITCMWAIT(),
    .ITCMERR(),
    .ITCMRDATA(),
    .ITCMRETRY(),
    .ITCMMBISTOUT(),
    // DTCM
    .D0TCMCS(),
    .D0TCMADDR(),
    .D0TCMWR(),
    .D0TCMBYTEWR(),
    .D0TCMPRIV(),
    .D0TCMMASTER(),
    .D0TCMWDATA(),
    .D0TCMMBISTIN(),
    .D0TCMWAIT(),
    .D0TCMERR(),
    .D0TCMRDATA(),
    .D0TCMRETRY(),
    .D0TCMMBISTOUT(),
    .D1TCMCS(),
    .D1TCMADDR(),
    .D1TCMWR(),
    .D1TCMBYTEWR(),
    .D1TCMPRIV(),
    .D1TCMMASTER(),
    .D1TCMWDATA(),
    .D1TCMMBISTIN(),
    .D1TCMWAIT(),
    .D1TCMERR(),
    .D1TCMRDATA(),
    .D1TCMRETRY(),
    .D1TCMMBISTOUT(),
    // AXIM
    .ACLKEN(),
    .ARVALID(),
    .ARADDR(),
    .ARID(),
    .ARBURST(),
    .ARLEN(),
    .ARSIZE(),
    .ARLOCK(),
    .ARCACHE(),
    .ARPROT(),
    .ARMASTER(),
    .ARINNER(),
    .ARSHARE(),
    .ARREADY(),
    .AWVALID(),
    .AWADDR(),
    .AWID(),
    .AWBURST(),
    .AWLEN(),
    .AWSIZE(),
    .AWLOCK(),
    .AWCACHE(),
    .AWPROT(),
    .AWMASTER(),
    .AWINNER(),
    .AWSHARE(),
    .AWSPARSE(),
    .AWREADY(),
    .RREADY(),
    .RVALID(),
    .RID(),
    .RLAST(),
    .RDATA(),
    .RRESP(),
    .WVALID(),
    .WID(),
    .WDATA(),
    .WSTRB(),
    .WLAST(),
    .WREADY(),
    .BREADY(),
    .BVALID(),
    .BID(),
    .BRESP(),
    // AHBP
    .HTRANSP(),
    .HWRITEP(),
    .HSIZEP(),
    .HBURSTP(),
    .HPROTP(),
    .HMASTERP(),
    .HADDRP(),
    .HWDATAP(),
    .EXREQP(),
    .HREADYP(),
    .HRESPP(),
    .HRDATAP(),
    .EXRESPP(),
    // AHBs
    .HREADYOUTS(),
    .HRESPS(),
    .HRDATAS(),
    .AHBSRDY(),
    .WABORTS(),
    .AHBSPRI(),
    .HREADYS(),
    .HSELS(),
    .HTRANSS(),
    .HWRITES(),
    .HSIZES(),
    .HBURSTS(),
    .HPROTS(),
    .HADDRS(),
    .HWDATAS(),
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
    .TSVALUEB(),
    .TSCLKCHANGE(),
    // Debug
    .HALTED(),
    .DBGRESTARTED(),
    .DBGEN(),
    .NIDEN(),
    .EDBGRQ(),
    .DBGRESTART(),
    // Debug Protection
    .IADDR(),
    .IADBGPROT(),
    // Interrupts
    .IRQ(),
    .NMI(),
    // POWER CONTROL AND SLEEP
    .SLEEPING(),
    .SLEEPDEEP(),
    .GATEHCLK(),
    .SLEEPHOLDACKn(),
    .SLEEPHOLDREQn(),
    .WAKEUP(),
    .WICSENSE(),
    .WICENREQ(),
    .WICENACK(),
    .ETMPWRUPREQ(),
    // EVENTS AND ERRORS
    .LOCKUP(),
    .TXEV(),
    .ICERR(),
    .DCERR(),
    .ICDET(),
    .DCDET(),
    .RXEV(),
    // FPU EXCEPTION FLAGS
    .FPIXC(),
    .FPIDC(),
    .FPOFC(),
    .FPUFC(),
    .FPDZC(),
    .FPIOC(),
    // CROSS TRIGGER INTERFACE
    .CTICHIN(),
    .CTICHOUT(),
    .CTIIRQ(),
    // MBIST INTERFACE
    .MBISTACK(),
    .MBISTOUTDATA(),
    .MBISTIMPERR(),
    .nMBISTRESET(),
    .MBISTREQ(),
    .MBISTADDR(),
    .MBISTINDATA(),
    .MBISTWRITEEN(),
    .MBISTREADEN(),
    .MBISTARRAY(),
    .MBISTBE(),
    .MBISTCFG(),
    // DEBUG ACCESS PORT
    .DAPEN(),
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
    .MAXPORTSIZE(),
    .TRACECLK(),
    .TRACEDATA(),
    .TRACESWO(),
    .SWOACTIVE(),
    // ECO Rev Number
    .ECOREVNUM(36'd0),
    // Dual redundant CPU comparison control
    .DCCMINP(),
    .DCCMOUT(),
    .DCCMINP2(),
    .DCCMOUT2(),
    // DFT
    .DFTSE(),
    .DFTRSTDISABLE(),
    .DFTRAMHOLD(),
    // Control Wires
    .CTLPPBLOCK(4'h0)
);

dspsoc_cpu_dma u_dspsoc_cpu_dma (
    .HCLK(),
    .HRESETn(),

    .PCLKEN_DMA(),
    .PSEL_DMA(),
    .PEN_DMA(),
    .PWRITE_DMA(),
    .PADDR_DMA(),
    .PWDATA_DMA(),
    .PRDATA_DMA(),

    .HSEL_M7_AHBS(),
    .HADDR_M7_AHBS(),
    .HTRANS_M7_AHBS(),
    .HWRITE_M7_AHBS(),
    .HSIZE_M7_AHBS(),
    .HBURST_M7_AHBS(),
    .HPROT_M7_AHBS(),
    .HWDATA_M7_AHBS(),
    .HMASTLOCK_M7_AHBS(),
    .HREADYMUX_M7_AHBS(),
    .HRDATA_M7_AHBS(),
    .HREADYOUT_M7_AHBS(),
    .HRESP_M7_AHBS(),

    .HSEL_SYS_BUS(),
    .HADDR_SYS_BUS(),
    .HTRANS_SYS_BUS(),
    .HWRITE_SYS_BUS(),
    .HSIZE_SYS_BUS(),
    .HBURST_SYS_BUS(),
    .HPROT_SYS_BUS(),
    .HWDATA_SYS_BUS(),
    .HMASTLOCK_SYS_BUS(),
    .HREADYMUX_SYS_BUS(),
    .HRDATA_SYS_BUS(),
    .HREADYOUT_SYS_BUS(),
    .HRESP_SYS_BUS()
);


endmodule
