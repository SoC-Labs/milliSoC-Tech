//-----------------------------------------------------------------------------
// milliSoC Peripheral Subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// Daniel Newbrook (d.newbrook@soton.ac.uk)
// 
// Copyright � 2021-4, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
// Purpose:
//  APB peripheral subsystem for SoC. Takes an APB input (subordinate port) and 
//  muxes to several peripherals including UART and timers
//-----------------------------------------------------------------------------
// Modules instantiated:
//  millisoc_peripheral_addr_decode  (u_peripheral_addr_decode)
//  cmsdk_ahb_slave_mux             (u_ahb_slave_mux_sys_bus)
//  cmsdk_ahb_default_slave         (u_ahb_default_slave_1)
//  cmsdk_ahb_gpio                  (u_cmsdk_gpio_0)
//  cmsdk_ahb_gpio                  (u_cmsdk_gpio_1)
//  cmsdk_ahb_to_apb                (u_ahb_to_apb)
//  cmsdk_apb_slave_mux             (u_apb_slave_mux)
//  cmsdk_apb_timer                 (u_apb_timer0)
//  cmsdk_apb_timer                 (u_apb_timer1)
//  cmsdk_apb_dualtimers            (u_apb_dualtimers_2)
//  cmsdk_apb_uart                  (u_apb_uart_0)
//  cmsdk_apb_uart                  (u_apb_uart_1)
//  cmsdk_apb_watchdog              (u_apb_watchdog)
//  Rtc                             (u_apb_rtc)
//  Ssp                             (u_apb_spi)
//  millisoc_peripheral_debug        (u_millisoc_peripheral_debug)

