//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2012 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2010-08-23 13:11:28 +0100 (Mon, 23 Aug 2010) $
//
//      Revision            : $Revision: 146458 $
//
//      Release Information : Cortex-R5-AT570-r1p3-00rel0
//
//------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: Top-level parameter list to create modifiable defaults
// ----------------------------------------------------------------------------

  // ----------------------------------------------------------------------
  // CORTEXR5 SHARED PARAMETERS
  // ----------------------------------------------------------------------
  //`define USE_DW                // Instantiate DesignWare components
  // ----------------------------------------------------------------------
  parameter NUM_CPU   =  1;       // Number of CPUs (1 or 2)
  // ----------------------------------------------------------------------
  parameter LOCK_STEP =  0;       // Controls Lock-step configurations
                                  //  0 - no redundant logic
                                  //  1 - CPU0 with redundancy
                                  //  3 - split/lock configuration
  // ----------------------------------------------------------------------
  parameter ICACHE_ERR = 0;       // I-Cache Error Handling:
                                  //  0 - None
                                  //  1 - Parity
                                  //  2 - ECC
  // ----------------------------------------------------------------------
  parameter DCACHE_ERR = 0;       // D-Cache Error Handling:
                                  //  0 - None
                                  //  1 - Parity
                                  //  2 - ECC
  // ----------------------------------------------------------------------
  parameter ATCM_ERR = 0;         // ATCM Error Handling:
                                  //  0 - none
                                  //  1 - ECC-32
                                  //  2 - ECC-64
  // ----------------------------------------------------------------------
  parameter BTCM_ERR = 0;         // BTCM Error Handling:
                                  //  0 - none
                                  //  1 - ECC-32
                                  //  2 - ECC-64
  // ----------------------------------------------------------------------
  parameter INST_ENDIAN = 1;      // Instruction Endianness
                                  //  0 - little-endian only
                                  //  1 - selectable endianess (CFGIE)
  // ----------------------------------------------------------------------
  parameter BREAK_POINTS = 3;     // Number of Breakpoints
                                  // Valid Range [2 - 8]
  // ----------------------------------------------------------------------
  parameter WATCH_POINTS = 2;     // Number of Watchpoints
                                  // Valid Range [1 - 8]
  // ----------------------------------------------------------------------
  parameter A_TCM_PORT = 1;       // ATCM Port Inclusion
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter B0_TCM_PORT = 1;      // B0TCM Port Inclusion
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter B1_TCM_PORT = 1;      // B1TCM Port Inclusion
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter TCM_BUS_PARITY = 0;   // TCM Address/Control Bus Parity
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter AXI_BUS_ECC = 0;      // Bus ECC Functionality on AXI-M, AXI-S,
                                  // ACP-M and ACP-S AXI ports
                                  //  0 - Bus ECC Disabled (all ECC and
                                  //      parity outputs tied to 0)
                                  //  1 - Bus ECC Enabled
  // ----------------------------------------------------------------------
  parameter PP_BUS_ECC = 0;       // Bus ECC Functionality on LLPP ports
                                  //  0 - Bus ECC Disabled (all ECC and
                                  //      parity outputs tied low)
                                  //  1 - Bus ECC Enabled
  // ----------------------------------------------------------------------
  parameter PERPH_REV_AND = 4'h0; // Value of RevAnd field
  // ----------------------------------------------------------------------
  parameter HARD_ERR_CACHE = 0;   // TCM Hard Error Cache Inclusion
                                  // (only if TCM has ECC)
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter AHB_PP = 0;           // AHB Peripheral Port Inclusion
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter MICRO_SCU = 0;        // MicroSCU Inclusion
                                  // Enables ACP functionality
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  // CORTEXR5 CPU0 PARAMETERS
  // ----------------------------------------------------------------------
  parameter I_CACHE0 = 1;         // Infer I-Cache Controller for CPU0
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter D_CACHE0 = 1;         // Infer D-Cache Controller for CPU0
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter FPU0 = 0;             // Floating Point logic inclusion on CPU0
                                  //  0 - excluded
                                  //  1 - included
                                  // Requires floating-point unit code,
                                  // which is part of the separately
                                  // licensed deliverable, AT575-MN-22110
  // ----------------------------------------------------------------------
  parameter DP_FLOAT0 = 0;        // Double Precision Floating Point logic
                                  // inclusion on CPU0 (only valid when
                                  // FPU0 is 1)
                                  //  0 - excluded
                                  //  1 - included
                                  // Requires floating-point unit code,
                                  // which is part of the separately
                                  // licensed deliverable, AT575-MN-22110
  // ----------------------------------------------------------------------
  parameter MPU_REGIONS0 = 12;    // Number of MPU Regions on CPU0
                                  // Valid values in {0, 12, 16}
  // ----------------------------------------------------------------------
  parameter TCM_HI_INIT_ADDR0 = 20'h40000;// Initial address of "other" TCM
                                          // interface on CPU0 (high bits)
                                          // Must be TCM-size aligned
  // ----------------------------------------------------------------------
  parameter AXI_SLAVE0 = 1;       // AXI Slave inclusion on CPU0
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  // CORTEXR5 CPU1 PARAMETERS
  // ----------------------------------------------------------------------
  parameter I_CACHE1 = 0;         // Infer I-Cache Controller for CPU1
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter D_CACHE1 = 0;         // Infer D-Cache Controller for CPU1
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------
  parameter FPU1 = 0;             // Floating Point logic inclusion on CPU1
                                  // Requires floating-point unit code,
                                  // which is part of the separately
                                  // licensed deliverable, AT575-MN-22110
  // ----------------------------------------------------------------------
  parameter DP_FLOAT1 = 0;        // Double Precision Floating Point logic
                                  // inclusion on CPU1 (only valid when
                                  // FPU1 is 1)
                                  //  0 - excluded
                                  //  1 - included
                                  // Requires floating-point unit code,
                                  // which is part of the separately
                                  // licensed deliverable, AT575-MN-22110
  // ----------------------------------------------------------------------
  parameter MPU_REGIONS1 = 12;    // Number of MPU Regions on CPU1
                                  // Valid values in {0, 12, 16}
  // ----------------------------------------------------------------------
  parameter TCM_HI_INIT_ADDR1 = 20'h40000;// Initial address of "other" TCM
                                          // interface on CPU1 (high bits)
                                          // Must be TCM-size aligned
  // ----------------------------------------------------------------------
  parameter AXI_SLAVE1 = 1;       // AXI Slave inclusion on CPU1
                                  //  0 - excluded
                                  //  1 - included
  // ----------------------------------------------------------------------

