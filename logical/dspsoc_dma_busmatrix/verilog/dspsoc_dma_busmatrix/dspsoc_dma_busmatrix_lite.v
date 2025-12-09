//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2001-2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
//  Abstract            : BusMatrixLite is a wrapper module that wraps around
//                        the BusMatrix module to give AHB Lite compliant
//                        slave and master interfaces.
//
//-----------------------------------------------------------------------------



module dspsoc_dma_busmatrix_lite (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System Address Remap control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HADDR_DMAC_0,
    HTRANS_DMAC_0,
    HWRITE_DMAC_0,
    HSIZE_DMAC_0,
    HBURST_DMAC_0,
    HPROT_DMAC_0,
    HWDATA_DMAC_0,
    HMASTLOCK_DMAC_0,

    // Output port MI0 (inputs from slave 0)
    HRDATA_M7_AHBS,
    HREADYOUT_M7_AHBS,
    HRESP_M7_AHBS,

    // Output port MI1 (inputs from slave 1)
    HRDATA_SYS_BUS,
    HREADYOUT_SYS_BUS,
    HRESP_SYS_BUS,

    // Scan test dummy signals; not connected until scan insertion
    SCANENABLE,   // Scan Test Mode Enable
    SCANINHCLK,   // Scan Chain Input


    // Output port MI0 (outputs to slave 0)
    HSEL_M7_AHBS,
    HADDR_M7_AHBS,
    HTRANS_M7_AHBS,
    HWRITE_M7_AHBS,
    HSIZE_M7_AHBS,
    HBURST_M7_AHBS,
    HPROT_M7_AHBS,
    HWDATA_M7_AHBS,
    HMASTLOCK_M7_AHBS,
    HREADYMUX_M7_AHBS,

    // Output port MI1 (outputs to slave 1)
    HSEL_SYS_BUS,
    HADDR_SYS_BUS,
    HTRANS_SYS_BUS,
    HWRITE_SYS_BUS,
    HSIZE_SYS_BUS,
    HBURST_SYS_BUS,
    HPROT_SYS_BUS,
    HWDATA_SYS_BUS,
    HMASTLOCK_SYS_BUS,
    HREADYMUX_SYS_BUS,

    // Input port SI0 (outputs to master 0)
    HRDATA_DMAC_0,
    HREADY_DMAC_0,
    HRESP_DMAC_0,

    // Scan test dummy signals; not connected until scan insertion
    SCANOUTHCLK   // Scan Chain Output

    );

// -----------------------------------------------------------------------------
// Input and Output declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    input         HCLK;            // AHB System Clock
    input         HRESETn;         // AHB System Reset

    // System Address Remap control
    input   [3:0] REMAP;           // System Address REMAP control

    // Input port SI0 (inputs from master 0)
    input  [31:0] HADDR_DMAC_0;         // Address bus
    input   [1:0] HTRANS_DMAC_0;        // Transfer type
    input         HWRITE_DMAC_0;        // Transfer direction
    input   [2:0] HSIZE_DMAC_0;         // Transfer size
    input   [2:0] HBURST_DMAC_0;        // Burst type
    input   [3:0] HPROT_DMAC_0;         // Protection control
    input  [31:0] HWDATA_DMAC_0;        // Write data
    input         HMASTLOCK_DMAC_0;     // Locked Sequence

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATA_M7_AHBS;        // Read data bus
    input         HREADYOUT_M7_AHBS;     // HREADY feedback
    input         HRESP_M7_AHBS;         // Transfer response

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATA_SYS_BUS;        // Read data bus
    input         HREADYOUT_SYS_BUS;     // HREADY feedback
    input         HRESP_SYS_BUS;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    input         SCANENABLE;      // Scan enable signal
    input         SCANINHCLK;      // HCLK scan input


    // Output port MI0 (outputs to slave 0)
    output        HSEL_M7_AHBS;          // Slave Select
    output [31:0] HADDR_M7_AHBS;         // Address bus
    output  [1:0] HTRANS_M7_AHBS;        // Transfer type
    output        HWRITE_M7_AHBS;        // Transfer direction
    output  [2:0] HSIZE_M7_AHBS;         // Transfer size
    output  [2:0] HBURST_M7_AHBS;        // Burst type
    output  [3:0] HPROT_M7_AHBS;         // Protection control
    output [31:0] HWDATA_M7_AHBS;        // Write data
    output        HMASTLOCK_M7_AHBS;     // Locked Sequence
    output        HREADYMUX_M7_AHBS;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSEL_SYS_BUS;          // Slave Select
    output [31:0] HADDR_SYS_BUS;         // Address bus
    output  [1:0] HTRANS_SYS_BUS;        // Transfer type
    output        HWRITE_SYS_BUS;        // Transfer direction
    output  [2:0] HSIZE_SYS_BUS;         // Transfer size
    output  [2:0] HBURST_SYS_BUS;        // Burst type
    output  [3:0] HPROT_SYS_BUS;         // Protection control
    output [31:0] HWDATA_SYS_BUS;        // Write data
    output        HMASTLOCK_SYS_BUS;     // Locked Sequence
    output        HREADYMUX_SYS_BUS;     // Transfer done

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATA_DMAC_0;        // Read data bus
    output        HREADY_DMAC_0;     // HREADY feedback
    output        HRESP_DMAC_0;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output

// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System Address Remap control
    wire   [3:0] REMAP;           // System REMAP signal

    // Input Port SI0
    wire  [31:0] HADDR_DMAC_0;         // Address bus
    wire   [1:0] HTRANS_DMAC_0;        // Transfer type
    wire         HWRITE_DMAC_0;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_0;         // Transfer size
    wire   [2:0] HBURST_DMAC_0;        // Burst type
    wire   [3:0] HPROT_DMAC_0;         // Protection control
    wire  [31:0] HWDATA_DMAC_0;        // Write data
    wire         HMASTLOCK_DMAC_0;     // Locked Sequence

    wire  [31:0] HRDATA_DMAC_0;        // Read data bus
    wire         HREADY_DMAC_0;     // HREADY feedback
    wire         HRESP_DMAC_0;         // Transfer response

    // Output Port MI0
    wire         HSEL_M7_AHBS;          // Slave Select
    wire  [31:0] HADDR_M7_AHBS;         // Address bus
    wire   [1:0] HTRANS_M7_AHBS;        // Transfer type
    wire         HWRITE_M7_AHBS;        // Transfer direction
    wire   [2:0] HSIZE_M7_AHBS;         // Transfer size
    wire   [2:0] HBURST_M7_AHBS;        // Burst type
    wire   [3:0] HPROT_M7_AHBS;         // Protection control
    wire  [31:0] HWDATA_M7_AHBS;        // Write data
    wire         HMASTLOCK_M7_AHBS;     // Locked Sequence
    wire         HREADYMUX_M7_AHBS;     // Transfer done

    wire  [31:0] HRDATA_M7_AHBS;        // Read data bus
    wire         HREADYOUT_M7_AHBS;     // HREADY feedback
    wire         HRESP_M7_AHBS;         // Transfer response

    // Output Port MI1
    wire         HSEL_SYS_BUS;          // Slave Select
    wire  [31:0] HADDR_SYS_BUS;         // Address bus
    wire   [1:0] HTRANS_SYS_BUS;        // Transfer type
    wire         HWRITE_SYS_BUS;        // Transfer direction
    wire   [2:0] HSIZE_SYS_BUS;         // Transfer size
    wire   [2:0] HBURST_SYS_BUS;        // Burst type
    wire   [3:0] HPROT_SYS_BUS;         // Protection control
    wire  [31:0] HWDATA_SYS_BUS;        // Write data
    wire         HMASTLOCK_SYS_BUS;     // Locked Sequence
    wire         HREADYMUX_SYS_BUS;     // Transfer done

    wire  [31:0] HRDATA_SYS_BUS;        // Read data bus
    wire         HREADYOUT_SYS_BUS;     // HREADY feedback
    wire         HRESP_SYS_BUS;         // Transfer response


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------
    wire   [3:0] tie_hi_4;
    wire         tie_hi;
    wire         tie_low;
    wire   [1:0] i_hresp_DMAC_0;

    wire   [3:0]        i_hmaster_M7_AHBS;
    wire   [1:0] i_hresp_M7_AHBS;
    wire   [3:0]        i_hmaster_SYS_BUS;
    wire   [1:0] i_hresp_SYS_BUS;

// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

    assign tie_hi   = 1'b1;
    assign tie_hi_4 = 4'b1111;
    assign tie_low  = 1'b0;


    assign HRESP_DMAC_0  = i_hresp_DMAC_0[0];

    assign i_hresp_M7_AHBS = {{1{tie_low}}, HRESP_M7_AHBS};
    assign i_hresp_SYS_BUS = {{1{tie_low}}, HRESP_SYS_BUS};

// BusMatrix instance
  dspsoc_dma_busmatrix udspsoc_dma_busmatrix (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .REMAP      (REMAP),

    // Input port SI0 signals
    .HSEL_DMAC_0       (tie_hi),
    .HADDR_DMAC_0      (HADDR_DMAC_0),
    .HTRANS_DMAC_0     (HTRANS_DMAC_0),
    .HWRITE_DMAC_0     (HWRITE_DMAC_0),
    .HSIZE_DMAC_0      (HSIZE_DMAC_0),
    .HBURST_DMAC_0     (HBURST_DMAC_0),
    .HPROT_DMAC_0      (HPROT_DMAC_0),
    .HWDATA_DMAC_0     (HWDATA_DMAC_0),
    .HMASTLOCK_DMAC_0  (HMASTLOCK_DMAC_0),
    .HMASTER_DMAC_0    (tie_hi_4),
    .HREADY_DMAC_0     (HREADY_DMAC_0),
    .HRDATA_DMAC_0     (HRDATA_DMAC_0),
    .HREADYOUT_DMAC_0  (HREADY_DMAC_0),
    .HRESP_DMAC_0      (i_hresp_DMAC_0),


    // Output port MI0 signals
    .HSEL_M7_AHBS       (HSEL_M7_AHBS),
    .HADDR_M7_AHBS      (HADDR_M7_AHBS),
    .HTRANS_M7_AHBS     (HTRANS_M7_AHBS),
    .HWRITE_M7_AHBS     (HWRITE_M7_AHBS),
    .HSIZE_M7_AHBS      (HSIZE_M7_AHBS),
    .HBURST_M7_AHBS     (HBURST_M7_AHBS),
    .HPROT_M7_AHBS      (HPROT_M7_AHBS),
    .HWDATA_M7_AHBS     (HWDATA_M7_AHBS),
    .HMASTER_M7_AHBS    (i_hmaster_M7_AHBS),
    .HMASTLOCK_M7_AHBS  (HMASTLOCK_M7_AHBS),
    .HREADYMUX_M7_AHBS  (HREADYMUX_M7_AHBS),
    .HRDATA_M7_AHBS     (HRDATA_M7_AHBS),
    .HREADYOUT_M7_AHBS  (HREADYOUT_M7_AHBS),
    .HRESP_M7_AHBS      (i_hresp_M7_AHBS),

    // Output port MI1 signals
    .HSEL_SYS_BUS       (HSEL_SYS_BUS),
    .HADDR_SYS_BUS      (HADDR_SYS_BUS),
    .HTRANS_SYS_BUS     (HTRANS_SYS_BUS),
    .HWRITE_SYS_BUS     (HWRITE_SYS_BUS),
    .HSIZE_SYS_BUS      (HSIZE_SYS_BUS),
    .HBURST_SYS_BUS     (HBURST_SYS_BUS),
    .HPROT_SYS_BUS      (HPROT_SYS_BUS),
    .HWDATA_SYS_BUS     (HWDATA_SYS_BUS),
    .HMASTER_SYS_BUS    (i_hmaster_SYS_BUS),
    .HMASTLOCK_SYS_BUS  (HMASTLOCK_SYS_BUS),
    .HREADYMUX_SYS_BUS  (HREADYMUX_SYS_BUS),
    .HRDATA_SYS_BUS     (HRDATA_SYS_BUS),
    .HREADYOUT_SYS_BUS  (HREADYOUT_SYS_BUS),
    .HRESP_SYS_BUS      (i_hresp_SYS_BUS),


    // Scan test dummy signals; not connected until scan insertion
    .SCANENABLE            (SCANENABLE),
    .SCANINHCLK            (SCANINHCLK),
    .SCANOUTHCLK           (SCANOUTHCLK)
  );


endmodule
