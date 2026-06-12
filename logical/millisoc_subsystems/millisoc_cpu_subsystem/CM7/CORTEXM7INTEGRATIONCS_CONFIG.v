//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//  Version and Release Control Information:
//
//  File Revision       : $Revision: 313889 $
//  File Date           : $Date: 2015-07-14 18:54:18 +0100 (Tue, 14 Jul 2015) $
//
//  Release Information : CORTEX-M7-r1p2-00rel0
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------
// Purpose : Configuration for CORTEXM7INTEGRATIONCS - user modifiable
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Floating point unit (FPU) configuration
//------------------------------------------------------------------------------
// 0 = No FPU hardware
// 1 = Single-precision FPU
// 2 = Single and double precision FPU
parameter FPU = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// I-cache configuration
//------------------------------------------------------------------------------
// 0 = No I-cache implemented
// 1 = I-cache implemented
// Note that the I-cache size, if implemented, is controlled separately
parameter ICACHE = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// D-cache configuration
//------------------------------------------------------------------------------
// 0 = No D-cache implemented
// 1 = D-cache implemented
// Note that the D-cache size, if implemented, is controlled separately
parameter DCACHE = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Cache ECC configuration
//------------------------------------------------------------------------------
// 0 = No cache ECC implemented
// 1 = Cache ECC implemented
// Note that this applies to both I and D-caches (if implemented)
parameter CACHEECC = 0,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// MPU region configuration
//------------------------------------------------------------------------------
// 0  = No MPU. Default memory map applies
// 8  = 8 region MPU
// 16 = 16 region MPU
parameter MPU = 8,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Number of IRQs
//------------------------------------------------------------------------------
// n = number of IRQs implemented
// n can be between 1 and 240 (inclusive)
// The lower n bits of the IRQ[239:0] bus are implemented
// Note that this parameter does not affect NMI (which is always implemented)
parameter IRQNUM = 240,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// IRQ priority width configuration
//------------------------------------------------------------------------------
// m = number of bits of IRQLVL implemented
// m can be between 3 and 8 (inclusive)
parameter IRQLVL = 3,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Debug (breakpoint/watchpoint) configuration
//------------------------------------------------------------------------------
// Controls the number of FPB and DWT comaprators implemented
// 0 = Reduced comparator set: 2 DWT and 4 FPB comparators
// 1 = Full comparator set: 4 DWT and 8 FPB comparators
// Note that this parameter does not affect baseline debug halt and monitor mode
// functionality which is always present
parameter DBGLVL = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Internal Trace support
//------------------------------------------------------------------------------
// 0 = No ITM or DWT trace functionality implemented
// 1 = ITM and DWT trace functionality implemented
// Note that this parameter does not affect the number of DWT comparators
parameter TRC = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// ETM support
//------------------------------------------------------------------------------
// 0 = No ETM interface
// 1 = Instruction-only ETM interface
// 2 = Instruction and data ETM interface
parameter ETM = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// CTI support
//------------------------------------------------------------------------------
// Cross Trigger Interface option:
// 0 = absent
// 1 = present
parameter CTI = 0,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// WIC support
//------------------------------------------------------------------------------
// Controls whether the WIC is supported or not
parameter WIC = 1,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Number of WIC lines
//------------------------------------------------------------------------------
// NMI, RXEV, DbgMon + number of IRQ lines supported by WIC
// Defaults to number of IRQs + 3
parameter WICLINES = IRQNUM + 3,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Dual-redundant (lock-step) CPU functionality
//------------------------------------------------------------------------------
// 0 = No dual-redundant CPU
// 1 = Dual-redundant CPU
parameter LOCKSTEP = 0,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Reset-all-registers
//------------------------------------------------------------------------------
// 0 = Standard configuration - not all DFFs are asynchronously reset
// 1 = All CORTEXM7 DFFs asynchronously reset
// 2 = All CORTEXM7 and CSETMM7 DFFs asynchronously reset
parameter RAR = 0,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Use Synopsys DesignWare
//------------------------------------------------------------------------------
// 0 = No Synopsys DesignWare components instantiated
// 1 = Synopsys DesignWare components instantiated
// Setting this option to 1 may give better PPA when implementing with the
// Synopsys tool-chain.
// Note that this option is ONLY supported for the Synopsys tool-chain. For
// all other flows you MUST set this to 0
parameter DW = 0,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// NOTE:
// The I-cache and D-cache size parameters are only used for DSM simulation
// These parameters are not used for RTL simulation
// When generating a DSM these parameter values must match the sizes of the cache 
// memories and the values of the ram_icu_cache_size and ram_dcu_cache_size 
// signals in the cm7top_cache_rams.v file..
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// I-cache Size in k Bytes
//------------------------------------------------------------------------------
// 0  = 0 kB
// 4  = 4 kB
// 8  = 8 kB
// 16 = 16 kB
// 32 = 32 kB
// 64 = 64 kB
parameter ICACHESIZE = 16,
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// D-cache Size in k Bytes
//------------------------------------------------------------------------------
// 0  = 0 kB
// 4  = 4 kB
// 8  = 8 kB
// 16 = 16 kB
// 32 = 32 kB
// 64 = 64 kB
parameter DCACHESIZE = 16
//------------------------------------------------------------------------------