module millisoc_peripheral_subsystem #(
    parameter BE = 0 )(
    input  wire         PCLK,
    input  wire         PRESETn,
    input  wire         HCLK,
    input  wire         HRESETn,
    input  wire         RT_CLK, // 32kHz real time clock

    // Peripheral AHB bus interface
    ahb_if.subordinate     PERIPH_AHB,

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

// APB bus interface
wire [15:0] PADDR;
wire        PENABLE;
wire        PWRITE;
wire [31:0] PWDATA;
wire        PSEL;
wire [31:0] PRDATA;
wire        PREADY;
wire        PSLVERR;
wire [3:0]  PSTRB;
wire [2:0]  PPROT;
wire        APBACTIVE;

// AHB internal wires 
ahb_if #(.DATA_W(32), .ADDR_W(32)) GPIO0_AHB();
ahb_if #(.DATA_W(32), .ADDR_W(32)) GPIO1_AHB();
ahb_if #(.DATA_W(32), .ADDR_W(32)) APBSYS_AHB();


wire        defslv_hsel;   // AHB default slave signals
wire        defslv_hreadyout;
wire [31:0] defslv_hrdata;
wire        defslv_hresp;

// Internal APB signals for Timer0
wire        PSEL_TIMER0;
wire        PREADY_TIMER0;
wire [31:0] PRDATA_TIMER0;
wire        PSLVERR_TIMER0;

// Internal APB signals for Timer1
wire        PSEL_TIMER1;
wire        PREADY_TIMER1;
wire [31:0] PRDATA_TIMER1;
wire        PSLVERR_TIMER1;

// Internal APB signals for DualTimer
wire        PSEL_DUALTIMER;
wire        PREADY_DUALTIMER;
wire [31:0] PRDATA_DUALTIMER;
wire        PSLVERR_DUALTIMER;

// Internal APB signals for USRT0
wire        PSEL_USRT0;
wire        PREADY_USRT0;
wire [31:0] PRDATA_USRT0;
wire        PSLVERR_USRT0;

// Internal APB signals for USRT1
wire        PSEL_USRT1;
wire        PREADY_USRT1;
wire [31:0] PRDATA_USRT1;
wire        PSLVERR_USRT1;

// Internal APB signals for UART0
wire        PSEL_UART0;
wire        PREADY_UART0;
wire [31:0] PRDATA_UART0;
wire        PSLVERR_UART0;

// Internal APB signals for UART1
wire        PSEL_UART1;
wire        PREADY_UART1;
wire [31:0] PRDATA_UART1;
wire        PSLVERR_UART1;

// Internal APB signals for Watchdog timer
wire        PSEL_WATCHDOG;
wire        PREADY_WATCHDOG;
wire [31:0] PRDATA_WATCHDOG;
wire        PSLVERR_WATCHDOG;

// Internal APB signals for Real Time Clock
wire        PSEL_RTC;
wire        PREADY_RTC;
wire [31:0] PRDATA_RTC;
wire        PSLVERR_RTC;

// Internal APB signals for SPI
wire        PSEL_SPI;
wire        PREADY_SPI;
wire [31:0] PRDATA_SPI;
wire        PSLVERR_SPI;


// Interrupt Signals 
wire [15:0] gpio0_int;
wire        gpio0_comb_int;
wire [15:0] gpio1_int;
wire        gpio1_comb_int;
wire        timer0_int;
wire        timer1_int;
wire        dualtimer_int1;
wire        dualtimer_int2;
wire        dualtimer_int_comb;
wire        usrt0_txint;
wire        usrt0_rxint;
wire        usrt0_txovrint;
wire        usrt0_rxovrint;
wire        usrt0_combined_int;
wire        usrt1_txint;
wire        usrt1_rxint;
wire        usrt1_txovrint;
wire        usrt1_rxovrint;
wire        usrt1_combined_int;
wire        uart0_txint;
wire        uart0_rxint;
wire        uart0_txovrint;
wire        uart0_rxovrint;
wire        uart0_combined_int;
wire        uart1_txint;
wire        uart1_rxint;
wire        uart1_txovrint;
wire        uart1_rxovrint;
wire        uart1_combined_int;
wire        wdog_int;
wire        rtc_int;
wire        spi_comb_int;
wire        spi_rx_int;
wire        spi_tx_int;
wire        spi_rx_overr_int;
wire        spi_tx_to_int;

assign PERI_IRQS[0] = gpio0_comb_int;
assign PERI_IRQS[1] = gpio1_comb_int;
assign PERI_IRQS[17:2] = gpio0_int;
assign PERI_IRQS[33:18] = gpio1_int;
assign PERI_IRQS[34] = timer0_int;
assign PERI_IRQS[35] = timer1_int;
assign PERI_IRQS[36] = dualtimer_int1;
assign PERI_IRQS[37] = dualtimer_int2;
assign PERI_IRQS[38] = dualtimer_int_comb;
assign PERI_IRQS[39] = usrt0_txint;
assign PERI_IRQS[40] = usrt0_rxint;
assign PERI_IRQS[41] = usrt0_txovrint;
assign PERI_IRQS[42] = usrt0_rxovrint;
assign PERI_IRQS[43] = usrt0_combined_int;
assign PERI_IRQS[44] = usrt1_txint;
assign PERI_IRQS[45] = usrt1_rxint;
assign PERI_IRQS[46] = usrt1_txovrint;
assign PERI_IRQS[47] = usrt1_rxovrint;
assign PERI_IRQS[48] = usrt1_combined_int;
assign PERI_IRQS[49] = uart0_txint;
assign PERI_IRQS[50] = uart0_rxint;
assign PERI_IRQS[51] = uart0_txovrint;
assign PERI_IRQS[52] = uart0_rxovrint;
assign PERI_IRQS[53] = uart0_combined_int;
assign PERI_IRQS[54] = uart1_txint;
assign PERI_IRQS[55] = uart1_rxint;
assign PERI_IRQS[56] = uart1_txovrint;
assign PERI_IRQS[57] = uart1_rxovrint;
assign PERI_IRQS[58] = uart1_combined_int;
assign PERI_IRQS[59] = wdog_int;
assign PERI_IRQS[60] = rtc_int;
assign PERI_IRQS[61] = spi_comb_int;
assign PERI_IRQS[62] = spi_rx_int;
assign PERI_IRQS[63] = spi_tx_int;
assign PERI_IRQS[64] = spi_rx_overr_int;
assign PERI_IRQS[65] = spi_tx_to_int;


cmsdk_ahb_busmatrix_periph_lite u_periph_ahb_bus (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .REMAP      (4'h0), // No remap

    .HADDRs0    (PERIPH_AHB.HADDR),
    .HTRANSs0   (PERIPH_AHB.HTRANS),
    .HWRITEs0   (PERIPH_AHB.HWRITE),
    .HSIZEs0    (PERIPH_AHB.HSIZE),
    .HBURSTs0   (PERIPH_AHB.HBURST),
    .HPROTs0    (PERIPH_AHB.HPROT),
    .HWDATAs0   (PERIPH_AHB.HWDATA),
    .HMASTLOCKs0(1'b0),
    .HRDATAs0   (PERIPH_AHB.HRDATA),
    .HREADYs0   (PERIPH_AHB.HREADYOUT),
    .HRESPs0    (PERIPH_AHB.HRESP),


    .HSELm0     (APBSYS_AHB.HSEL),
    .HADDRm0    (APBSYS_AHB.HADDR),
    .HTRANSm0   (APBSYS_AHB.HTRANS),
    .HWRITEm0   (APBSYS_AHB.HWRITE),
    .HSIZEm0    (APBSYS_AHB.HSIZE),
    .HBURSTm0   (APBSYS_AHB.HBURST),
    .HPROTm0    (APBSYS_AHB.HPROT),
    .HWDATAm0   (APBSYS_AHB.HWDATA),
    .HMASTLOCKm0(),
    .HREADYMUXm0(APBSYS_AHB.HREADY),
    .HRDATAm0   (APBSYS_AHB.HRDATA),
    .HREADYOUTm0(APBSYS_AHB.HREADYOUT),
    .HRESPm0    (APBSYS_AHB.HRESP),

    .HSELm1     (GPIO0_AHB.HSEL),
    .HADDRm1    (GPIO0_AHB.HADDR),
    .HTRANSm1   (GPIO0_AHB.HTRANS),
    .HWRITEm1   (GPIO0_AHB.HWRITE),
    .HSIZEm1    (GPIO0_AHB.HSIZE),
    .HBURSTm1   (GPIO0_AHB.HBURST),
    .HPROTm1    (GPIO0_AHB.HPROT),
    .HWDATAm1   (GPIO0_AHB.HWDATA),
    .HMASTLOCKm1(),
    .HREADYMUXm1(GPIO0_AHB.HREADY),
    .HRDATAm1   (GPIO0_AHB.HRDATA),
    .HREADYOUTm1(GPIO0_AHB.HREADYOUT),
    .HRESPm1    (GPIO0_AHB.HRESP),

    .HSELm2     (GPIO1_AHB.HSEL),
    .HADDRm2    (GPIO1_AHB.HADDR),
    .HTRANSm2   (GPIO1_AHB.HTRANS),
    .HWRITEm2   (GPIO1_AHB.HWRITE),
    .HSIZEm2    (GPIO1_AHB.HSIZE),
    .HBURSTm2   (GPIO1_AHB.HBURST),
    .HPROTm2    (GPIO1_AHB.HPROT),
    .HWDATAm2   (GPIO1_AHB.HWDATA),
    .HMASTLOCKm2(),
    .HREADYMUXm2(GPIO1_AHB.HREADY),
    .HRDATAm2   (GPIO1_AHB.HRDATA),
    .HREADYOUTm2(GPIO1_AHB.HREADYOUT),
    .HRESPm2    (GPIO1_AHB.HRESP),

    .SCANENABLE (1'b0),
    .SCANINHCLK (1'b0)
);


// // Default slave
// cmsdk_ahb_default_slave u_ahb_default_slave_1 (
// .HCLK         (HCLK),
// .HRESETn      (HRESETn),
// .HSEL         (defslv_hsel),
// .HTRANS       (PERIPH_AHB.HTRANS),
// .HREADY       (PERIPH_AHB.HREADY),
// .HREADYOUT    (defslv_hreadyout),
// .HRESP        (defslv_hresp)
// );
// assign   defslv_hrdata = 32'hDEADBEEF; // Default slave do not have read data



cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK(16'hFFFF),
    .ALTERNATE_FUNC_DEFAULT(16'h0000),
    .BE(0)
) u_cmsdk_ahb_gpio_0 (
    .HCLK(HCLK),        
    .HRESETn(HRESETn),     
    .FCLK(HCLK),        
    .HSEL(GPIO0_AHB.HSEL),        
    .HREADY(GPIO0_AHB.HREADY),
    .HTRANS(GPIO0_AHB.HTRANS),
    .HSIZE(GPIO0_AHB.HSIZE),
    .HWRITE(GPIO0_AHB.HWRITE),
    .HADDR(GPIO0_AHB.HADDR[11:0]),
    .HWDATA(GPIO0_AHB.HWDATA),
    .HREADYOUT(GPIO0_AHB.HREADYOUT),
    .HRESP(GPIO0_AHB.HRESP),
    .HRDATA(GPIO0_AHB.HRDATA),

    .ECOREVNUM(4'h0),   

    .PORTIN(p0_in),   
    .PORTOUT(p0_out),     
    .PORTEN(p0_en),      
    .PORTFUNC(p0_func),   

    .GPIOINT(gpio0_int),     
    .COMBINT(gpio0_comb_int)      
);

cmsdk_ahb_gpio #(
    .ALTERNATE_FUNC_MASK(16'hFFFF),
    .ALTERNATE_FUNC_DEFAULT(16'hFFFF),
    .BE(0)
) u_cmsdk_ahb_gpio_1 (
    .HCLK(HCLK),        
    .HRESETn(HRESETn),     
    .FCLK(HCLK),        
    .HSEL(GPIO1_AHB.HSEL),        
    .HREADY(GPIO1_AHB.HREADY),
    .HTRANS(GPIO1_AHB.HTRANS),
    .HSIZE(GPIO1_AHB.HSIZE),
    .HWRITE(GPIO1_AHB.HWRITE),
    .HADDR(GPIO1_AHB.HADDR[11:0]),
    .HWDATA(GPIO1_AHB.HWDATA),
    .HREADYOUT(GPIO1_AHB.HREADYOUT),
    .HRESP(GPIO1_AHB.HRESP),
    .HRDATA(GPIO1_AHB.HRDATA),

    .ECOREVNUM(4'h0),   

    .PORTIN(p1_in),   
    .PORTOUT(p1_out),     
    .PORTEN(p1_en),      
    .PORTFUNC(p1_func),   

    .GPIOINT(gpio1_int),     
    .COMBINT(gpio1_comb_int)      
);
  // endian handling
  wire             bigendian;
  assign           bigendian = (BE!=0) ? 1'b1 : 1'b0;

  wire   [31:0]    hwdata_le; // Little endian write data
  wire   [31:0]    hrdata_le; // Little endian read data
  wire             reg_be_swap_ctrl_en = APBSYS_AHB.HSEL & APBSYS_AHB.HTRANS[1] & APBSYS_AHB.HREADY & bigendian;
  reg     [1:0]    reg_be_swap_ctrl; // registered byte swap control
  wire    [1:0]    nxt_be_swap_ctrl; // next state of byte swap control

  assign nxt_be_swap_ctrl[1] = bigendian & (APBSYS_AHB.HSIZE[1:0]==2'b10); // Swap upper and lower half word
  assign nxt_be_swap_ctrl[0] = bigendian & (APBSYS_AHB.HSIZE[1:0]!=2'b00); // Swap byte within hafword

  // Register byte swap control for data phase
  always @(posedge HCLK or negedge HRESETn)
    begin
    if (~HRESETn)
      reg_be_swap_ctrl <= 2'b00;
    else if (reg_be_swap_ctrl_en)
      reg_be_swap_ctrl <= nxt_be_swap_ctrl;
    end

  // swap byte within half word
  wire  [31:0] hwdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
     {APBSYS_AHB.HWDATA[23:16],APBSYS_AHB.HWDATA[31:24],APBSYS_AHB.HWDATA[7:0],APBSYS_AHB.HWDATA[15:8]}:
     {APBSYS_AHB.HWDATA[31:24],APBSYS_AHB.HWDATA[23:16],APBSYS_AHB.HWDATA[15:8],APBSYS_AHB.HWDATA[7:0]};
  // swap lower and upper half word
  assign       hwdata_le    = (reg_be_swap_ctrl[1] & bigendian) ?
     {hwdata_mux_1[15: 0],hwdata_mux_1[31:16]}:
     {hwdata_mux_1[31:16],hwdata_mux_1[15:0]};
  // swap byte within half word
  wire  [31:0] hrdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
     {hrdata_le[23:16],hrdata_le[31:24],hrdata_le[ 7:0],hrdata_le[15:8]}:
     {hrdata_le[31:24],hrdata_le[23:16],hrdata_le[15:8],hrdata_le[7:0]};
  // swap lower and upper half word
  assign       APBSYS_AHB.HRDATA       = (reg_be_swap_ctrl[1] & bigendian) ?
     {hrdata_mux_1[15: 0],hrdata_mux_1[31:16]}:
     {hrdata_mux_1[31:16],hrdata_mux_1[15:0]};

// AHB to APB bus bridge
cmsdk_ahb_to_apb #(
    .ADDRWIDTH      (16),
    .REGISTER_RDATA (1),
    .REGISTER_WDATA (0)
)   u_ahb_to_apb (
    // AHB side
    .HCLK     (HCLK),
    .HRESETn  (HRESETn),
    .HSEL     (APBSYS_AHB.HSEL),
    .HADDR    (APBSYS_AHB.HADDR[15:0]),
    .HTRANS   (APBSYS_AHB.HTRANS),
    .HSIZE    (APBSYS_AHB.HSIZE),
    .HPROT    (APBSYS_AHB.HPROT),
    .HWRITE   (APBSYS_AHB.HWRITE),
    .HREADY   (APBSYS_AHB.HREADY),
    .HWDATA   (hwdata_le),

    .HREADYOUT(APBSYS_AHB.HREADYOUT), // AHB Outputs
    .HRDATA   (hrdata_le),
    .HRESP    (APBSYS_AHB.HRESP),

    .PADDR    (PADDR[15:0]),
    .PSEL     (PSEL),
    .PENABLE  (PENABLE),
    .PSTRB    (PSTRB),
    .PPROT    (PPROT),
    .PWRITE   (PWRITE),
    .PWDATA   (PWDATA),

    .APBACTIVE(APBACTIVE),
    .PCLKEN   (1'b1),     // APB clock enable signal

    .PRDATA   (PRDATA),
    .PREADY   (PREADY),
    .PSLVERR  (PSLVERR)
);


// CMSDK APB Slave Mux (from Corstone 101) 
cmsdk_apb_slave_mux #(
    .PORT0_ENABLE(1),
    .PORT1_ENABLE(1),
    .PORT2_ENABLE(1),
    .PORT3_ENABLE(0),   // Was USRT, now unused
    .PORT4_ENABLE(0),   // Was USRT, now unused
    .PORT5_ENABLE(1),
    .PORT6_ENABLE(1),
    .PORT7_ENABLE(1),
    .PORT8_ENABLE(1),
    .PORT9_ENABLE(1),
    .PORT10_ENABLE(0),
    .PORT11_ENABLE(0),
    .PORT12_ENABLE(0),
    .PORT13_ENABLE(0),
    .PORT14_ENABLE(0),
    .PORT15_ENABLE(0)
    ) u_apb_slave_mux (
    .DECODE4BIT(PADDR[15:12]),
    .PSEL(PSEL),   

    .PSEL0(PSEL_TIMER0),
    .PREADY0(PREADY_TIMER0),
    .PRDATA0(PRDATA_TIMER0),
    .PSLVERR0(PSLVERR_TIMER0),

    .PSEL1(PSEL_TIMER1),
    .PREADY1(PREADY_TIMER1),
    .PRDATA1(PRDATA_TIMER1),
    .PSLVERR1(PSLVERR_TIMER1),

    .PSEL2(PSEL_DUALTIMER),
    .PREADY2(PREADY_DUALTIMER),
    .PRDATA2(PRDATA_DUALTIMER),
    .PSLVERR2(PSLVERR_DUALTIMER),

    .PSEL3(PSEL_USRT0),
    .PREADY3(PREADY_USRT0),
    .PRDATA3(PRDATA_USRT0),
    .PSLVERR3(PSLVERR_USRT0),

    .PSEL4(PSEL_USRT1),
    .PREADY4(PREADY_USRT1),
    .PRDATA4(PRDATA_USRT1),
    .PSLVERR4(PSLVERR_USRT1),

    .PSEL5(PSEL_UART0),
    .PREADY5(PREADY_UART0),
    .PRDATA5(PRDATA_UART0),
    .PSLVERR5(PSLVERR_UART0),   

    .PSEL6(PSEL_UART1),
    .PREADY6(PREADY_UART1),
    .PRDATA6(PRDATA_UART1),
    .PSLVERR6(PSLVERR_UART1),

    .PSEL7(PSEL_WATCHDOG),
    .PREADY7(PREADY_WATCHDOG),
    .PRDATA7(PRDATA_WATCHDOG),
    .PSLVERR7(PSLVERR_WATCHDOG),

    .PSEL8(PSEL_RTC),
    .PREADY8(PREADY_RTC),
    .PRDATA8(PRDATA_RTC),
    .PSLVERR8(PSLVERR_RTC),

    .PSEL9(PSEL_SPI),
    .PREADY9(PREADY_SPI),
    .PRDATA9(PRDATA_SPI),
    .PSLVERR9(PSLVERR_SPI),

    .PSEL10(),
    .PREADY10(1'b1),
    .PRDATA10(32'd0),
    .PSLVERR10(1'b1),

    .PSEL11(),
    .PREADY11(1'b1),
    .PRDATA11(32'd0),
    .PSLVERR11(1'b1),  

    .PSEL12(),
    .PREADY12(1'b1),
    .PRDATA12(32'd0),
    .PSLVERR12(1'b1),  

    .PSEL13(),
    .PREADY13(1'b1),
    .PRDATA13(32'd0),
    .PSLVERR13(1'b1),  

    .PSEL14(),
    .PREADY14(1'b1),
    .PRDATA14(32'd0),
    .PSLVERR14(1'b1),  

    .PSEL15(),
    .PREADY15(1'b1),
    .PRDATA15(32'd0),
    .PSLVERR15(1'b1),  

    .PREADY(PREADY),
    .PRDATA(PRDATA),
    .PSLVERR(PSLVERR)
);

reg [14:0] rt_clk_div;

always @(posedge RT_CLK or negedge PRESETn) begin
    if(~PRESETn)
        rt_clk_div <= 15'd0;
    else
        rt_clk_div <= rt_clk_div + 1;
end

cmsdk_apb_timer u_apb_timer0(
    .PCLK(PCLK),    // PCLK for timer operation
    .PCLKG(PCLK),   // Gated clock
    .PRESETn(PRESETn), // Reset
    .PSEL(PSEL_TIMER0),    // Device select
    .PADDR(PADDR[11:2]),   // Address
    .PENABLE(PENABLE), // Transfer control
    .PWRITE(PWRITE),  // Write control
    .PWDATA(PWDATA),  // Write data
    .ECOREVNUM(4'h0),// Engineering-change-order revision bits
    .PRDATA(PRDATA_TIMER0),  // Read data
    .PREADY(PREADY_TIMER0),  // Device ready
    .PSLVERR(PSLVERR_TIMER0), // Device error response
    .EXTIN(RT_CLK),   // Extenal input: real time clock 32.768 kHz
    .TIMERINT(timer0_int)
);

cmsdk_apb_timer u_apb_timer1(
    .PCLK(PCLK),    // PCLK for timer operation
    .PCLKG(PCLK),   // Gated clock
    .PRESETn(PRESETn), // Reset
    .PSEL(PSEL_TIMER1),    // Device select
    .PADDR(PADDR[11:2]),   // Address
    .PENABLE(PENABLE), // Transfer control
    .PWRITE(PWRITE),  // Write control
    .PWDATA(PWDATA),  // Write data
    .ECOREVNUM(4'h0),// Engineering-change-order revision bits
    .PRDATA(PRDATA_TIMER1),  // Read data
    .PREADY(PREADY_TIMER1),  // Device ready
    .PSLVERR(PSLVERR_TIMER1), // Device error response
    .EXTIN(rt_clk_div[4]),   // Extenal input: divided real time clock 1.024 kHz
    .TIMERINT(timer1_int)
);

cmsdk_apb_dualtimers u_apb_dualtimers_2 (
   // Inputs
    .PCLK              (PCLK),
    .PRESETn           (PRESETn),
    .PENABLE           (PENABLE),
    .PSEL              (PSEL_DUALTIMER),
    .PADDR             (PADDR[11:2]),
    .PWRITE            (PWRITE),
    .PWDATA            (PWDATA),

    .TIMCLK            (PCLK),
    .TIMCLKEN1         (1'b1), // simple case:the timer 0 clock always enable
    .TIMCLKEN2         (1'b1), // simple case:the timer 1 clock always enable

    .ECOREVNUM         (4'h0),// Engineering-change-order revision bits

   // Outputs
    .PRDATA            (PRDATA_DUALTIMER),

    .TIMINT1           (dualtimer_int1), // not used
    .TIMINT2           (dualtimer_int2), // not used
    .TIMINTC           (dualtimer_int_comb)
);
// When using peripherals with APB (AMBA 2.0), the PREADY and PSLVERR
// signals are not required. So we connect PREADY to 1 and PSLVERR to 0.

assign PSLVERR_DUALTIMER = 1'b0;
assign PREADY_DUALTIMER  = 1'b1;

cmsdk_apb_uart u_apb_uart_0(
    .PCLK              (PCLK),     // Peripheral clock
    .PCLKG             (PCLK),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset

    .PSEL              (PSEL_UART0),     // APB interface inputs
    .PADDR             (PADDR[11:2]),
    .PENABLE           (PENABLE),
    .PWRITE            (PWRITE),
    .PWDATA            (PWDATA),

    .PRDATA            (PRDATA_UART0),   // APB interface outputs
    .PREADY            (PREADY_UART0),
    .PSLVERR           (PSLVERR_UART0),

    .ECOREVNUM         (4'h0),// Engineering-change-order revision bits

    .RXD               (UARTRXD0),      // Receive data

    .TXD               (UARTTXD0),      // Transmit data
    .TXEN              (UARTTXEN0),     // Transmit Enabled

    .BAUDTICK          (),   // Baud rate x16 tick output (for testing)

    .TXINT             (uart0_txint),       // Transmit Interrupt
    .RXINT             (uart0_rxint),       // Receive  Interrupt
    .TXOVRINT          (uart0_txovrint),    // Transmit Overrun Interrupt
    .RXOVRINT          (uart0_rxovrint),    // Receive  Overrun Interrupt
    .UARTINT           (uart0_combined_int) // Combined Interrupt
);

cmsdk_apb_uart u_apb_uart_1(
    .PCLK              (PCLK),     // Peripheral clock
    .PCLKG             (PCLK),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset

    .PSEL              (PSEL_UART1),     // APB interface inputs
    .PADDR             (PADDR[11:2]),
    .PENABLE           (PENABLE),
    .PWRITE            (PWRITE),
    .PWDATA            (PWDATA),

    .PRDATA            (PRDATA_UART1),   // APB interface outputs
    .PREADY            (PREADY_UART1),
    .PSLVERR           (PSLVERR_UART1),

    .ECOREVNUM         (4'h0),// Engineering-change-order revision bits

    .RXD               (UARTRXD1),      // Receive data

    .TXD               (UARTTXD1),      // Transmit data
    .TXEN              (UARTTXEN1),     // Transmit Enabled

    .BAUDTICK          (),   // Baud rate x16 tick output (for testing)

    .TXINT             (uart1_txint),       // Transmit Interrupt
    .RXINT             (uart1_rxint),       // Receive  Interrupt
    .TXOVRINT          (uart1_txovrint),    // Transmit Overrun Interrupt
    .RXOVRINT          (uart1_rxovrint),    // Receive  Overrun Interrupt
    .UARTINT           (uart1_combined_int) // Combined Interrupt
);

cmsdk_apb_watchdog u_apb_watchdog(
    .PCLK(PCLK),
    .PRESETn(PRESETn),

    .PENABLE(PENABLE),
    .PSEL(PSEL_WATCHDOG),
    .PADDR(PADDR[11:2]),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),

    .WDOGCLK(PCLK),
    .WDOGCLKEN(1'b1),
    .WDOGRESn(PRESETn),

    .ECOREVNUM(4'h0),

    .PRDATA(PRDATA_WATCHDOG),

    .WDOGINT(wdog_int),
    .WDOGRES(WDOGRESREQ)
);
assign PSLVERR_WATCHDOG = 1'b0;
assign PREADY_WATCHDOG  = 1'b1;


Rtc u_apb_rtc(
    // Inputs
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL_RTC),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[11:2]),
    .PWDATA(PWDATA),
    .CLK1HZ(rt_clk_div[14]),

    .nRTCRST(PRESETn),
    .nPOR(PRESETn),
    .SCANENABLE(1'b0),
    .SCANINPCLK(PCLK),
    .SCANINCLK1HZ(rt_clk_div[14]),
    // Outputs
    .PRDATA(PRDATA_RTC),
    .RTCINTR(rtc_int),
    .SCANOUTPCLK(),
    .SCANOUTCLK1HZ()
);

assign PSLVERR_RTC = 1'b0;
assign PREADY_RTC  = 1'b1;

Ssp u_apb_spi(
// Clocks and reset
    .PCLK(PCLK), 
    .SSPCLK(PCLK), 

    .PRESETn(PRESETn),
    .nSSPRST(PRESETn),
// APB Bus
    .PSEL(PSEL_SPI),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[11:2]),
    .PWDATA(PWDATA[15:0]),
    .PRDATA(PRDATA_SPI[15:0]),

// Scan
    .SCANENABLE(1'b0),
    .SCANINPCLK(PCLK),
    .SCANINSSPCLK(PCLK),

    .SCANOUTPCLK(), 
    .SCANOUTSSPCLK(), 

// Interrupts 
    .SSPINTR(spi_comb_int), 
    .SSPRXINTR(spi_rx_int),
    .SSPTXINTR(spi_tx_int) , 
    .SSPRORINTR(spi_rx_overr_int), 
    .SSPRTINTR(spi_tx_to_int),

// To PADS
    .SSPFSSIN(1'b1), 
    .SSPCLKIN(1'b0),
    .SSPRXD(SPI_MISO), 

    .SSPFSSOUT(SPI_SSn), 
    .SSPCLKOUT(SPI_SCLK),
    .nSSPCTLOE(),
    .SSPTXD(SPI_MOSI), 
    .nSSPOE(), 

// DMA
    .SSPTXDMACLR(1'b1),
    .SSPRXDMACLR(1'b1),

    .SSPTXDMASREQ(),
    .SSPTXDMABREQ(),
    .SSPRXDMASREQ(),
    .SSPRXDMABREQ()
);

assign PREADY_SPI  = 1'b1;
assign PSLVERR_SPI = 1'b0;


endmodule
