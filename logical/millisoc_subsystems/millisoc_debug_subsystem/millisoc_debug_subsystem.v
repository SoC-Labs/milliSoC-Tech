//-----------------------------------------------------------------------------
// milliSoC debug subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
// 
// Copyright � 2021-6, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
// Purpose:
//  provide debug access to all cpu nodes in system
//-----------------------------------------------------------------------------
// Modules instantiated:
//  cxdapswjdp  (u_dap)


module millisoc_debug_subsystem(

    input wire      clk,
    input wire      poresetn,
    input wire      dapresetn,      // DAP Reset
    input wire      clken,       // DAP Clock Enable

    // to pads
    input wire      swclktck,   // SW/jtag Clock

    output wire     swdo,       // SW Data Out
    output wire     swdoen,     // SW Data Out Enable
    input wire      swditms,    // SW Debug Data In / jtag Test Mode Select

    output wire     tdo,        // jtag TAP Data Out
    output wire     ntdoen,     // tdo enable
    input wire      tdi,        // jtag TAP Data In / Alternative input function

    input wire      ntrst,          // jtag TAP Reset

    output wire     cdbgpwrupreq, // Debug Power Domain up request
    input wire      cdbgpwrupack,   // Debug Power Domain up acknowledge

    output wire     csyspwrupreq, // System Power Domain up request
    input wire      csyspwrupack,   // System Power Domain up acknowledge

    output wire     cdbgrstreq,   // Debug reset request to reset controller
    input wire      cdbgrstack,     // Debug reset acknowledge to reset controller

    output wire     jtagnsw,      // jtag/not Serial Wire Mode
    output wire     jtagtop,      // jtag-DP TAP controller in one of four top states
                                        // (TLR, rti, Sel-DR, Sel-IR)

    input wire [31:0]   targetid,       // Target ID for SW multidrop selection
    input wire  [3:0]   instanceid,      // Instance ID for SW multidrop selection

    input wire [31:0] rombaseaddr,    // APB ROM Base address, tie-off

    output wire        pdbgswen        // Enable software access to Debug APB


);


wire [15:2] dapcaddr;     // DAP Address
wire        dapwrite;     // DAP Bus write
wire        dapenable;    // DAP Enable Transaction
wire        dapabort;     // DAP abort
wire        dapsel;       // DAP transaction select
wire [31:0] dapwdata;     // DAP write Data
wire [31:0] daprdata;     // DAP read Data
wire        dapready;     // DAP Data bus Ready
wire        dapslverr;    // AP slave error response

  // I/O Declaration for DAPBUS Master interface 1
wire [7:2]  dapcaddrm1;
wire        dapselm1;
wire        dapenablem1;
wire        dapwritem1;
wire [31:0] dapwdatam1;
wire        dapabortm1;
wire [31:0] daprdatam1;
wire        dapreadym1;
wire        dapslverrm1;
        
  // I/O Declaration for DAPBUS Master interface 0
wire [7:2]  dapcaddrm0;
wire        dapselm0;
wire        dapenablem0;
wire        dapwritem0;
wire [31:0] dapwdatam0;
wire        dapabortm0;
wire [31:0] daprdatam0;
wire        dapreadym0;
wire        dapslverrm0;

    // APB AP
wire         psel;           // APB select
wire         penable;        // APB enable
wire         pwrite;         // APB write or read
wire [31:2]  paddr;          // APB address bus
wire [31:0]  pwdata;         // APB write data bus
wire          pready;         // APB slave ready
wire          pslverr;        // APB slave error
wire [31:0]   prdata;         // APB read data bus



// DAP, takes JTAG/SWD and converts to debug APB
cxdapswjdp #(.IRLEN8(0)) u_dap (
    // to pads
    .swclktck(swclktck),        // SW/jtag Clock
    .swdo(swdo),                // SW Data Out
    .swdoen(swdoen),            // SW Data Out Enable
    .swditms(swditms),          // SW Debug Data In / jtag Test Mode Select
    .tdo(tdo),                  // jtag TAP Data Out
    .ntdoen(ntdoen),            // tdo enable
    .tdi(tdi),                  // jtag TAP Data In / Alternative input function
    .ntrst(ntrst),

    .dapcaddr(dapcaddr),        // DAP Address
    .dapwrite(dapwrite),        // DAP Bus write
    .dapenable(dapenable),      // DAP Enable Transaction
    .dapabort(dapabort),        // DAP abort
    .dapsel(dapsel),            // DAP transaction select
    .dapwdata(dapwdata),        // DAP write Data
    .cdbgpwrupreq(cdbgpwrupreq),// Debug Power Domain up request
    .csyspwrupreq(csyspwrupreq),// System Power Domain up request
    .cdbgrstreq(cdbgrstreq),    // Debug reset request to reset controller
    .jtagnsw(jtagnsw),          // jtag/not Serial Wire Mode
    .jtagtop(jtagtop),          // jtag-DP TAP controller in one of four top states
                                // (TLR, rti, Sel-DR, Sel-IR)

    // Inputs
    .npotrst(poresetn),         // jtag/Serial Wire Power on reset
    .dapresetn(dapresetn),      // DAP Reset
    .dapclk(clk),               // DAP Clock
    .dapclken(clken),        // DAP Clock Enable
    .daprdata(daprdata),        // DAP read Data
    .dapready(dapready),        // DAP Data bus Ready
    .dapslverr(dapslverr),      // AP slave error response
    .cdbgpwrupack(cdbgpwrupack),// Debug Power Domain up acknowledge
    .csyspwrupack(csyspwrupack),// System Power Domain up acknowledge
    .cdbgrstack(cdbgrstack),    // Debug reset acknowledge to reset controller
    .targetid(targetid),        // Target ID for SW multidrop selection
    .instanceid(instanceid)     // Instance ID for SW multidrop selection
);


