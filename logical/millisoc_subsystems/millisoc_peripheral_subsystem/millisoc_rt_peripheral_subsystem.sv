
module millisoc_rt_peripheral_subsystem(
    input  wire         CLK,
    input  wire         PORESETn,
    input  wire         SYSRESETn,

    axi3_if.subordinate AXI_PERIPH,

    apb4_if.master      MHU_SND,
    apb4_if.master      MHU_REC,

    // UART0
    input  wire         UARTRXD0,
    output wire         UARTTXD0,
    output wire         UARTTXEN0,
    // UART1
    input  wire         UARTRXD1,
    output wire         UARTTXD1,
    output wire         UARTTXEN1,

    // GPIO P0
    input  wire [15:0]  p0_in,
    output wire [15:0]  p0_out,
    output wire [15:0]  p0_en,
    output wire [15:0]  p0_func,

    // GPIO P1
    input  wire [15:0]  p1_in,
    output wire [15:0]  p1_out,
    output wire [15:0]  p1_en,
    output wire [15:0]  p1_func,

    // SPI Bus to Pads
    output wire         SPI_SSn,
    output wire         SPI_SCLK,
    output wire         SPI_MOSI,
    input  wire         SPI_MISO,

    output wire         WDOGRESREQ, // Watchdog reset request

    // Interrupts
    output wire [71:0]  PERI_IRQS   // Peripheral interrupts to GIC


);

ahb_if #(.DATA_W(32), .ADDR_W(32)) PERIPH_AHB();

nic400_Rx_peripheral u_Rx_peripheral_bus(
    .PADDR_power_ctrl(),
    .PWDATA_power_ctrl(),
    .PWRITE_power_ctrl(),
    .PPROT_power_ctrl(),
    .PSTRB_power_ctrl(),
    .PENABLE_power_ctrl(),
    .PSELx_power_ctrl(),
    .PRDATA_power_ctrl(32'd0),
    .PSLVERR_power_ctrl(1'b0),
    .PREADY_power_ctrl(1'b1),

    .HADDR_periph(PERIPH_AHB.HADDR),
    .HTRANS_periph(PERIPH_AHB.HTRANS),
    .HWRITE_periph(PERIPH_AHB.HWRITE),
    .HSIZE_periph(PERIPH_AHB.HSIZE),
    .HBURST_periph(PERIPH_AHB.HBURST),
    .HPROT_periph(PERIPH_AHB.HPROT),
    .HWDATA_periph(PERIPH_AHB.HWDATA),
    .HRDATA_periph(PERIPH_AHB.HRDATA),
    .HREADY_periph(PERIPH_AHB.HREADYOUT),
    .HRESP_periph(PERIPH_AHB.HRESP),

    .AWID_cpu_peri(AXI_PERIPH.AWID),
    .AWADDR_cpu_peri(AXI_PERIPH.AWADDR),
    .AWLEN_cpu_peri(AXI_PERIPH.AWLEN),
    .AWSIZE_cpu_peri(AXI_PERIPH.AWSIZE),
    .AWBURST_cpu_peri(AXI_PERIPH.AWBURST),
    .AWLOCK_cpu_peri(AXI_PERIPH.AWLOCK),
    .AWCACHE_cpu_peri(AXI_PERIPH.AWCACHE),
    .AWPROT_cpu_peri(AXI_PERIPH.AWPROT),
    .AWVALID_cpu_peri(AXI_PERIPH.AWVALID),
    .AWREADY_cpu_peri(AXI_PERIPH.AWREADY),
    .WID_cpu_peri(AXI_PERIPH.WID),
    .WDATA_cpu_peri(AXI_PERIPH.WDATA),
    .WSTRB_cpu_peri(AXI_PERIPH.WSTRB),
    .WLAST_cpu_peri(AXI_PERIPH.WLAST),
    .WVALID_cpu_peri(AXI_PERIPH.WVALID),
    .WREADY_cpu_peri(AXI_PERIPH.WREADY),
    .BID_cpu_peri(AXI_PERIPH.BID),
    .BRESP_cpu_peri(AXI_PERIPH.BRESP),
    .BVALID_cpu_peri(AXI_PERIPH.BVALID),
    .BREADY_cpu_peri(AXI_PERIPH.BREADY),
    .ARID_cpu_peri(AXI_PERIPH.ARID),
    .ARADDR_cpu_peri(AXI_PERIPH.ARADDR),
    .ARLEN_cpu_peri(AXI_PERIPH.ARLEN),
    .ARSIZE_cpu_peri(AXI_PERIPH.ARSIZE),
    .ARBURST_cpu_peri(AXI_PERIPH.ARBURST),
    .ARLOCK_cpu_peri(AXI_PERIPH.ARLOCK),
    .ARCACHE_cpu_peri(AXI_PERIPH.ARCACHE),
    .ARPROT_cpu_peri(AXI_PERIPH.ARPROT),
    .ARVALID_cpu_peri(AXI_PERIPH.ARVALID),
    .ARREADY_cpu_peri(AXI_PERIPH.ARREADY),
    .RID_cpu_peri(AXI_PERIPH.RID),
    .RDATA_cpu_peri(AXI_PERIPH.RDATA),
    .RRESP_cpu_peri(AXI_PERIPH.RRESP),
    .RLAST_cpu_peri(AXI_PERIPH.RLAST),
    .RVALID_cpu_peri(AXI_PERIPH.RVALID),
    .RREADY_cpu_peri(AXI_PERIPH.RREADY),

    .clk0clk(CLK),
    .clk0clken(1'b1),
    .clk0resetn(PORESETn)
);

millisoc_peripheral_subsystem u_rx_periphs(
    .PCLK(CLK),
    .PRESETn(SYSRESETn),
    .HCLK(CLK),
    .HRESETn(SYSRESETn),
    .RT_CLK(),

    .PERIPH_AHB(PERIPH_AHB),
    .MHU_REC(MHU_REC),
    .MHU_SND(MHU_SND),

    .UARTRXD0(UARTRXD0),
    .UARTTXD0(UARTTXD0),
    .UARTTXEN0(UARTTXEN0),
    .UARTRXD1(UARTRXD1),
    .UARTTXD1(UARTTXD1),
    .UARTTXEN1(UARTTXEN1),
    .p0_in(p0_in),
    .p0_out(p0_out),
    .p0_en(p0_en),
    .p0_func(p0_func),
    .p1_in(p1_in),
    .p1_out(p1_out),
    .p1_en(p1_en),
    .p1_func(p1_func),
    .SPI_SSn(SPI_SSn),
    .SPI_SCLK(SPI_SCLK),
    .SPI_MOSI(SPI_MOSI),
    .SPI_MISO(SPI_MISO),
    .WDOGRESREQ(WDOGRESREQ),
    .PERI_IRQS(PERI_IRQS)
);

endmodule
