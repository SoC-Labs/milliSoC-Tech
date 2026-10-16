
module millisoc_sys_ctrl(
    input  wire         pclk,
    input  wire         nporeset,

    apb4_if.subordinate sys_ctrl_apb,

    input  wire         sysresetreq,
    input  wire         watchdogreq,

    output wire         nsysreset,

    output reg          cpu_mx_wait
);

//Local parameter for IDs,
localparam  SYSCTRL_ID0        = {32'h00000053}; // 0xFD0 : S
localparam  SYSCTRL_ID1        = {32'h0000004C}; // 0xFD4 : L
localparam  SYSCTRL_ID2        = {32'h00000053}; // 0xFD8 : S
localparam  SYSCTRL_ID3        = {32'h00000059}; // 0xFDC : Y
localparam  SYSCTRL_ID4        = {32'h00000053}; // 0xFE0 : S
localparam  SYSCTRL_ID5        = {32'h00000043}; // 0xFE4 : C
localparam  SYSCTRL_ID6        = {32'h00000054}; // 0xFE8 : T
localparam  SYSCTRL_ID7        = {32'h00000052}; // 0xFEC : R
localparam  SYSCTRL_ID8        = {32'h0000004C}; // 0xFF0 : L
localparam  SYSCTRL_ID9        = {32'h0000005F}; // 0xFF4 : _
localparam  SYSCTRL_IDA        = {32'h00000056}; // 0xFF8 : V
localparam  SYSCTRL_IDB        = {32'h00000031}; // 0xFFC : 1


// APB Register interface
wire apb_read_en;
wire apb_write_en;
wire [1:0] apb_wr_sel;
reg [31:0] PRDATA;
assign sys_ctrl_apb.prdata=PRDATA;
// APB Control
assign apb_read_en = sys_ctrl_apb.psel & (~sys_ctrl_apb.pwrite);
assign apb_write_en = sys_ctrl_apb.psel & (~sys_ctrl_apb.penable) & sys_ctrl_apb.pwrite;
assign sys_ctrl_apb.pready = 1'b1; // Always ready
assign sys_ctrl_apb.pslverr = 1'b0; // Always OK

assign apb_wr_sel[0] = apb_write_en & (sys_ctrl_apb.paddr[11:2]==10'h0);
assign apb_wr_sel[1] = apb_write_en & (sys_ctrl_apb.paddr[11:2]==10'h1);

wire [1:0] next_reset_info;
wire  reg_next_reset_info_en;
assign next_reset_info[0] = sysresetreq;
assign next_reset_info[1] = watchdogreq;

assign reg_next_reset_info_en = sysresetreq | watchdogreq;

reg [1:0] reset_info;

always @(posedge pclk or negedge nporeset) begin
    if(~nporeset)
        reset_info <= 2'b00;
    else if (reg_next_reset_info_en)
        reset_info <= next_reset_info;
end

always @(posedge pclk or negedge nporeset) begin
    if(~nporeset)
        cpu_mx_wait <= 1'b1;
    else if (apb_wr_sel[1])
        cpu_mx_wait <= sys_ctrl_apb.pwdata[0];
end

always @(apb_read_en or sys_ctrl_apb.paddr or reset_info) begin
    case(apb_read_en)
        1'b1: begin
            case(sys_ctrl_apb.paddr[11:2])
                10'h000: PRDATA = {30'd0, reset_info};
                10'h001: PRDATA = {31'd0, cpu_mx_wait};
                10'h3F4: PRDATA = SYSCTRL_ID0;
                10'h3F5: PRDATA = SYSCTRL_ID1;
                10'h3F6: PRDATA = SYSCTRL_ID2;
                10'h3F7: PRDATA = SYSCTRL_ID3;
                10'h3F8: PRDATA = SYSCTRL_ID4;
                10'h3F9: PRDATA = SYSCTRL_ID5;
                10'h3FA: PRDATA = SYSCTRL_ID6;
                10'h3FB: PRDATA = SYSCTRL_ID7;
                10'h3FC: PRDATA = SYSCTRL_ID8;
                10'h3FD: PRDATA = SYSCTRL_ID9;
                10'h3FE: PRDATA = SYSCTRL_IDA;
                10'h3FF: PRDATA = SYSCTRL_IDB;
            default: PRDATA = 32'd0;
            endcase
        end
        1'b0: PRDATA = 32'd0;
        default: PRDATA = 32'd0;
    endcase
end

reg nsysreset_i;
reg [3:0] nsysreset_sync;
wire nsysreset_en;

assign nsysreset_en = (~nporeset) | watchdogreq | sysresetreq;
assign nsysreset = nsysreset_sync[3];

always @(posedge pclk or posedge nsysreset_en)begin
    if (nsysreset_en) begin
        nsysreset_i <= 1'b1;
        nsysreset_sync <= 4'h0;
    end else begin
        nsysreset_sync[3] <= nsysreset_sync[2];
        nsysreset_sync[2] <= nsysreset_sync[1];
        nsysreset_sync[1] <= nsysreset_sync[0];
        nsysreset_sync[0] <= nsysreset_i;
    end
end

endmodule
