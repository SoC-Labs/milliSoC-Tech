module spram #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8) (
  input  wire                   clk,
  input  wire                   cs,
  input  wire                   we,
  input  wire [ADDR_WIDTH-1:0]  addr,
  input  wire [DATA_WIDTH-1:0]  din,
  output reg  [DATA_WIDTH-1:0]   dout
);

  reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];   // Depth follows ADDR_WIDTH

  always @(posedge clk) begin
    if (cs) begin
      if (we)
        mem[addr] <= din;        // Write
      else
        dout <= mem[addr];       // Read, registered: block RAM friendly
    end
  end

endmodule
