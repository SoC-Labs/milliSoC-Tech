//-----------------------------------------------------------------------------
// milliSoC debug subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
//
// Copyright (c) 2021-6, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
// Purpose:
//  Provide debug access to all CPU nodes in the system using the Arm
//  CoreSight SoC-400 debug subsystem.
//
//  The SoC-400 provides a single SWJ-DP (SW-DP / JTAG-DP) at the chip
//  boundary.  A DAPBUS interconnect fans the DP out to four access ports:
//
//    AP0 : APB-AP  -> cxapbic_1 (APB fabric for CoreSight debug peripherals)
//    AP1 : AXI-AP  -> NIC400 "DEBUG" port (system memory / peripherals)
//    AP2 : APB-AP  -> Cortex-R5 external debug interface (EDI)
//    AP3 : AHB-AP  -> Cortex-M85 external private peripheral bus (EPPB)
//
//  The M85 also has a dedicated EPPB APB master interface for CoreSight
//  components; this interface is arbitrated onto the APBIC input below.
//
//  The AP select number is encoded in DAPBUS address bits [15:8] and is
//  decoded by cxdapbusic_1.
//
//  Modules instantiated:
//    cxdapswjdp    - SWJ debug port (SW-DP / JTAG-DP)
//    cxdapbusic_1  - DAPBUS interconnect (4 master interfaces)
//    cxdapapbap    - APB access port  (AP0, AP2)
//    cxdapaxiap_1  - AXI4 access port (AP1)
//    cxdapahbap    - AHB  access port  (AP3)
//    cxapbic_1     - APB interconnect  (target of AP0)
//
//  Notes on address mapping
//  -----------------------
//  * cxdapswjdp drives DAPBUS address bits [15:8] with the AP select and
//    bits [7:2] with {AP bank select, AP register select}.  The DAPBUS
//    interconnect therefore needs no address adapter.
//
//  * cxdapapbap / cxdapahbap derive their target address from the AP TAR
//    (Target Address Register).  For the APB-AP only bits [29:0] of the TAR
//    are usable, giving a maximum address of 0x3FFFFFFC.
//
//  * The Cortex-R5 EDI decodes PADDRDBG0[11:2] inside a 4KB window, and uses
//    PADDRDBG310 as a "privileged / external debugger" qualifier.  It is
//    therefore driven from AP2's APB address as
//      PADDRDBG0[11:2] = paddr[11:2]  (TAR[9:0])
//      PADDRDBG310     = paddr[31]    (TAR[29])
//
//  * The Cortex-M85 EPPB AHB slave is reached by AP3. Its separate CoreSight
//    APB master reaches the APBIC, with PADDR31 and PADDR[19:2] encoding the
//    address per the M85 interface.
//-----------------------------------------------------------------------------

