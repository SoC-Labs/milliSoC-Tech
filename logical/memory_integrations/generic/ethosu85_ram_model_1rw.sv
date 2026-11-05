//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2024 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//            Release Information : ETHOSU85-ML009-r0p0-00eac0
//
//-----------------------------------------------------------------------------
// SystemVerilog (IEEE Std 1800-2017)
//-----------------------------------------------------------------------------



module ethosu85_ram_model_1rw #(
  parameter ADDR_BITS      = 4,
            ARRAY_HEIGHT   = 1<<ADDR_BITS,
            DATA_BITS      = 64,
            ELEM_SIZE      = DATA_BITS,
            LRE_BITS       = 1,
            LRE_ELEM0      = DATA_BITS/ELEM_SIZE,
            LRE_ELEM1      = 0,
            LRE_ELEM2      = 0,
            LRE_ELEM3      = 0,
            RESET_VALUE    = {DATA_BITS{1'b0}},
            LISL_WU_DELAY  = 0,
            RET1_WU_DELAY  = 0,
            RET2_WU_DELAY  = 0,

            POP_RAM = 0,
            RD_X_INJECTION = 1,
            CAN_INJECT_DBL_ERR = 1
)
(
  input  wire                                clk,
  input  wire [ADDR_BITS-1:0]                addr_i,
  output wire [DATA_BITS-1:0]                rdata_o,
  input  wire [DATA_BITS-1:0]                wdata_i,
  input  wire                                ce_i,
  input  wire                                late_cancel_i,
  input  wire                                eva_i,
  input  wire [LRE_BITS-1:0]                 lre_i,
  input  wire                                gwe_i,
  input  wire [(DATA_BITS/ELEM_SIZE)-1:0]    elem_we_i,
  input  wire                                ece_i,
  input  wire                                pdw_i,
  input  wire                                ret_i,
  input  wire                                qnap_i,
  output wire                                prdy_o


);
wire pge  = ~pdw_i & ~ret_i;
wire ret1 = qnap_i |  ret_i;
wire ret2 = 1'b0;


wire light_sleep_mode   =  pge &  ret1;
wire ret1_mode          = ~pge &  ret1;
wire ret2_mode          = ~pge & ~ret1 &  ret2;
wire power_down         = ~pge & ~ret1 & ~ret2;
wire chip_en            =  pge & ~ret1;
wire valid_state        = light_sleep_mode | ret1_mode | ret2_mode | power_down | chip_en;
wire sleep_or_pdown_on  = light_sleep_mode | ret1_mode | ret2_mode | power_down;

assign prdy_o = ~valid_state                         & 1'bx
              | (light_sleep_mode | chip_en)         & 1'b1
              | (ret1_mode | ret2_mode | power_down) & 1'b0;



reg [ADDR_BITS-1:0]             addr_q;
reg                             gwe_q;
reg [LRE_BITS-1:0]              lre_q;

always @(posedge clk)
  if (ece_i) begin
    addr_q    <= addr_i;
    gwe_q     <= gwe_i;
    lre_q     <= lre_i;
  end

wire [ADDR_BITS-1:0]             gated_addr    = ece_i ? addr_i    : addr_q;
wire                             gated_gwe     = ece_i ? gwe_i     : gwe_q;
reg [3:0] gated_lre;
always @(*) begin
  if (LRE_BITS == 4)
    gated_lre = ece_i ? lre_i : lre_q;
  else
    gated_lre = ece_i ? {{4-LRE_BITS{1'b0}}, lre_i} : {{4-LRE_BITS{1'b0}}, lre_q};
end



wire ce_rd       = ce_i & ~gated_gwe & ~eva_i & ~late_cancel_i & ~sleep_or_pdown_on;
wire ce_wr       = ce_i &  gated_gwe & ~eva_i & ~sleep_or_pdown_on;
wire ce_eva      = ce_i              &  eva_i & ~sleep_or_pdown_on;
wire ce_rd_canceled = ce_i & ~gated_gwe & ~eva_i & late_cancel_i & ~sleep_or_pdown_on;

localparam LRE_BITS0 = LRE_ELEM0*ELEM_SIZE;
localparam LRE_BITS1 = LRE_ELEM1*ELEM_SIZE;
localparam LRE_BITS2 = LRE_ELEM2*ELEM_SIZE;
localparam LRE_BITS3 = LRE_ELEM3*ELEM_SIZE;

reg [DATA_BITS-1:0] lre_bit_en;
always @(*) begin
  if (LRE_BITS == 4)
    lre_bit_en = { {LRE_BITS3{gated_lre[3]}},
                   {LRE_BITS2{gated_lre[2]}},
                   {LRE_BITS1{gated_lre[1]}},
                   {LRE_BITS0{gated_lre[0]}}
                 };
  else if (LRE_BITS == 3)
    lre_bit_en = { {LRE_BITS2{gated_lre[2]}},
                   {LRE_BITS1{gated_lre[1]}},
                   {LRE_BITS0{gated_lre[0]}}
                 };
  else if (LRE_BITS == 2)
    lre_bit_en = { {LRE_BITS1{gated_lre[1]}},
                   {LRE_BITS0{gated_lre[0]}}
                 };
  else
    lre_bit_en = {LRE_BITS0{gated_lre[0]}};
end


wire [DATA_BITS-1:0] bit_re     = lre_bit_en;

wire delay_wr = 1'b0;

localparam ELEM_COUNT = DATA_BITS/ELEM_SIZE;
wire [DATA_BITS-1:0] ram_rdata;
genvar elem;
generate
  for (elem = 0; elem < ELEM_COUNT; elem = elem + 1) begin : gen_ram
    (* ram_style = "block" *) reg [ELEM_SIZE-1:0] mem_q[ARRAY_HEIGHT-1:0];
    reg [ELEM_SIZE-1:0] rdata_q;

    always @(posedge clk) begin
      if (ce_rd | ce_eva)
        rdata_q <= mem_q[gated_addr];

      if ((ce_wr | ce_eva) & ~delay_wr
          & elem_we_i[elem] & lre_bit_en[elem*ELEM_SIZE])
        mem_q[gated_addr] <= wdata_i[elem*ELEM_SIZE +: ELEM_SIZE];
    end

    assign ram_rdata[elem*ELEM_SIZE +: ELEM_SIZE] = rdata_q;
  end
endgenerate

reg [DATA_BITS-1:0] read_bit_en_q;
reg                 read_valid_q;
always @(posedge clk) begin
  if (ce_rd | ce_eva) begin
    read_bit_en_q <= bit_re;
    read_valid_q  <= 1'b1;
  end else if ((RD_X_INJECTION == 32'd1) | ce_rd_canceled) begin
    read_valid_q <= 1'b0;
  end
end

assign rdata_o = read_valid_q
               ? (ram_rdata & read_bit_en_q)
                 | (~read_bit_en_q & {DATA_BITS{RD_X_INJECTION == 32'd1}} & 'X)
               : 'X;



endmodule
