//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
// Release Information : Cortex-M55-r1p1-00rel0
//------------------------------------------------------------------------------
// SystemVerilog (IEEE Std 1800-2012)
//------------------------------------------------------------------------------
parameter MCUROMADDR     = 32'hE00FE000,
                                          // Base address of the MCU level CoreSight ROM Table
                                          // Notes:
                                          // - The base address must be aligned to a 4KB
                                          //   address region i.e. MCUROMADDR[11:0] = 0
                                          // - The address must be in the EPPB address
                                          //   region of the memory map
// ------------------------------------------------------------------------
parameter EWIC           = 0,             // Specifies whether the MCU level includes the
                                          // External Wakeup Interupt Controller
                                          // 0: E-WIC not included
                                          // 1: E-WIC included
// ------------------------------------------------------------------------
parameter ETB            = 0,             // Specifies whether the MCU level is configured
                                          // with the CoreSight Embedded Trace Buffer, ETB
                                          // Note: The CoreSight ETB is a separate licensable
                                          // product from Arm
                                          // 0: ETB not included
                                          // 1: ETB included

// ------------------------------------------------------------------------
// The following parameters are for the DAP
// ------------------------------------------------------------------------
parameter DPSEL          = 0,             // Specifies debug port select capability
                                          // 0 - JTAG only selected (JTAG-DP)
                                          // 1 - Serial Wire only selected (SW-DP)
                                          // 2 - Dynamic switching selected (SWJ-DP)

// ------------------------------------------------------------------------
// The following parameters are for the main ROM table
// ------------------------------------------------------------------------
parameter JEPID          = 7'h00,         // JEP106 identification code for SoC design
                                          // Reflected in MCU ROM table PIDR1 and PRDR2
// ------------------------------------------------------------------------
parameter JEPCONT        = 4'h0,          // JEP106 continuation code for SoC design
                                          // Reflected in MCU ROM table PIDR4
// ------------------------------------------------------------------------
parameter PARTNO         = 12'h000,       // Part number for SoC design
                                          // Reflected in MCU ROM table PIDR0 and PIDR1
// ------------------------------------------------------------------------
parameter MCU_ECOREVNUM  = 20'h00000,     // ECOREVNUM for MCU CoreSight Components (ROM Table,
                                          // DAP, TPIU and ETB) and EWIC module.
                                          // The assigned values are reflected in PIDR3.REVAND
                                          // field of the corresponding block
                                          // 19:16 = yamin_mcurom
                                          // 15:12 = yamin_dap
                                          // 11:8  = yamin_tpiu/tpium
                                          //  7:4  = css600_tmc_etb
                                          //  3:0  = yamin_ewic

// ------------------------------------------------------------------------
// The following parameters for SBIST
// ------------------------------------------------------------------------
parameter SBISTC          = 0,            // Specifies whether the MCU level includes
                                          // SBIST Controller
// ------------------------------------------------------------------------
parameter SBIST_DL_CYCLES = 16'hA0,       // Specifies the reset value SBIST deadlock counter
                                          // Time out clock cycles = SBIST_DL_CYCLES * 32
// ------------------------------------------------------------------------
parameter SBIST_DL_RESET  = 0,            // Sets FCTLT register at reset in SBIST controller
                                          // 0 disables the deadlock counter

// ------------------------------------------------------------------------
// The following parameters are for the TPIU
// ------------------------------------------------------------------------
parameter TPIUM             = 0,          // Specifies which Trace Port Interface Unit (TPIU)
                                          // the MCU level is configured with:
                                          // 0: Selects TPIU
                                          //    Configurable as 1, 2 or 4-bit parallel
                                          // 1: Selects TPIUM
                                          //    Configurable as 1, 2, 4, 8, 12 or 16-bit parallel
// ------------------------------------------------------------------------
parameter FF_SYNC_DEPTH     = 2,          // TPIUM Synchronizer Depth
                                          // This parameter sets the number of flip-flop
                                          // stages in the synchronizers:
                                          // 2: 2-stage synchronizer
                                          // 3: 3-stage synchronizer
                                          // Legal values are 2, 3
// --------------------------------------------------------------------------------------
parameter TRACEPORT_DATA_WIDTH = 16       // Configures the width of the TPIUM tracedata
                                          // output port. Along with the configuration
                                          // tieoff tp_maxdatasize it defines the maximum
                                          // allowed width of tracedata port and defines
                                          // also TPIU_SSPSR.
                                          // Legal values are 4,8,12,16