`default_nettype none

module millisoc_debug_subsystem(

    // ---- Clock and reset ---------------------------------------------------
    input  wire        dapclk,          // DAP clock
    input  wire        dapclken,        // DAP clock enable
    input  wire        dapresetn,       // DAP reset (active low)
    input  wire        poresetn,        // Power-on reset (active low)

    // ---- SWD / JTAG pad interface -----------------------------------------
    input  wire        swclktck,        // SW/JTAG clock
    input  wire        swditms,         // SW data in / JTAG TMS
    input  wire        tdi,             // JTAG data in
    input  wire        ntrst,           // JTAG TAP reset (active low)
    output wire        swdo,            // SW data out
    output wire        swdoen,          // SW data out enable
    output wire        tdo,             // JTAG data out
    output wire        ntdoen,          // JTAG data out enable

    // ---- AP1 : AXI4 master -> NIC400 "DEBUG" slave port --------------------
    output wire [31:0] dap_awaddr,
    output wire [7:0]  dap_awlen,
    output wire [2:0]  dap_awsize,
    output wire [1:0]  dap_awburst,
    output wire        dap_awlock,
    output wire [3:0]  dap_awcache,
    output wire [2:0]  dap_awprot,
    output wire        dap_awvalid,
    input  wire        dap_awready,
    output wire [63:0] dap_wdata,
    output wire [7:0]  dap_wstrb,
    output wire        dap_wlast,
    output wire        dap_wvalid,
    input  wire        dap_wready,
    input  wire [1:0]  dap_bresp,
    input  wire        dap_bvalid,
    output wire        dap_bready,
    output wire [31:0] dap_araddr,
    output wire [7:0]  dap_arlen,
    output wire [2:0]  dap_arsize,
    output wire [1:0]  dap_arburst,
    output wire        dap_arlock,
    output wire [3:0]  dap_arcache,
    output wire [2:0]  dap_arprot,
    output wire        dap_arvalid,
    input  wire        dap_arready,
    input  wire [63:0] dap_rdata,
    input  wire [1:0]  dap_rresp,
    input  wire        dap_rlast,
    input  wire        dap_rvalid,
    output wire        dap_rready,

    // ---- CPU/system bus APB access to the CoreSight APBIC -----------------
    input  wire [31:0] sys_paddr,
    input  wire [31:0] sys_pwdata,
    input  wire        sys_psel,
    input  wire        sys_penable,
    input  wire        sys_pwrite,
    output wire [31:0] sys_prdata,
    output wire        sys_pready,
    output wire        sys_pslverr,

    // ---- Cortex-M85 EPPB CoreSight APB master ------------------------------
    input  wire [31:0] m85_paddr,
    input  wire [31:0] m85_pwdata,
    input  wire        m85_psel,
    input  wire        m85_penable,
    input  wire        m85_pwrite,
    output wire [31:0] m85_prdata,
    output wire        m85_pready,
    output wire        m85_pslverr,

    // ---- AP2 : APB master -> Cortex-R5 external debug interface ------------
    output wire        r5_psel,
    output wire [11:2] r5_paddr,
    output wire        r5_paddr31,
    output wire        r5_penable,
    output wire        r5_pwrite,
    output wire [31:0] r5_pwdata,
    input  wire [31:0] r5_prdata,
    input  wire        r5_pready,
    input  wire        r5_pslverr,

    // ---- AP3 : AHB master -> Cortex-M85 EPPB -------------------------------
    output wire [31:0] m85_haddr,
    output wire [1:0]  m85_htrans,
    output wire        m85_hwrite,
    output wire [2:0]  m85_hsize,
    output wire [6:0]  m85_hprot,
    output wire [31:0] m85_hwdata,
    input  wire [31:0] m85_hrdata,
    input  wire        m85_hready,
    input  wire [1:0]  m85_hresp,

    // ---- Debug power-up request from the DP (active high) ------------------
    output wire        dap_pwrupreq
);

  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------

  // AP select numbers, encoded in DAPBUS address bits [15:8]
  localparam [7:0] AP_SEL_APBIC = 8'd0;   // AP0 - APB-AP -> cxapbic_1
  localparam [7:0] AP_SEL_AXI   = 8'd1;   // AP1 - AXI-AP -> NIC400
  localparam [7:0] AP_SEL_R5    = 8'd2;   // AP2 - APB-AP -> R5 EDI
  localparam [7:0] AP_SEL_M85   = 8'd3;   // AP3 - AHB-AP -> M85 EPPB

  // System-visible base of the CoreSight APBIC ROM table.
  localparam [31:0] ROM_BASE_APBIC = 32'hE00F_0000;

  // Target ID presented by the APBIC in its CoreSight ROM table.
  localparam [31:0] APBIC_TARGET_ID = 32'h0000_0000;

  //---------------------------------------------------------------------------
  // DAPBUS: SWJ-DP (slave side of the interconnect)
  //---------------------------------------------------------------------------
  wire [15:2] dapcaddrs;
  wire        dapsels;
  wire        dapenables;
  wire        dapwrites;
  wire [31:0] dapwdatas;
  wire        dapaborts;
  wire [31:0] daprdatas;
  wire        dapreadys;
  wire        dapslverrs;

  //---------------------------------------------------------------------------
  // DAPBUS: access ports (master side of the interconnect)
  //---------------------------------------------------------------------------
  // AP0 - APB-AP -> APBIC
  wire [7:2]  dapcaddrm0;
  wire        dapselm0;
  wire        dapenablem0;
  wire        dapwritem0;
  wire [31:0] dapwdatam0;
  wire        dapabortm0;
  wire [31:0] daprdatam0;
  wire        dapreadym0;
  wire        dapslverrm0;

  // AP1 - AXI-AP -> NIC400
  wire [7:2]  dapcaddrm1;
  wire        dapselm1;
  wire        dapenablem1;
  wire        dapwritem1;
  wire [31:0] dapwdatam1;
  wire        dapabortm1;
  wire [31:0] daprdatam1;
  wire        dapreadym1;
  wire        dapslverrm1;

  // AP2 - APB-AP -> R5 EDI
  wire [7:2]  dapcaddrm2;
  wire        dapselm2;
  wire        dapenablem2;
  wire        dapwritem2;
  wire [31:0] dapwdatam2;
  wire        dapabortm2;
  wire [31:0] daprdatam2;
  wire        dapreadym2;
  wire        dapslverrm2;

  // AP3 - AHB-AP -> M85 EPPB
  wire [7:2]  dapcaddrm3;
  wire        dapselm3;
  wire        dapenablem3;
  wire        dapwritem3;
  wire [31:0] dapwdatam3;
  wire        dapabortm3;
  wire [31:0] daprdatam3;
  wire        dapreadym3;
  wire        dapslverrm3;

  //---------------------------------------------------------------------------
  // AP0 APB interface (to the APBIC)
  //---------------------------------------------------------------------------
  wire        apb_psel0;
  wire        apb_penable0;
  wire        apb_pwrite0;
  wire [31:2] apb_paddr0;
  wire [31:0] apb_pwdata0;
  wire        apb_pready0;
  wire        apb_pslverr0;
  wire [31:0] apb_prdata0;
  wire        apb_pdbgswen0;

  //---------------------------------------------------------------------------
  // APBIC input mux: external AP0, NIC400 DEBUG_S, and the M85 EPPB APB port
  //---------------------------------------------------------------------------
  reg         apb_owner_valid;
  reg  [1:0]  apb_owner;
  reg  [1:0]  apb_rr_priority;
  reg  [1:0]  apb_grant;
  wire [1:0]  apb_mux_owner;
  wire        apb_mux_psel;
  wire        apb_mux_penable;
  wire        apb_mux_pwrite;
  wire [31:2] apb_mux_paddr;
  wire [31:0] apb_mux_pwdata;
  wire        apb_mux_pready;
  wire        apb_mux_pslverr;
  wire [31:0] apb_mux_prdata;

  //---------------------------------------------------------------------------
  // AP2 APB interface (to the R5 EDI)
  //---------------------------------------------------------------------------
  wire        apb_psel2;
  wire        apb_penable2;
  wire        apb_pwrite2;
  wire [31:2] apb_paddr2;
  wire [31:0] apb_pwdata2;
  wire        apb_pready2;
  wire        apb_pslverr2;
  wire [31:0] apb_prdata2;
  wire        apb_pdbgswen2;

  //---------------------------------------------------------------------------
  // SWJ-DP
  //---------------------------------------------------------------------------
  wire        dp_cdbgpwrupreq;
  wire        dp_csyspwrupreq;
  wire        dp_cdbgrstreq;
  wire        dp_jtagnsw;
  wire        dp_jtagtop;

  localparam [1:0] APB_OWNER_DAP = 2'd0;
  localparam [1:0] APB_OWNER_SYS = 2'd1;
  localparam [1:0] APB_OWNER_M85 = 2'd2;

  always @* begin
    case (apb_rr_priority)
      APB_OWNER_DAP: begin
        if (apb_psel0)
          apb_grant = APB_OWNER_DAP;
        else if (sys_psel)
          apb_grant = APB_OWNER_SYS;
        else
          apb_grant = APB_OWNER_M85;
      end
      APB_OWNER_SYS: begin
        if (sys_psel)
          apb_grant = APB_OWNER_SYS;
        else if (m85_psel)
          apb_grant = APB_OWNER_M85;
        else
          apb_grant = APB_OWNER_DAP;
      end
      default: begin
        if (m85_psel)
          apb_grant = APB_OWNER_M85;
        else if (apb_psel0)
          apb_grant = APB_OWNER_DAP;
        else
          apb_grant = APB_OWNER_SYS;
      end
    endcase
  end

  assign apb_mux_owner = apb_owner_valid ? apb_owner : apb_grant;
  assign apb_mux_psel =
      (apb_mux_owner == APB_OWNER_SYS) ? sys_psel :
      (apb_mux_owner == APB_OWNER_M85) ? m85_psel : apb_psel0;
  assign apb_mux_penable =
      (apb_mux_owner == APB_OWNER_SYS) ? sys_penable :
      (apb_mux_owner == APB_OWNER_M85) ? m85_penable : apb_penable0;
  assign apb_mux_pwrite =
      (apb_mux_owner == APB_OWNER_SYS) ? sys_pwrite :
      (apb_mux_owner == APB_OWNER_M85) ? m85_pwrite : apb_pwrite0;
  assign apb_mux_paddr =
      (apb_mux_owner == APB_OWNER_SYS) ? sys_paddr[31:2] :
      (apb_mux_owner == APB_OWNER_M85) ? m85_paddr[31:2] : apb_paddr0;
  assign apb_mux_pwdata =
      (apb_mux_owner == APB_OWNER_SYS) ? sys_pwdata :
      (apb_mux_owner == APB_OWNER_M85) ? m85_pwdata : apb_pwdata0;

  assign sys_prdata = (apb_mux_owner == APB_OWNER_SYS) ? apb_mux_prdata : 32'b0;
  assign sys_pready = (apb_mux_owner == APB_OWNER_SYS) && apb_mux_pready;
  assign sys_pslverr = (apb_mux_owner == APB_OWNER_SYS) && apb_mux_pslverr;
  assign m85_prdata = (apb_mux_owner == APB_OWNER_M85) ? apb_mux_prdata : 32'b0;
  assign m85_pready = (apb_mux_owner == APB_OWNER_M85) && apb_mux_pready;
  assign m85_pslverr = (apb_mux_owner == APB_OWNER_M85) && apb_mux_pslverr;
  assign apb_prdata0 = (apb_mux_owner == APB_OWNER_DAP) ? apb_mux_prdata : 32'b0;
  assign apb_pready0 = (apb_mux_owner == APB_OWNER_DAP) && apb_mux_pready;
  assign apb_pslverr0 = (apb_mux_owner == APB_OWNER_DAP) && apb_mux_pslverr;

  always @(posedge dapclk or negedge dapresetn) begin
    if (!dapresetn) begin
      apb_owner_valid <= 1'b0;
      apb_owner <= APB_OWNER_DAP;
      apb_rr_priority <= APB_OWNER_DAP;
    end else if (!apb_owner_valid && apb_mux_psel) begin
      apb_owner <= apb_grant;
      apb_owner_valid <= 1'b1;
    end else if (apb_owner_valid &&
                 apb_mux_psel && apb_mux_penable && apb_mux_pready) begin
      apb_owner_valid <= 1'b0;
      case (apb_owner)
        APB_OWNER_DAP: apb_rr_priority <= APB_OWNER_SYS;
        APB_OWNER_SYS: apb_rr_priority <= APB_OWNER_M85;
        default:       apb_rr_priority <= APB_OWNER_DAP;
      endcase
    end
  end

  //---------------------------------------------------------------------------
  // Instance: SWJ debug port
  //---------------------------------------------------------------------------
  cxdapswjdp #(
      .IRLEN8(0)          // 4 bit JTAG instruction register
  ) u_dap (
      // ---- To pads ----
      .swdo(swdo),
      .swdoen(swdoen),
      .tdo(tdo),
      .ntdoen(ntdoen),
      .swclktck(swclktck),
      .swditms(swditms),
      .tdi(tdi),
      .ntrst(ntrst),

      // ---- DAPBUS (slave interface of the interconnect) ----
      .dapcaddr(dapcaddrs),
      .dapwrite(dapwrites),
      .dapenable(dapenables),
      .dapabort(dapaborts),
      .dapsel(dapsels),
      .dapwdata(dapwdatas),
      .daprdata(daprdatas),
      .dapready(dapreadys),
      .dapslverr(dapslverrs),

      // ---- Power and reset ----
      .npotrst(poresetn),
      .dapresetn(dapresetn),
      .dapclk(dapclk),
      .dapclken(dapclken),

      // ---- Power management ----
      .cdbgpwrupreq(dp_cdbgpwrupreq),
      .csyspwrupreq(dp_csyspwrupreq),
      .cdbgrstreq(dp_cdbgrstreq),
      .cdbgpwrupack(1'b1),   // debug power domain is always available
      .csyspwrupack(1'b1),   // system power domain is always available
      .cdbgrstack(1'b0),     // no debug reset controller in Stage 0

      // ---- Multidrop ----
      .targetid(32'h0000_0000),
      .instanceid(4'h0),

      .jtagnsw(dp_jtagnsw),
      .jtagtop(dp_jtagtop)
  );

  // The DP's debug power-up request.  It is exported so that a system level
  // power controller can gate the debug power domains (the Cortex-M85
  // debug power controller integration is deferred to a later stage).
  assign dap_pwrupreq = dp_cdbgpwrupreq;

  // Unused DP outputs
  wire _unused_dp = &{1'b0, dp_csyspwrupreq, dp_cdbgrstreq, dp_jtagnsw, dp_jtagtop};

  //---------------------------------------------------------------------------
  // Instance: DAPBUS interconnect
  //---------------------------------------------------------------------------
  cxdapbusic_1 u_dap_busic (

      // ---- Master interface 0 : AP0 (APB-AP -> APBIC) ----
      .dapcaddrm0(dapcaddrm0),
      .dapselm0(dapselm0),
      .dapenablem0(dapenablem0),
      .dapwritem0(dapwritem0),
      .dapwdatam0(dapwdatam0),
      .dapabortm0(dapabortm0),
      .daprdatam0(daprdatam0),
      .dapreadym0(dapreadym0),
      .dapslverrm0(dapslverrm0),

      // ---- Master interface 1 : AP1 (AXI-AP -> NIC400) ----
      .dapcaddrm1(dapcaddrm1),
      .dapselm1(dapselm1),
      .dapenablem1(dapenablem1),
      .dapwritem1(dapwritem1),
      .dapwdatam1(dapwdatam1),
      .dapabortm1(dapabortm1),
      .daprdatam1(daprdatam1),
      .dapreadym1(dapreadym1),
      .dapslverrm1(dapslverrm1),

      // ---- Master interface 2 : AP2 (APB-AP -> R5 EDI) ----
      .dapcaddrm2(dapcaddrm2),
      .dapselm2(dapselm2),
      .dapenablem2(dapenablem2),
      .dapwritem2(dapwritem2),
      .dapwdatam2(dapwdatam2),
      .dapabortm2(dapabortm2),
      .daprdatam2(daprdatam2),
      .dapreadym2(dapreadym2),
      .dapslverrm2(dapslverrm2),

      // ---- Master interface 3 : AP3 (AHB-AP -> M85 EPPB) ----
      .dapcaddrm3(dapcaddrm3),
      .dapselm3(dapselm3),
      .dapenablem3(dapenablem3),
      .dapwritem3(dapwritem3),
      .dapwdatam3(dapwdatam3),
      .dapabortm3(dapabortm3),
      .daprdatam3(daprdatam3),
      .dapreadym3(dapreadym3),
      .dapslverrm3(dapslverrm3),

      // ---- Slave interface : SWJ-DP ----
      .dapcaddrs(dapcaddrs),
      .dapsels(dapsels),
      .dapenables(dapenables),
      .dapwrites(dapwrites),
      .dapwdatas(dapwdatas),
      .dapaborts(dapaborts),
      .daprdatas(daprdatas),
      .dapreadys(dapreadys),
      .dapslverrs(dapslverrs)
  );

  //---------------------------------------------------------------------------
  // Instance: AP0 - APB access port -> APB interconnect
  //---------------------------------------------------------------------------
  cxdapapbap u_dap_ap_apb_ap (
      .dapclk(dapclk),
      .dapclken(dapclken),
      .dapresetn(dapresetn),

      .dapsel(dapselm0),
      .dapenable(dapenablem0),
      .dapwrite(dapwritem0),
      .dapabort(dapabortm0),
      .dapcaddr(dapcaddrm0),
      .dapwdata(dapwdatam0),
      .dapready(dapreadym0),
      .dapslverr(dapslverrm0),
      .daprdata(daprdatam0),

      .deviceen(1'b1),
      .rombaseaddr(ROM_BASE_APBIC),

      .psel(apb_psel0),
      .penable(apb_penable0),
      .pwrite(apb_pwrite0),
      .paddr(apb_paddr0),
      .pwdata(apb_pwdata0),
      .pready(apb_pready0),
      .pslverr(apb_pslverr0),
      .prdata(apb_prdata0),

      .pdbgswen(apb_pdbgswen0)
  );

  //---------------------------------------------------------------------------
  // Instance: APB interconnect (target of AP0)
  //
  //  The APBIC master interfaces are not used in Stage 0 - they exist so
  //  that CoreSight peripherals can be attached to the debug APB fabric in
  //  a later stage.  Their read data is tied to zero and they always report
  //  ready, so that an access to an unimplemented window cannot hang the DAP.
  //---------------------------------------------------------------------------
  cxapbic_1 u_dap_apbic (

      // ---- Clock and reset ----
      .clk(dapclk),
      .resetn(dapresetn),

      // ---- Slave interface 0 : from AP0 ----
      .paddrs0(apb_mux_paddr[13:2]),
      .psels0(apb_mux_psel),
      .penables0(apb_mux_penable),
      .pwrites0(apb_mux_pwrite),
      .pwdatas0(apb_mux_pwdata),
      .prdatas0(apb_mux_prdata),
      .preadys0(apb_mux_pready),
      .pslverrs0(apb_mux_pslverr),
      .paddr31s0(apb_mux_paddr[31]),

      // ---- Master interface 0 : unused in Stage 0 ----
      .paddrm0(),
      .paddr31m0(),
      .pselm0(),
      .penablem0(),
      .pwritem0(),
      .pwdatam0(),
      .prdatam0(32'h0000_0000),
      .preadym0(1'b1),
      .pslverrm0(1'b0),

      // ---- Master interface 1 : unused in Stage 0 ----
      .paddrm1(),
      .paddr31m1(),
      .pselm1(),
      .penablem1(),
      .pwritem1(),
      .pwdatam1(),
      .prdatam1(32'h0000_0000),
      .preadym1(1'b1),
      .pslverrm1(1'b0),

      // ---- Target ID ----
      .targetid(APBIC_TARGET_ID),

      // ---- Authentication ----
      //  Arm guidance: slave interface 0 is fed from the DAP's APB-AP, so
      //  dbgswen is wired to 1 at the APBIC top level.
      .dbgswen(1'b1)
  );

  //---------------------------------------------------------------------------
  // Instance: AP1 - AXI4 access port -> NIC400 "DEBUG" slave port
  //---------------------------------------------------------------------------
  cxdapaxiap_1 u_dap_ap_axi_ap (
      .clk(dapclk),
      .resetn(dapresetn),

      .dapcaddr(dapcaddrm1),
      .dapsel(dapselm1),
      .dapenable(dapenablem1),
      .dapwrite(dapwritem1),
      .dapwdata(dapwdatam1),
      .dapabort(dapabortm1),
      .daprdata(daprdatam1),
      .dapready(dapreadym1),
      .dapslverr(dapslverrm1),

      .dbgen(1'b1),
      .spiden(1'b0),

      .awaddr(dap_awaddr),
      .awlen(dap_awlen),
      .awsize(dap_awsize),
      .awburst(dap_awburst),
      .awlock(dap_awlock),
      .awcache(dap_awcache),
      .awprot(dap_awprot),
      .awvalid(dap_awvalid),
      .awready(dap_awready),
      .wdata(dap_wdata),
      .wstrb(dap_wstrb),
      .wlast(dap_wlast),
      .wvalid(dap_wvalid),
      .wready(dap_wready),
      .bresp(dap_bresp),
      .bvalid(dap_bvalid),
      .bready(dap_bready),
      .araddr(dap_araddr),
      .arlen(dap_arlen),
      .arsize(dap_arsize),
      .arburst(dap_arburst),
      .arlock(dap_arlock),
      .arcache(dap_arcache),
      .arprot(dap_arprot),
      .arvalid(dap_arvalid),
      .arready(dap_arready),
      .rdata(dap_rdata),
      .rresp(dap_rresp),
      .rlast(dap_rlast),
      .rvalid(dap_rvalid),
      .rready(dap_rready),

      // AXI attribute outputs - not used by the NIC400 DEBUG port
      .awdomain(),
      .awsnoop(),
      .awbar(),
      .ardomain(),
      .arsnoop(),
      .arbar(),

      .rombaseaddrl(32'h0000_0000)
  );

  //---------------------------------------------------------------------------
  // Instance: AP2 - APB access port -> Cortex-R5 external debug interface
  //
  //  The R5 decodes PADDRDBG0[11:2] within a 4KB window and uses PADDRDBG310
  //  as the "external debugger / privileged" qualifier, so it is driven
  //  directly from the APB address produced by the access port.
  //---------------------------------------------------------------------------
  cxdapapbap u_dap_ap_r5_ap (
      .dapclk(dapclk),
      .dapclken(dapclken),
      .dapresetn(dapresetn),

      .dapsel(dapselm2),
      .dapenable(dapenablem2),
      .dapwrite(dapwritem2),
      .dapabort(dapabortm2),
      .dapcaddr(dapcaddrm2),
      .dapwdata(dapwdatam2),
      .dapready(dapreadym2),
      .dapslverr(dapslverrm2),
      .daprdata(daprdatam2),

      .deviceen(1'b1),
      .rombaseaddr(32'h0000_0000),

      .psel(apb_psel2),
      .penable(apb_penable2),
      .pwrite(apb_pwrite2),
      .paddr(apb_paddr2),
      .pwdata(apb_pwdata2),
      .pready(apb_pready2),
      .pslverr(apb_pslverr2),
      .prdata(apb_prdata2),

      .pdbgswen(apb_pdbgswen2)
  );

  assign r5_psel    = apb_psel2;
  assign r5_penable = apb_penable2;
  assign r5_pwrite  = apb_pwrite2;
  assign r5_pwdata  = apb_pwdata2;
  assign r5_paddr   = apb_paddr2[11:2];
  assign r5_paddr31 = apb_paddr2[31];

  // Return path from the Cortex-R5 external debug interface.  These must be
  // fed back into the APB-AP: leaving them unconnected makes its APB transfer
  // state machine wait forever on an unknown PREADY.
  assign apb_prdata2  = r5_prdata;
  assign apb_pready2  = r5_pready;
  assign apb_pslverr2 = r5_pslverr;

  //---------------------------------------------------------------------------
  // Instance: AP3 - AHB access port -> Cortex-M85 EPPB
  //
  //  The M85's external private peripheral bus is an AHB slave which carries
  //  the core debug registers (and the MCU CoreSight ROM table / CTI).  The
  //  AHB access port supports the full 32 bit TAR, so the debugger can use
  //  the architectural CoreSight addresses (e.g. 0xE00FE000) directly.
  //---------------------------------------------------------------------------
  cxdapahbap u_dap_ap_ahb_ap (
      .dapclk(dapclk),
      .dapclken(dapclken),
      .dapresetn(dapresetn),

      .dbgen(1'b1),
      .spiden(1'b0),

      .dapsel(dapselm3),
      .dapenable(dapenablem3),
      .dapwrite(dapwritem3),
      .dapabort(dapabortm3),
      .dapcaddr(dapcaddrm3),
      .dapwdata(dapwdatam3),

      .hreadym(m85_hready),
      .hrespm(m85_hresp),
      .hrdatam(m85_hrdata),
      .rombaseaddr(32'hE00F_E000),

      .dapready(dapreadym3),
      .dapslverr(dapslverrm3),
      .daprdata(daprdatam3),

      .hwritem(m85_hwrite),
      .hlockm(),
      .htransm(m85_htrans),
      .hsizem(m85_hsize),
      .hburstm(),
      .hbstrbm(),
      .hprotm(m85_hprot),
      .haddrm(m85_haddr),
      .hwdatam(m85_hwdata)
  );

  //---------------------------------------------------------------------------
  // Unused signals
  //---------------------------------------------------------------------------
  wire _unused = &{1'b0, apb_pdbgswen0, apb_pdbgswen2,
                   1'b0 /* AP_SEL_* are documentation only */};

endmodule

`default_nettype wire
