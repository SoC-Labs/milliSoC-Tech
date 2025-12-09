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
//  Abstract            : BusMatrix is the top-level which connects together
//                        the required Input Stages, MatrixDecodes, Output
//                        Stages and Output Arbitration blocks.
//
//                        Supports the following configured options:
//
//                         - Architecture type 'ahb2',
//                         - 1 slave ports (connecting to masters),
//                         - 2 master ports (connecting to slaves),
//                         - Routing address width of 32 bits,
//                         - Routing data width of 32 bits,
//                         - Arbiter type 'burst',
//                         - Connectivity mapping:
//                             S<0..0> -> M<0..1>,
//                         - Connectivity type 'full'.
//
//------------------------------------------------------------------------------



module dspsoc_dma_busmatrix (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System address remapping control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HSEL_DMAC_0,
    HADDR_DMAC_0,
    HTRANS_DMAC_0,
    HWRITE_DMAC_0,
    HSIZE_DMAC_0,
    HBURST_DMAC_0,
    HPROT_DMAC_0,
    HMASTER_DMAC_0,
    HWDATA_DMAC_0,
    HMASTLOCK_DMAC_0,
    HREADY_DMAC_0,

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
    HMASTER_M7_AHBS,
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
    HMASTER_SYS_BUS,
    HWDATA_SYS_BUS,
    HMASTLOCK_SYS_BUS,
    HREADYMUX_SYS_BUS,

    // Input port SI0 (outputs to master 0)
    HRDATA_DMAC_0,
    HREADYOUT_DMAC_0,
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

    // System address remapping control
    input   [3:0] REMAP;           // REMAP input

    // Input port SI0 (inputs from master 0)
    input         HSEL_DMAC_0;          // Slave Select
    input  [31:0] HADDR_DMAC_0;         // Address bus
    input   [1:0] HTRANS_DMAC_0;        // Transfer type
    input         HWRITE_DMAC_0;        // Transfer direction
    input   [2:0] HSIZE_DMAC_0;         // Transfer size
    input   [2:0] HBURST_DMAC_0;        // Burst type
    input   [3:0] HPROT_DMAC_0;         // Protection control
    input   [3:0] HMASTER_DMAC_0;       // Master select
    input  [31:0] HWDATA_DMAC_0;        // Write data
    input         HMASTLOCK_DMAC_0;     // Locked Sequence
    input         HREADY_DMAC_0;        // Transfer done

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATA_M7_AHBS;        // Read data bus
    input         HREADYOUT_M7_AHBS;     // HREADY feedback
    input   [1:0] HRESP_M7_AHBS;         // Transfer response

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATA_SYS_BUS;        // Read data bus
    input         HREADYOUT_SYS_BUS;     // HREADY feedback
    input   [1:0] HRESP_SYS_BUS;         // Transfer response

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
    output  [3:0] HMASTER_M7_AHBS;       // Master select
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
    output  [3:0] HMASTER_SYS_BUS;       // Master select
    output [31:0] HWDATA_SYS_BUS;        // Write data
    output        HMASTLOCK_SYS_BUS;     // Locked Sequence
    output        HREADYMUX_SYS_BUS;     // Transfer done

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATA_DMAC_0;        // Read data bus
    output        HREADYOUT_DMAC_0;     // HREADY feedback
    output  [1:0] HRESP_DMAC_0;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output


// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System address remapping control
    wire   [3:0] REMAP;           // REMAP signal

    // Input Port SI0
    wire         HSEL_DMAC_0;          // Slave Select
    wire  [31:0] HADDR_DMAC_0;         // Address bus
    wire   [1:0] HTRANS_DMAC_0;        // Transfer type
    wire         HWRITE_DMAC_0;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_0;         // Transfer size
    wire   [2:0] HBURST_DMAC_0;        // Burst type
    wire   [3:0] HPROT_DMAC_0;         // Protection control
    wire   [3:0] HMASTER_DMAC_0;       // Master select
    wire  [31:0] HWDATA_DMAC_0;        // Write data
    wire         HMASTLOCK_DMAC_0;     // Locked Sequence
    wire         HREADY_DMAC_0;        // Transfer done

    wire  [31:0] HRDATA_DMAC_0;        // Read data bus
    wire         HREADYOUT_DMAC_0;     // HREADY feedback
    wire   [1:0] HRESP_DMAC_0;         // Transfer response

    // Output Port MI0
    wire         HSEL_M7_AHBS;          // Slave Select
    wire  [31:0] HADDR_M7_AHBS;         // Address bus
    wire   [1:0] HTRANS_M7_AHBS;        // Transfer type
    wire         HWRITE_M7_AHBS;        // Transfer direction
    wire   [2:0] HSIZE_M7_AHBS;         // Transfer size
    wire   [2:0] HBURST_M7_AHBS;        // Burst type
    wire   [3:0] HPROT_M7_AHBS;         // Protection control
    wire   [3:0] HMASTER_M7_AHBS;       // Master select
    wire  [31:0] HWDATA_M7_AHBS;        // Write data
    wire         HMASTLOCK_M7_AHBS;     // Locked Sequence
    wire         HREADYMUX_M7_AHBS;     // Transfer done

    wire  [31:0] HRDATA_M7_AHBS;        // Read data bus
    wire         HREADYOUT_M7_AHBS;     // HREADY feedback
    wire   [1:0] HRESP_M7_AHBS;         // Transfer response

    // Output Port MI1
    wire         HSEL_SYS_BUS;          // Slave Select
    wire  [31:0] HADDR_SYS_BUS;         // Address bus
    wire   [1:0] HTRANS_SYS_BUS;        // Transfer type
    wire         HWRITE_SYS_BUS;        // Transfer direction
    wire   [2:0] HSIZE_SYS_BUS;         // Transfer size
    wire   [2:0] HBURST_SYS_BUS;        // Burst type
    wire   [3:0] HPROT_SYS_BUS;         // Protection control
    wire   [3:0] HMASTER_SYS_BUS;       // Master select
    wire  [31:0] HWDATA_SYS_BUS;        // Write data
    wire         HMASTLOCK_SYS_BUS;     // Locked Sequence
    wire         HREADYMUX_SYS_BUS;     // Transfer done

    wire  [31:0] HRDATA_SYS_BUS;        // Read data bus
    wire         HREADYOUT_SYS_BUS;     // HREADY feedback
    wire   [1:0] HRESP_SYS_BUS;         // Transfer response


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------

    // Bus-switch input SI0
    wire         i_sel0;            // HSEL signal
    wire  [31:0] i_addr0;           // HADDR signal
    wire   [1:0] i_trans0;          // HTRANS signal
    wire         i_write0;          // HWRITE signal
    wire   [2:0] i_size0;           // HSIZE signal
    wire   [2:0] i_burst0;          // HBURST signal
    wire   [3:0] i_prot0;           // HPROTS signal
    wire   [3:0] i_master0;         // HMASTER signal
    wire         i_mastlock0;       // HMASTLOCK signal
    wire         i_active0;         // Active signal
    wire         i_held_tran0;       // HeldTran signal
    wire         i_readyout0;       // Readyout signal
    wire   [1:0] i_resp0;           // Response signal

    // Bus-switch SI0 to MI0 signals
    wire         i_sel0to0;         // Routing selection signal
    wire         i_active0to0;      // Active signal

    // Bus-switch SI0 to MI1 signals
    wire         i_sel0to1;         // Routing selection signal
    wire         i_active0to1;      // Active signal

    wire         i_hready_mux__m7_ahbs;    // Internal HREADYMUXM for MI0
    wire         i_hready_mux__sys_bus;    // Internal HREADYMUXM for MI1


// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

  // Input stage for SI0
  dspsoc_dma_inititator_input u_dspsoc_dma_inititator_input_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSEL_DMAC_0),
    .HADDRS     (HADDR_DMAC_0),
    .HTRANSS    (HTRANS_DMAC_0),
    .HWRITES    (HWRITE_DMAC_0),
    .HSIZES     (HSIZE_DMAC_0),
    .HBURSTS    (HBURST_DMAC_0),
    .HPROTS     (HPROT_DMAC_0),
    .HMASTERS   (HMASTER_DMAC_0),
    .HMASTLOCKS (HMASTLOCK_DMAC_0),
    .HREADYS    (HREADY_DMAC_0),

    // Internal Response
    .active_ip     (i_active0),
    .readyout_ip   (i_readyout0),
    .resp_ip       (i_resp0),

    // Input Port Response
    .HREADYOUTS (HREADYOUT_DMAC_0),
    .HRESPS     (HRESP_DMAC_0),

    // Internal Address/Control Signals
    .sel_ip        (i_sel0),
    .addr_ip       (i_addr0),
    .trans_ip      (i_trans0),
    .write_ip      (i_write0),
    .size_ip       (i_size0),
    .burst_ip      (i_burst0),
    .prot_ip       (i_prot0),
    .master_ip     (i_master0),
    .mastlock_ip   (i_mastlock0),
    .held_tran_ip   (i_held_tran0)

    );


  // Matrix decoder for SI0
  dspsoc_dma_matrix_decode_DMAC_0 u_dspsoc_dma_matrix_decode_dmac_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Signals from Input stage SI0
    .HREADYS    (HREADY_DMAC_0),
    .sel_dec        (i_sel0),
    .decode_addr_dec (i_addr0[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans0),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active0to0),
    .readyout_dec0  (i_hready_mux__m7_ahbs),
    .resp_dec0      (HRESP_M7_AHBS),
    .rdata_dec0     (HRDATA_M7_AHBS),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active0to1),
    .readyout_dec1  (i_hready_mux__sys_bus),
    .resp_dec1      (HRESP_SYS_BUS),
    .rdata_dec1     (HRDATA_SYS_BUS),

    .sel_dec0       (i_sel0to0),
    .sel_dec1       (i_sel0to1),

    .active_dec     (i_active0),
    .HREADYOUTS (i_readyout0),
    .HRESPS     (i_resp0),
    .HRDATAS    (HRDATA_DMAC_0)

    );


  // Output stage for MI0
  dspsoc_dma_target_output u_dspsoc_dma_target_output_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to0),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DMAC_0),
    .held_tran_op0  (i_held_tran0),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_M7_AHBS),

    .active_op0    (i_active0to0),

    // Slave Address/Control Signals
    .HSELM      (HSEL_M7_AHBS),
    .HADDRM     (HADDR_M7_AHBS),
    .HTRANSM    (HTRANS_M7_AHBS),
    .HWRITEM    (HWRITE_M7_AHBS),
    .HSIZEM     (HSIZE_M7_AHBS),
    .HBURSTM    (HBURST_M7_AHBS),
    .HPROTM     (HPROT_M7_AHBS),
    .HMASTERM   (HMASTER_M7_AHBS),
    .HMASTLOCKM (HMASTLOCK_M7_AHBS),
    .HREADYMUXM (i_hready_mux__m7_ahbs),
    .HWDATAM    (HWDATA_M7_AHBS)

    );

  // Drive output with internal version
  assign HREADYMUX_M7_AHBS = i_hready_mux__m7_ahbs;


  // Output stage for MI1
  dspsoc_dma_target_output u_dspsoc_dma_target_output_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to1),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DMAC_0),
    .held_tran_op0  (i_held_tran0),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_SYS_BUS),

    .active_op0    (i_active0to1),

    // Slave Address/Control Signals
    .HSELM      (HSEL_SYS_BUS),
    .HADDRM     (HADDR_SYS_BUS),
    .HTRANSM    (HTRANS_SYS_BUS),
    .HWRITEM    (HWRITE_SYS_BUS),
    .HSIZEM     (HSIZE_SYS_BUS),
    .HBURSTM    (HBURST_SYS_BUS),
    .HPROTM     (HPROT_SYS_BUS),
    .HMASTERM   (HMASTER_SYS_BUS),
    .HMASTLOCKM (HMASTLOCK_SYS_BUS),
    .HREADYMUXM (i_hready_mux__sys_bus),
    .HWDATAM    (HWDATA_SYS_BUS)

    );

  // Drive output with internal version
  assign HREADYMUX_SYS_BUS = i_hready_mux__sys_bus;


endmodule

// --================================= End ===================================--
