

module millisoc_clk_subsystem(
    input wire              refclk,
    input wire              poresetn,

    apb4_if.subordinate     CLK_APB,

    output wire             r5_clk,
    output wire             m85_clk,
    output wire             sys_clk
);

wire [3:0] pre_div;
wire [3:0] post_div;
wire       clk_out;

pll u_pll (
    .refclk(refclk),
    .pre_div(pre_div),
    .post_div(post_div),
    .reset_n(poresetn),
    .clk_out(clk_out)
);


endmodule
