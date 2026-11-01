

module SRAM #(
  parameter ADDR_WIDTH = 20
) (
    input  wire           clk,
    input  wire [ADDR_WIDTH-1:0]    memaddr,
    input  wire [63:0]    memd,
    output wire [63:0]    memq,
    input  wire           memcen,
    input  wire [7:0]     memwen
);

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram0 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[7:0]),
      .dout(memq[7:0])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram1 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[15:8]),
      .dout(memq[15:8])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram2 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[23:16]),
      .dout(memq[23:16])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram3 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[31:24]),
      .dout(memq[31:24])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram4 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[39:32]),
      .dout(memq[39:32])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram5 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[47:40]),
      .dout(memq[47:40])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram6 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[55:48]),
      .dout(memq[55:48])
  );

  spram #(.ADDR_WIDTH(ADDR_WIDTH-2),
  .DATA_WIDTH(8)) u_sram7 (
      .clk(clk),
      .cs(~memcen),
      .we(~memwen[0]),
      .addr(memaddr[ADDR_WIDTH-1:2]),
      .din(memd[63:56]),
      .dout(memq[63:56])
  );


endmodule
