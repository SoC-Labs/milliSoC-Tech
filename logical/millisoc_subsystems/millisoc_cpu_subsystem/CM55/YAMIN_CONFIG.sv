//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2012-2021 Arm Limited or its affiliates.
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

//------------------------------------------------------------------------------
// Purpose : Configuration for YAMIN - user modifiable
//------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Verilog    | Default | Legal  | Configure by   | Description
// Parameter  | value   | values | wire tie-off   |
// --------------------------------------------------------------------------------------
// ICACHESZ    5'b01111 5'b00000,   No             Specifies whether the instruction cache
//                      5'b00001,                  controller is included in the processor,
//                      5'b00011,                  and, if included the size of the cache
//                      5'b00111,                  5'b00000:  No instruction cache
//                      5'b01111,                  5'b00001:  4KB instruction cache
//                      5'b11111                   5'b00011:  8KB instruction cache
//                                                 5'b00111:  16KB instruction cache
//                                                 5'b01111:  32KB instruction cache
//                                                 5'b11111:  64KB instruction cache
//                                                 Note: Setting ICACHESZ to any other value
//                                                 will result in UNPREDICTABLE behaviour
// --------------------------------------------------------------------------------------
// DCACHESZ    5'b01111 5'b00000,   No             Specifies whether the data cache
//                      5'b00001,                  controller is included in the processor,
//                      5'b00011,                  and, if included the size of the cache
//                      5'b00111,                  5'b00000:  No data cache
//                      5'b01111,                  5'b00001:  4KB data cache
//                      5'b11111                   5'b00011:  8KB data cache
//                                                 5'b00111:  16KB data cache
//                                                 5'b01111:  32KB data cache
//                                                 5'b11111:  64KB data cache
//                                                 Note: Setting DCACHESZ to any other value
//                                                 will result in UNPREDICTABLE behaviour
// --------------------------------------------------------------------------------------
// IDCACHEID    0        0..255     No             Instruction and Data cache ID Unique
//                                                 identifier for instruction and data cache
//                                                 RAM implementation.
//                                                 This parameter allows multiple instances
//                                                 of the Yamin processor to use different
//                                                 library cells for the embedded cache RAM
// --------------------------------------------------------------------------------------
// ECC          0        0,1        No             Specifies whether the cache and TCM ECC
//                                                 hardware is included
//                                                 0: No ECC logic
//                                                 1: ECC logic included
// --------------------------------------------------------------------------------------
// FPU          1        0,1        Yes            Specifies whether floating point
//                                  CFGFPU         hardware is included
//                                                 0: No FPU
//                                                 1: Include double precision FPU
// --------------------------------------------------------------------------------------
// MVE          1        0,1,2      Yes            Specifies whether the M-class vector
//                                  CFGMVE         extension is included
//                                                 0: MVE Extension not included
//                                                 1: Integer MVE
//                                                 2: Integer & FP MVE (requires FPU==1)
// --------------------------------------------------------------------------------------
// SECEXT       1        0,1        No             Specifies whether the ARMv8-M Security
//                                                 Extensions are included
//                                                 0: Security Extensions not included
//                                                 1: Security Extensions included
// --------------------------------------------------------------------------------------
// CPIF         1        0,1        Yes            Specifies whether the Coprocessor
//                                  CPENABLED      interface is included
//                                                 0: Coprocessor interface not included
//                                                 1: Coprocessor interface included
// --------------------------------------------------------------------------------------
// MPU_NS       8        0,4,8,     Partially      Specifies the number of non-secure MPU
//                       12,16      MPUSDISABLE    regions included
//                                                 0:  No MPU regions
//                                                 4:  4 MPU regions
//                                                 8:  8 MPU regions
//                                                 12: 12 MPU regions
//                                                 16: 16 MPU regions
//                                                 NB. If SECEXT is set to 0 this is the
//                                                 total number of MPU regions included
// --------------------------------------------------------------------------------------
// MPU_S        8        0,4,8,     Partially      Specifies the number of secure MPU
//                       12,16      MPUSDISABLE    regions included
//                                                 0:  No MPU regions
//                                                 4:  4 MPU regions
//                                                 8:  8 MPU regions
//                                                 12: 12 MPU regions
//                                                 16: 16 MPU regions
//                                                 NB. If SECEXT is set to 0 this parameter
//                                                 is ignored
// --------------------------------------------------------------------------------------
// SAU          4        0,4,8      Partially      Specifies the number of SAU regions
//                                  SAUDISABLE     included
//                                                 0: No SAU regions
//                                                 4: 4 SAU regions
//                                                 8: 8 SAU regions
//                                                 NB. If SECEXT is set to 0 this parameter
//                                                 is ignored
//                                                 If SAU is set to 0 the memory regions
//                                                 can be specified by an external IMP_DEF
//                                                 interface
// --------------------------------------------------------------------------------------
// ITGU         0        0,1         No            Specifies whether the ITCM Gate Unit is
//                                                 included
//                                                 0: ITGU is not included
//                                                 1: ITGU is included
//                                                 NB. If SECEXT is set to 0 this parameter
//                                                 is ignored
// --------------------------------------------------------------------------------------
// ITGUBLKSZ    6        0..15       No            ITCM gate unit block size
//                                                 Size in bytes = 2^(ITGUBLKSZ+5)
//                                                 Minimum block size: 32 bytes
//                                                 Maximum block size: 1 MB
// --------------------------------------------------------------------------------------
// ITGUMAXBLKS  1        1..9        No            Maximum number of ITCM gate unit blocks
//                                                 Number of blocks = 2^ITGUMAXBLKS
// --------------------------------------------------------------------------------------
// DTGU         0        0,1         No            Specifies whether the DTCM Gate Unit is
//                                                 included
//                                                 0: DTGU is not included
//                                                 1: DTGU is included
//                                                 NB. If SECEXT is set to 0 this parameter
//                                                 is ignored
// --------------------------------------------------------------------------------------
// DTGUBLKSZ    6        0..15       No            DTCM gate unit block size
//                                                 Size in bytes = 2^(DTGUBLKSZ+5)
//                                                 Minimum block size: 32 bytes
//                                                 Maximum block size: 1 MB
// --------------------------------------------------------------------------------------
// DTGUMAXBLKS  1        1..9        No            Maximum number of DTCM gate unit blocks
//                                                 Number of blocks = 2^DTGUMAXBLKS
// --------------------------------------------------------------------------------------
// NUMIRQ       32       1..480      No            Specifies the number of external
//                                                 interrupts included. Interrupt numbers
//                                                 are IRQ0 to IRQ(NUMIRQ-1)
// --------------------------------------------------------------------------------------
// IRQLVL       3        3..8        No            Specifies the number of exception
//                                                 priority bits
// --------------------------------------------------------------------------------------
// IRQTIER      All      NUMIRQ      No            Specifies the individual interrupts
//              zeros    length                    which support the lowest interrupt
//                       vector                    latency. This allows a range of
//                                                 low latency interrupts IRQTIER[i] =
//                                                 1'b1 indicates that IRQ[i] is high
//                                                 latency
// --------------------------------------------------------------------------------------
// IRQDIS       All      NUMIRQ      No            Disables support for individual
//              zeros    length                    interrupts, allowing a range of
//                       vector                    non-contiguous interrupts
//                                                 IRQDIS[i] = 1'b1 indicates that IRQ[i]
//                                                 is not present
// --------------------------------------------------------------------------------------
// BUSPROT      0        0, 1        No            Specifies whether Bus protection is
//                                                 supported on the M-AXI, P-AHB, EPPB
//                                                 and S-AXI interfaces on the processor
//                                                 0: Bus protection not included
//                                                 1: Bus protection included
// --------------------------------------------------------------------------------------
// LOCKSTEP     0        0, 1        No            Specifies whether the processor is
//                                                 configured for dual-redundant lockstep
//                                                 operation
//                                                 0: Regular processor operation
//                                                 1: Dual-redundant lockstep operation
//                                                 Note: FLOPPARITY must be set to 0 if
//                                                 LOCKSTEP is set to 1
// --------------------------------------------------------------------------------------
// FLOPPARITY   0        0,1         No            Specifies whether the processor is
//                                                 configured with parity generation and
//                                                 and checks on all flip-flops in
//                                                 non-debug logic
//                                                 0: No parity on flip-flops
//                                                 1: Include parity on flip-flops
//                                                 Notes:
//                                                 - LOCKSTEP must be set to 0 if
//                                                   FLOPPARITY is set to 1
//                                                 - RAR must be set to 1 if
//                                                   FLOPPARITY is set to 1
// --------------------------------------------------------------------------------------
// DBGLVL       2        0, 1, 2, 3  No            Specifies the number of debug
//                                                 resources included
//                                                 0: Minimal debug: No halting debug or
//                                                    memory access
//                                                 1: Reduced set: 2 watchpoint and 4
//                                                    breakpoint comparators
//                                                 2: Full set: 4 watchpoint and 8 break
//                                                    point comparators
//                                                 3: Full set 8 DWT and 8 BPU comparators
//                                                 Debug Monitor mode and the Unprivileged
//                                                 Debug Extension is always supported.
//                                                 The PMU is included when DBGLVL is non-zero
// --------------------------------------------------------------------------------------
// ITM          1        0,1         No            Specifies the level of instrumentation
//                                                 trace supported
//                                                 0: No Trace included, DWT triggers and
//                                                    counters not included
//                                                 1: Include DWT and ITM trace
//                                                 If DBGLVL is set 0 zero no trace is
//                                                 included in the processor i.e. ITM,
//                                                 ETM and MTB parameters are ignored.
// --------------------------------------------------------------------------------------
// ETM          0        0,1         No            Specifies support for ETM trace
//                                                 0: No ETM trace included
//                                                 1: ETM included
//                                                 The ETM parameter is ignored if DBGLVL
//                                                 is 0.
//                                                 If ETM is set to 1 the partner must
//                                                 have licensed the ETM unit.
// --------------------------------------------------------------------------------------
// PMC          0        0, 1        No            Specifies whether the Programmable
//                                                 MBIST Controller (PMC-100) is included
//                                                 0: PMC-100 not included
//                                                 1: PMC-100 included
//                                                 Note: PMC-100 is delivered as part of
//                                                 the optional licensable Safety package
// --------------------------------------------------------------------------------------
// PMCPROGSIZE  14       14..32                    Specifies the number of microcode program
//                                                 registers implemented in PMC-100
//                                                 0..13:  Reserved
//                                                 14..32: Number of microcode registers
//                                                 Note: This parameter is not used when
//                                                 the PMC-100 is not included
// --------------------------------------------------------------------------------------
// IWIC         1        0,1         No            Specifies whether the Internal Wake-up
//                                                 Interrupt Controller (IWIC) is included
//                                                 0: I-WIC not included
//                                                 1: I-WIC included
// --------------------------------------------------------------------------------------
// WICLINES     NUMIRQ+3 4..NUMIRQ+3 No            Specifies the number of IRQ lines
//                                                 supported by the WIC. The value always
//                                                 includes the three internal events NMI,
//                                                 RVEX and Debug monitor event.
// --------------------------------------------------------------------------------------
// CTI          1        0,1                       Specifies whether the Cross Trigger
//                                                 Interface (CTI) unit is include
//                                                 0: CTI not included
//                                                 1: CTI included
// --------------------------------------------------------------------------------------
// RAR          0        0,1         No            Specifies whether all synchronous
//                                                 state or only architecturally required
//                                                 state is reset
//                                                 0: Only reset state required by the
//                                                    architecture
//                                                 1: Reset all synchronous state
//                                                 Note: RAR must be set to 1 if
//                                                 FLOPPARITY is set to 1
// --------------------------------------------------------------------------------------
// CDEMAPPEDONCP*  0      0,1         Yes          Specifies whether the instruction for
//                                    CFGNOCDECP*  this coprocessor is redirected to the
//                                                 CDE modules :
//                                                 0: CDE modules not used
//                                                 1: CDE modules used
// --------------------------------------------------------------------------------------
// CDERTLID        0      0,1,2..255  No           RTL identification used for System with
//                                                 multi Cortex-M55 or to differentiate CDE
//                                                 RTL version.
// --------------------------------------------------------------------------------------

