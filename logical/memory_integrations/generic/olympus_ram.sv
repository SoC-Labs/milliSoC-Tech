//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2012-2022 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
// Release Information : Cortex-M85-r1p0-00rel0
//------------------------------------------------------------------------------
// SystemVerilog (IEEE Std 1800-2012)
//------------------------------------------------------------------------------
module olympus_ram import olympus_pkg::*;
#(
 `include "olympus_decl.sv"
)
(
 input  wire         rclk,
 input  wire [ 3:0]  dcu_ram_tag_en_i,
 input  wire         dcu_ram_tag_wr_i,
 input  wire [33:0]  dcu_ram_tag_wdata_i,
 input  wire [ 8:0]  dcu_ram_tag_addr_i,
 output wire [33:0]  ram_dcu_tag_rdata0_o,
 output wire [33:0]  ram_dcu_tag_rdata1_o,
 output wire [33:0]  ram_dcu_tag_rdata2_o,
 output wire [33:0]  ram_dcu_tag_rdata3_o,
 input  wire [ 3:0]  dcu_ram_data0_en_i,
 input  wire         dcu_ram_data0_wr_i,
 input  wire [ 4:0]  dcu_ram_data0_strb0_i,
 input  wire [ 4:0]  dcu_ram_data0_strb1_i,
 input  wire [ 4:0]  dcu_ram_data0_strb2_i,
 input  wire [ 4:0]  dcu_ram_data0_strb3_i,
 input  wire [10:0]  dcu_ram_data0_addr0_i,
 input  wire [10:0]  dcu_ram_data0_addr1_i,
 input  wire [10:0]  dcu_ram_data0_addr2_i,
 input  wire [10:0]  dcu_ram_data0_addr3_i,
 input  wire [38:0]  dcu_ram_data0_wdata0_i,
 input  wire [38:0]  dcu_ram_data0_wdata1_i,
 input  wire [38:0]  dcu_ram_data0_wdata2_i,
 input  wire [38:0]  dcu_ram_data0_wdata3_i,
 output wire [38:0]  ram_dcu_data0_rdata0_o,
 output wire [38:0]  ram_dcu_data0_rdata1_o,
 output wire [38:0]  ram_dcu_data0_rdata2_o,
 output wire [38:0]  ram_dcu_data0_rdata3_o,
 input  wire [ 3:0]  dcu_ram_data1_en_i,
 input  wire         dcu_ram_data1_wr_i,
 input  wire [ 4:0]  dcu_ram_data1_strb0_i,
 input  wire [ 4:0]  dcu_ram_data1_strb1_i,
 input  wire [ 4:0]  dcu_ram_data1_strb2_i,
 input  wire [ 4:0]  dcu_ram_data1_strb3_i,
 input  wire [10:0]  dcu_ram_data1_addr0_i,
 input  wire [10:0]  dcu_ram_data1_addr1_i,
 input  wire [10:0]  dcu_ram_data1_addr2_i,
 input  wire [10:0]  dcu_ram_data1_addr3_i,
 input  wire [38:0]  dcu_ram_data1_wdata0_i,
 input  wire [38:0]  dcu_ram_data1_wdata1_i,
 input  wire [38:0]  dcu_ram_data1_wdata2_i,
 input  wire [38:0]  dcu_ram_data1_wdata3_i,
 output wire [38:0]  ram_dcu_data1_rdata0_o,
 output wire [38:0]  ram_dcu_data1_rdata1_o,
 output wire [38:0]  ram_dcu_data1_rdata2_o,
 output wire [38:0]  ram_dcu_data1_rdata3_o,
 input  wire [1:0]   icu_ram_tag_en_i,
 input  wire         icu_ram_tag_wr_i,
 input  wire [27:0]  icu_ram_tag_wdata_i,
 input  wire [9:0]   icu_ram_tag_addr_i,
 output wire [27:0]  ram_icu_tag_rdata0_o,
 output wire [27:0]  ram_icu_tag_rdata1_o,
 input  wire [1:0]   icu_ram_data_en_i,
 input  wire         icu_ram_data_wr_i,
 input  wire [11:0]  icu_ram_data_addr0_i,
 input  wire [11:0]  icu_ram_data_addr1_i,
 input  wire [70:0]  icu_ram_data_wdata0_i,
 input  wire [70:0]  icu_ram_data_wdata1_i,
 output wire [70:0]  ram_icu_data_rdata0_o,
 output wire [70:0]  ram_icu_data_rdata1_o
);


  wire [3:0] ram_icu_cache_size = ICACHESZ[4:1];
  wire [3:0] ram_dcu_cache_size = DCACHESZ[4:1];


  localparam OLYMPUS_IDATA_RAM_ADDR_W = 12;
  localparam OLYMPUS_IDATA_RAM_W      = 71;
  localparam OLYMPUS_ITAG_RAM_ADDR_W  = 10;
  localparam OLYMPUS_ITAG_RAM_W       = 28;

  localparam OLYMPUS_DDATA_RAM_ADDR_W = 11;
  localparam OLYMPUS_DDATA_RAM_W      = 39;
  localparam OLYMPUS_DTAG_RAM_ADDR_W  =  9;
  localparam OLYMPUS_DTAG_RAM_W       = 34;

  generate
    if (ICACHE) begin : gen_icache


      spram_we #(.ADDR_WIDTH(OLYMPUS_IDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_IDATA_RAM_W)) u_idata_bank0
        (
         .clk    (rclk),
         .addr_i (icu_ram_data_addr0_i & {ram_icu_cache_size, 8'b1111_1111}),
         .rd_o   (ram_icu_data_rdata0_o[0 +:OLYMPUS_IDATA_RAM_W]),
         .wd_i   (icu_ram_data_wdata0_i[0 +:OLYMPUS_IDATA_RAM_W]),
         .cs_i   (icu_ram_data_en_i[0]),
         .we_i   ({OLYMPUS_IDATA_RAM_W{icu_ram_data_wr_i}})
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_IDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_IDATA_RAM_W)) u_idata_bank1
        (
         .clk    (rclk),
         .addr_i (icu_ram_data_addr1_i & {ram_icu_cache_size, 8'b1111_1111}),
         .rd_o   (ram_icu_data_rdata1_o[0 +:OLYMPUS_IDATA_RAM_W]),
         .wd_i   (icu_ram_data_wdata1_i[0 +:OLYMPUS_IDATA_RAM_W]),
         .cs_i   (icu_ram_data_en_i[1]),
         .we_i   ({OLYMPUS_IDATA_RAM_W{icu_ram_data_wr_i}})
        );



      spram_we #(.ADDR_WIDTH(OLYMPUS_ITAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_ITAG_RAM_W)) u_itag_bank0
        (
         .clk    (rclk),
         .addr_i (icu_ram_tag_addr_i & {ram_icu_cache_size, 6'b11_1111}),
         .rd_o   (ram_icu_tag_rdata0_o[0 +:OLYMPUS_ITAG_RAM_W]),
         .wd_i   (icu_ram_tag_wdata_i[0 +:OLYMPUS_ITAG_RAM_W]),
         .cs_i   (icu_ram_tag_en_i[0]),
         .we_i   ({OLYMPUS_ITAG_RAM_W{icu_ram_tag_wr_i}})
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_ITAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_ITAG_RAM_W)) u_itag_bank1
        (
         .clk    (rclk),
         .addr_i (icu_ram_tag_addr_i & {ram_icu_cache_size, 6'b11_1111}),
         .rd_o   (ram_icu_tag_rdata1_o[0 +:OLYMPUS_ITAG_RAM_W]),
         .wd_i   (icu_ram_tag_wdata_i[0 +:OLYMPUS_ITAG_RAM_W]),
         .cs_i   (icu_ram_tag_en_i[1]),
         .we_i   ({OLYMPUS_ITAG_RAM_W{icu_ram_tag_wr_i}})
        );
    end else begin : gen_no_icache
      assign ram_icu_data_rdata0_o = {OLYMPUS_IDATA_RAM_W{1'b0}};
      assign ram_icu_data_rdata1_o = {OLYMPUS_IDATA_RAM_W{1'b0}};
      assign ram_icu_tag_rdata0_o  = {OLYMPUS_ITAG_RAM_W{1'b0}};
      assign ram_icu_tag_rdata1_o  = {OLYMPUS_ITAG_RAM_W{1'b0}};
      wire unused_i = |{ icu_ram_tag_en_i,
                                icu_ram_tag_wr_i,
                                icu_ram_tag_wdata_i,
                                icu_ram_tag_addr_i,
                                icu_ram_data_en_i,
                                icu_ram_data_wr_i,
                                icu_ram_data_addr0_i,
                                icu_ram_data_addr1_i,
                                icu_ram_data_wdata0_i,
                                icu_ram_data_wdata1_i,
                                ram_icu_cache_size};
    end
  endgenerate

  generate
    if (DCACHE) begin : gen_dcache



      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata0_bank0
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data0_addr0_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data0_rdata0_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data0_wdata0_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data0_en_i[0]),
         .we_i   ({{7{dcu_ram_data0_strb0_i[4]}},
                   {8{dcu_ram_data0_strb0_i[3]}},
                   {8{dcu_ram_data0_strb0_i[2]}},
                   {8{dcu_ram_data0_strb0_i[1]}},
                   {8{dcu_ram_data0_strb0_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata0_bank1
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data0_addr1_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data0_rdata1_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data0_wdata1_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data0_en_i[1]),
         .we_i   ({{7{dcu_ram_data0_strb1_i[4]}},
                   {8{dcu_ram_data0_strb1_i[3]}},
                   {8{dcu_ram_data0_strb1_i[2]}},
                   {8{dcu_ram_data0_strb1_i[1]}},
                   {8{dcu_ram_data0_strb1_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata0_bank2
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data0_addr2_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data0_rdata2_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data0_wdata2_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data0_en_i[2]),
         .we_i   ({{7{dcu_ram_data0_strb2_i[4]}},
                   {8{dcu_ram_data0_strb2_i[3]}},
                   {8{dcu_ram_data0_strb2_i[2]}},
                   {8{dcu_ram_data0_strb2_i[1]}},
                   {8{dcu_ram_data0_strb2_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata0_bank3
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data0_addr3_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data0_rdata3_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data0_wdata3_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data0_en_i[3]),
         .we_i   ({{7{dcu_ram_data0_strb3_i[4]}},
                   {8{dcu_ram_data0_strb3_i[3]}},
                   {8{dcu_ram_data0_strb3_i[2]}},
                   {8{dcu_ram_data0_strb3_i[1]}},
                   {8{dcu_ram_data0_strb3_i[0]}}
                  })
        );


      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata1_bank0
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data1_addr0_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data1_rdata0_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data1_wdata0_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data1_en_i[0]),
         .we_i   ({{7{dcu_ram_data1_strb0_i[4]}},
                   {8{dcu_ram_data1_strb0_i[3]}},
                   {8{dcu_ram_data1_strb0_i[2]}},
                   {8{dcu_ram_data1_strb0_i[1]}},
                   {8{dcu_ram_data1_strb0_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata1_bank1
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data1_addr1_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data1_rdata1_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data1_wdata1_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data1_en_i[1]),
         .we_i   ({{7{dcu_ram_data1_strb1_i[4]}},
                   {8{dcu_ram_data1_strb1_i[3]}},
                   {8{dcu_ram_data1_strb1_i[2]}},
                   {8{dcu_ram_data1_strb1_i[1]}},
                   {8{dcu_ram_data1_strb1_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata1_bank2
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data1_addr2_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data1_rdata2_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data1_wdata2_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data1_en_i[2]),
         .we_i   ({{7{dcu_ram_data1_strb2_i[4]}},
                   {8{dcu_ram_data1_strb2_i[3]}},
                   {8{dcu_ram_data1_strb2_i[2]}},
                   {8{dcu_ram_data1_strb2_i[1]}},
                   {8{dcu_ram_data1_strb2_i[0]}}
                  })
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DDATA_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DDATA_RAM_W)) u_ddata1_bank3
        (
         .clk    (rclk),
         .addr_i (dcu_ram_data1_addr3_i & {ram_dcu_cache_size, 7'b111_1111}),
         .rd_o   (ram_dcu_data1_rdata3_o[0 +:OLYMPUS_DDATA_RAM_W]),
         .wd_i   (dcu_ram_data1_wdata3_i[0 +:OLYMPUS_DDATA_RAM_W]),
         .cs_i   (dcu_ram_data1_en_i[3]),
         .we_i   ({{7{dcu_ram_data1_strb3_i[4]}},
                   {8{dcu_ram_data1_strb3_i[3]}},
                   {8{dcu_ram_data1_strb3_i[2]}},
                   {8{dcu_ram_data1_strb3_i[1]}},
                   {8{dcu_ram_data1_strb3_i[0]}}
                  })
        );



      spram_we #(.ADDR_WIDTH(OLYMPUS_DTAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DTAG_RAM_W)) u_dtag_bank0
        (
         .clk    (rclk),
         .addr_i (dcu_ram_tag_addr_i & {ram_dcu_cache_size, 5'b1_1111}),
         .rd_o   (ram_dcu_tag_rdata0_o[0 +:OLYMPUS_DTAG_RAM_W]),
         .wd_i   (dcu_ram_tag_wdata_i[0 +:OLYMPUS_DTAG_RAM_W]),
         .cs_i   (dcu_ram_tag_en_i[0]),
         .we_i   ({OLYMPUS_DTAG_RAM_W{dcu_ram_tag_wr_i}})
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DTAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DTAG_RAM_W)) u_dtag_bank1
        (
         .clk    (rclk),
         .addr_i (dcu_ram_tag_addr_i & {ram_dcu_cache_size, 5'b1_1111}),
         .rd_o   (ram_dcu_tag_rdata1_o[0 +:OLYMPUS_DTAG_RAM_W]),
         .wd_i   (dcu_ram_tag_wdata_i[0 +:OLYMPUS_DTAG_RAM_W]),
         .cs_i   (dcu_ram_tag_en_i[1]),
         .we_i   ({OLYMPUS_DTAG_RAM_W{dcu_ram_tag_wr_i}})
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DTAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DTAG_RAM_W)) u_dtag_bank2
        (
         .clk    (rclk),
         .addr_i (dcu_ram_tag_addr_i & {ram_dcu_cache_size, 5'b1_1111}),
         .rd_o   (ram_dcu_tag_rdata2_o[0 +:OLYMPUS_DTAG_RAM_W]),
         .wd_i   (dcu_ram_tag_wdata_i[0 +:OLYMPUS_DTAG_RAM_W]),
         .cs_i   (dcu_ram_tag_en_i[2]),
         .we_i   ({OLYMPUS_DTAG_RAM_W{dcu_ram_tag_wr_i}})
        );

      spram_we #(.ADDR_WIDTH(OLYMPUS_DTAG_RAM_ADDR_W), .DATA_WIDTH(OLYMPUS_DTAG_RAM_W)) u_dtag_bank3
        (
         .clk    (rclk),
         .addr_i (dcu_ram_tag_addr_i & {ram_dcu_cache_size, 5'b1_1111}),
         .rd_o   (ram_dcu_tag_rdata3_o[0 +:OLYMPUS_DTAG_RAM_W]),
         .wd_i   (dcu_ram_tag_wdata_i[0 +:OLYMPUS_DTAG_RAM_W]),
         .cs_i   (dcu_ram_tag_en_i[3]),
         .we_i   ({OLYMPUS_DTAG_RAM_W{dcu_ram_tag_wr_i}})
        );
      wire [1:0] unused_d = { dcu_ram_data0_wr_i, dcu_ram_data1_wr_i};

    end else begin : gen_no_dcache
      assign ram_dcu_data0_rdata0_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data0_rdata1_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data0_rdata2_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data0_rdata3_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data1_rdata0_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data1_rdata1_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data1_rdata2_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_data1_rdata3_o = {OLYMPUS_DDATA_RAM_W{1'b0}};
      assign ram_dcu_tag_rdata0_o   = {OLYMPUS_DTAG_RAM_W{1'b0}};
      assign ram_dcu_tag_rdata1_o   = {OLYMPUS_DTAG_RAM_W{1'b0}};
      assign ram_dcu_tag_rdata2_o   = {OLYMPUS_DTAG_RAM_W{1'b0}};
      assign ram_dcu_tag_rdata3_o   = {OLYMPUS_DTAG_RAM_W{1'b0}};
      wire unused_d = |{ dcu_ram_tag_en_i,
                                dcu_ram_tag_wr_i,
                                dcu_ram_tag_wdata_i,
                                dcu_ram_tag_addr_i,
                                dcu_ram_data0_en_i,
                                dcu_ram_data0_wr_i,
                                dcu_ram_data0_strb0_i,
                                dcu_ram_data0_strb1_i,
                                dcu_ram_data0_strb2_i,
                                dcu_ram_data0_strb3_i,
                                dcu_ram_data0_addr0_i,
                                dcu_ram_data0_addr1_i,
                                dcu_ram_data0_addr2_i,
                                dcu_ram_data0_addr3_i,
                                dcu_ram_data0_wdata0_i,
                                dcu_ram_data0_wdata1_i,
                                dcu_ram_data0_wdata2_i,
                                dcu_ram_data0_wdata3_i,
                                dcu_ram_data1_en_i,
                                dcu_ram_data1_wr_i,
                                dcu_ram_data1_strb0_i,
                                dcu_ram_data1_strb1_i,
                                dcu_ram_data1_strb2_i,
                                dcu_ram_data1_strb3_i,
                                dcu_ram_data1_addr0_i,
                                dcu_ram_data1_addr1_i,
                                dcu_ram_data1_addr2_i,
                                dcu_ram_data1_addr3_i,
                                dcu_ram_data1_wdata0_i,
                                dcu_ram_data1_wdata1_i,
                                dcu_ram_data1_wdata2_i,
                                dcu_ram_data1_wdata3_i,
                                ram_dcu_cache_size};
    end
  endgenerate

endmodule
