//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2011 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: $
//
//      Revision            : $Revision: $
//
//      Release Information : Cortex-R5-AT570-r1p2-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract: An example TCM implementation module for Cortex-R5
//
// Overview:
//
//-----------------------------------------------------------------------------

module cortexr5_tcm
  #(parameter    A_WIDTH = 20, // Default = 8MB
    parameter    ECC = 1       // Default = ECC32
    )
  (input  wire        clk,          // Clock
   input  wire        rstn,         // Reset (not used, include for FPGA version compatiability)
   input  wire [22:3] addr,         // Address
   input  wire [ 1:0] cs,           // Chip select
   input  wire        we,           // Write enable
   input  wire [ 7:0] strb,         // Write strobes
   input  wire [63:0] data_out,     // Write data
   input  wire [13:0] parity_out,   // Write data ECC
   output wire [63:0] data_in,      // Read data
   output wire [13:0] parity_in,    // Read data ECC
   output wire        stall,        // Stall signal to extend data phase
   output wire        retry,        // Retry signal
   output wire        error,        // Error
   output wire        lateerror     // Late error
   );

  wire [A_WIDTH-4:0] ram_addr = addr[A_WIDTH-1:3]; // Implemented address bits
  wire [7:0]         strb_q   = {8{we}} & strb;    // Qualified strobes
  
  // Implement RAM banks
  // NOTE: All signals are active HIGH
  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b0
    (.clk         (clk),
      .cs         (cs[0]),
      .addr       (ram_addr),
      .din       (data_out[7:0]),
      .we         (strb_q[0]),
      .dout        (data_in[7:0])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b1
    (.clk         (clk),
      .cs         (cs[0]),
      .addr       (ram_addr),
      .din       (data_out[15:8]),
      .we         (strb_q[1]),
      .dout        (data_in[15:8])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b2
    (.clk         (clk),
      .cs         (cs[0]),
      .addr       (ram_addr),
      .din       (data_out[23:16]),
      .we         (strb_q[2]),
      .dout        (data_in[23:16])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b3
    (.clk         (clk),
      .cs         (cs[0]),
      .addr       (ram_addr),
      .din       (data_out[31:24]),
      .we         (strb_q[3]),
      .dout        (data_in[31:24])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b4
    (.clk         (clk),
      .cs         (cs[1]),
      .addr       (ram_addr),
      .din       (data_out[39:32]),
      .we         (strb_q[4]),
      .dout        (data_in[39:32])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b5
    (.clk         (clk),
      .cs         (cs[1]),
      .addr       (ram_addr),
      .din       (data_out[47:40]),
      .we         (strb_q[5]),
      .dout        (data_in[47:40])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b6
    (.clk         (clk),
      .cs         (cs[1]),
      .addr       (ram_addr),
      .din       (data_out[55:48]),
      .we         (strb_q[6]),
      .dout        (data_in[55:48])
      );

  spram 
    #(.ADDR_WIDTH  (A_WIDTH-3),
      .DATA_WIDTH (8)
      )
  u_tcm_ram_0_b7
    (.clk         (clk),
      .cs         (cs[1]),
      .addr       (ram_addr),
      .din       (data_out[63:56]),
      .we         (strb_q[7]),
      .dout        (data_in[63:56])
      );


  assign parity_in = {14{1'b0}};

  // Tie off unused signals
  assign error     = 1'b0;
  assign lateerror = 1'b0;
  assign retry     = 1'b0;
  assign stall     = 1'b0;
  
endmodule // cortexr5_tcm


