module spram_we #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 8) (
  input  wire                  clk,
  input  wire                  cs_i,
  input  wire [ADDR_WIDTH-1:0] addr_i,
  input  wire [DATA_WIDTH-1:0] wd_i,
  input  wire [DATA_WIDTH-1:0] we_i,
  output reg  [DATA_WIDTH-1:0] rd_o
);

  reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
  integer bit_index;

  always @(posedge clk) begin
    if (cs_i) begin
      if (|we_i) begin
        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin
          if (we_i[bit_index])
            mem[addr_i][bit_index] <= wd_i[bit_index];
        end
      end else begin
        rd_o <= mem[addr_i];
      end
    end
  end

endmodule