parameter ICACHESZ           =  5'b00111,
parameter DCACHESZ           =  5'b00111,
parameter IDCACHEID          =  0,
parameter ECC                =  0,
parameter FPU                =  1,
parameter MVE                =  1,
parameter SECEXT             =  0,
parameter CPIF               =  1,
parameter MPU_NS             =  8,
parameter MPU_S              =  8,
parameter SAU                =  4,
parameter ITGU               =  0,
parameter DTGU               =  0,
parameter ITGUBLKSZ          =  6,
parameter DTGUBLKSZ          =  6,
parameter ITGUMAXBLKS        =  1,
parameter DTGUMAXBLKS        =  1,
parameter NUMIRQ             =  240,
parameter IRQLVL             =  3,
parameter [479:0] IRQTIER    =  {480{1'b0}},
parameter [479:0] IRQDIS     =  {480{1'b0}},
parameter BUSPROT            =  0,
parameter LOCKSTEP           =  0,
parameter FLOPPARITY         =  0,
parameter DBGLVL             =  2,
parameter ITM                =  1,
parameter ETM                =  0,
parameter PMC                =  0,
parameter PMCPROGSIZE        =  14,
parameter IWIC               =  1,
parameter WICLINES           =  NUMIRQ+3,
parameter CTI                =  0,
parameter RAR                =  0,
parameter CDEMAPPEDONCP0     =  0,
parameter CDEMAPPEDONCP1     =  0,
parameter CDEMAPPEDONCP2     =  0,
parameter CDEMAPPEDONCP3     =  0,
parameter CDEMAPPEDONCP4     =  0,
parameter CDEMAPPEDONCP5     =  0,
parameter CDEMAPPEDONCP6     =  0,
parameter CDEMAPPEDONCP7     =  0,
parameter CDERTLID           =  0
