
module millisoc_cpu_dma(
    input  wire         HCLK,
    input  wire         HRESETn,

    input wire          PCLKEN_DMA,
    input wire          PSEL_DMA,
    input wire          PEN_DMA,
    input wire          PWRITE_DMA,
    input wire [11:0]   PADDR_DMA,
    input wire [31:0]   PWDATA_DMA,
    output wire [31:0]  PRDATA_DMA,

    output wire         HSEL_M7_AHBS,
    output wire [31:0]  HADDR_M7_AHBS,
    output wire [1:0]   HTRANS_M7_AHBS,
    output wire         HWRITE_M7_AHBS,
    output wire [2:0]   HSIZE_M7_AHBS,
    output wire [2:0]   HBURST_M7_AHBS,
    output wire [3:0]   HPROT_M7_AHBS,
    output wire [31:0]  HWDATA_M7_AHBS,
    output wire         HMASTLOCK_M7_AHBS,
    output wire         HREADYMUX_M7_AHBS,
    input  wire [31:0]  HRDATA_M7_AHBS,
    input  wire         HREADYOUT_M7_AHBS,
    input  wire         HRESP_M7_AHBS,

    output wire         HSEL_SYS_BUS,
    output wire [31:0]  HADDR_SYS_BUS,
    output wire [1:0]   HTRANS_SYS_BUS,
    output wire         HWRITE_SYS_BUS,
    output wire [2:0]   HSIZE_SYS_BUS,
    output wire [2:0]   HBURST_SYS_BUS,
    output wire [3:0]   HPROT_SYS_BUS,
    output wire [31:0]  HWDATA_SYS_BUS,
    output wire         HMASTLOCK_SYS_BUS,
    output wire         HREADYMUX_SYS_BUS,
    input  wire [31:0]  HRDATA_SYS_BUS,
    input  wire         HREADYOUT_SYS_BUS,
    input  wire         HRESP_SYS_BUS
);

// DMA AHB Bus Wires
wire [31:0] HADDR_DMAC_0;
wire [1:0]  HTRANS_DMAC_0;
wire        HWRITE_DMAC_0;
wire [2:0]  HSIZE_DMAC_0;
wire [2:0]  HBURST_DMAC_0;
wire [3:0]  HPROT_DMAC_0;
wire [31:0] HWDATA_DMAC_0;
wire        HMASTLOCK_DMAC_0;
wire        HREADY_DMAC_0;
wire [31:0] HRDATA_DMAC_0;
wire        HRESP_DMAC_0;

sldma230 #(
    .SYS_ADDR_W (32),
    .SYS_DATA_W (32),
    .CFG_ADDR_W (12),
    .CHANNEL_NUM(2)
) u_sldma230 (
    .HCLK        (HCLK        ),
    .HRESETn     (HRESETn     ),

    // AHB Lite Port
    .HADDR       (HADDR_DMAC_0),
    .HTRANS      (HTRANS_DMAC_0),
    .HWRITE      (HWRITE_DMAC_0),
    .HSIZE       (HSIZE_DMAC_0),
    .HBURST      (HBURST_DMAC_0),
    .HPROT       (HPROT_DMAC_0),
    .HWDATA      (HWDATA_DMAC_0),
    .HMASTLOCK   (HMASTLOCK_DMAC_0),
    .HRDATA      (HRDATA_DMAC_0),
    .HREADY      (HREADY_DMAC_0),
    .HRESP       (HRESP_DMAC_0),

    // APB Configurtation Port
    .PCLKEN      (PCLKEN_DMA),
    .PSEL        (PSEL_DMA),
    .PEN         (PEN_DMA),
    .PWRITE      (PWRITE_DMA),
    .PADDR       (PADDR_DMA),
    .PWDATA      (PWDATA_DMA),
    .PRDATA      (PRDATA_DMA),

    // DMA Request and Status Port
    .DMA_REQ     (1'b0        ),
    .DMA_DONE    (            ),
    .DMA_ERR     (            )
);

millisoc_dma_busmatrix_lite u_millisoc_dma_busmatrix (
    .HCLK      (HCLK      ),
    .HRESETn   (HRESETn   ),
    .REMAP     (4'h0      ),

    .SCANENABLE(1'b0      ),
    .SCANINHCLK(1'b0      ),

    // DMA Master 0 (DMA0)
    .HADDR_DMAC_0(HADDR_DMAC_0),
    .HTRANS_DMAC_0(HTRANS_DMAC_0),
    .HWRITE_DMAC_0(HWRITE_DMAC_0),
    .HSIZE_DMAC_0(HSIZE_DMAC_0),
    .HBURST_DMAC_0(HBURST_DMAC_0),
    .HPROT_DMAC_0(HPROT_DMAC_0),
    .HWDATA_DMAC_0(HWDATA_DMAC_0),
    .HMASTLOCK_DMAC_0(HMASTLOCK_DMAC_0),
    .HREADY_DMAC_0(HREADY_DMAC_0),
    .HRDATA_DMAC_0(HRDATA_DMAC_0),
    .HRESP_DMAC_0(HRESP_DMAC_0),

    // M7 Slave
    .HSEL_M7_AHBS(HSEL_M7_AHBS),
    .HADDR_M7_AHBS(HADDR_M7_AHBS),
    .HTRANS_M7_AHBS(HTRANS_M7_AHBS),
    .HWRITE_M7_AHBS(HWRITE_M7_AHBS),
    .HSIZE_M7_AHBS(HSIZE_M7_AHBS),
    .HBURST_M7_AHBS(HBURST_M7_AHBS),
    .HPROT_M7_AHBS(HPROT_M7_AHBS),
    .HWDATA_M7_AHBS(HWDATA_M7_AHBS),
    .HMASTLOCK_M7_AHBS(HMASTLOCK_M7_AHBS),
    .HREADYMUX_M7_AHBS(HREADYMUX_M7_AHBS),
    .HRDATA_M7_AHBS(HRDATA_M7_AHBS),
    .HREADYOUT_M7_AHBS(HREADYOUT_M7_AHBS),
    .HRESP_M7_AHBS(HRESP_M7_AHBS),

    // System Slave
    .HSEL_SYS_BUS(HSEL_SYS_BUS),
    .HADDR_SYS_BUS(HADDR_SYS_BUS),
    .HTRANS_SYS_BUS(HTRANS_SYS_BUS),
    .HWRITE_SYS_BUS(HWRITE_SYS_BUS),
    .HSIZE_SYS_BUS(HSIZE_SYS_BUS),
    .HBURST_SYS_BUS(HBURST_SYS_BUS),
    .HPROT_SYS_BUS(HPROT_SYS_BUS),
    .HWDATA_SYS_BUS(HWDATA_SYS_BUS),
    .HMASTLOCK_SYS_BUS(HMASTLOCK_SYS_BUS),
    .HREADYMUX_SYS_BUS(HREADYMUX_SYS_BUS),
    .HRDATA_SYS_BUS(HRDATA_SYS_BUS),
    .HREADYOUT_SYS_BUS(HREADYOUT_SYS_BUS),
    .HRESP_SYS_BUS(HRESP_SYS_BUS)
);

endmodule