cxdapbusic_1 u_dap_bus (
    // I/O Declaration for DAPBUS Master interface 1
    .dapcaddrm1(dapcaddrm1),
    .dapselm1(dapselm1),
    .dapenablem1(dapenablem1),
    .dapwritem1(dapwritem1),
    .dapwdatam1(dapwdatam1),
    .dapabortm1(dapabortm1),
    .daprdatam1(daprdatam1),
    .dapreadym1(dapreadym1),
    .dapslverrm1(dapslverrm1),

    // I/O Declaration for DAPBUS Master interface 0
    .dapcaddrm0(dapcaddrm0),
    .dapselm0(dapselm0),
    .dapenablem0(dapenablem0),
    .dapwritem0(dapwritem0),
    .dapwdatam0(dapwdatam0),
    .dapabortm0(dapabortm0),
    .daprdatam0(daprdatam0),
    .dapreadym0(dapreadym0),
    .dapslverrm0(dapslverrm0),

    // Slave interface
    .dapcaddrs(dapcaddr),
    .dapsels(dapsel),
    .dapenables(dapenable),
    .dapwrites(dapwrite),
    .dapwdatas(dapwdata),
    .dapaborts(dapabort),
    .daprdatas(daprdata),
    .dapreadys(dapready),
    .dapslverrs(dapslverr)
);


cxdapapbap u_dap_apb_ap (
    .dapclk(clk),         // DAP clock
    .dapclken(clken),       // DAP clock enable
    .dapresetn(dapresetn),      // DAP asynchrnous reset active low

    .dapsel(dapselm0),         // DAP select
    .dapenable(dapenablem0),      // DAP enable
    .dapwrite(dapwritem0),       // DAP write or read
    .dapabort(dapabortm0),       // DAP abort
    .dapcaddr(dapcaddrm0),       // DAP compressed address bus
    .dapwdata(dapwdatam0),       // DAP write data bus
    .dapready(dapreadym0),       // DAP slave ready
    .dapslverr(dapslverrm0),      // DAP slave error
    .daprdata(daprdatam0),       // DAP read data bus

    .deviceen(1'b1),       // Device enable

    .rombaseaddr(rombaseaddr),    // APB ROM Base address, tie-off

    .psel(psel),           // APB select
    .penable(penable),        // APB enable
    .pwrite(pwrite),         // APB write or read
    .paddr(paddr),          // APB address bus
    .pwdata(pwdata),         // APB write data bus
    .pready(pready),         // APB slave ready
    .pslverr(pslverr),        // APB slave error
    .prdata(prdata),         // APB read data bus

    .pdbgswen(pdbgswen)        // Enable software access to Debug APB
  );


cxapbic_1 u_dap_apb_bus (
    // Clock and reset
    .clk(clk),
    .resetn(dapresetn),
  
    // I/O Declaration for APB Slave interface 0
    .paddrs0(paddr[13:2]),
    .psels0(psel),
    .penables0(penable),
    .pwrites0(pwrite),
    .pwdatas0(pwdata),
    .prdatas0(prdata),
    .preadys0(pready),
    .pslverrs0(pslverr),
    .paddr31s0(paddr[31]),

    // I/O Declaration for APB Master interface 0
    .paddrm0(),
    .paddr31m0(),
    .pselm0(),
    .penablem0(),
    .pwritem0(),
    .pwdatam0(),
    .prdatam0(),
    .preadym0(),
    .pslverrm0(),
    
    // I/O Declaration for APB Master interface 1
    .paddrm1(),
    .paddr31m1(),
    .pselm1(),
    .penablem1(),
    .pwritem1(),
    .pwdatam1(),
    .prdatam1(),
    .preadym1(),
    .pslverrm1(),
    // targetid setting for top-level APBIC
    .targetid(targetid),

    // Authentication interface
    .dbgswen(pdbgswen)

);
endmodule
