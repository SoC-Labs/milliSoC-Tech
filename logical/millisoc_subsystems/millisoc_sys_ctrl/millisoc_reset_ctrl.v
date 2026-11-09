`default_nettype none

module millisoc_reset_ctrl(
    input  wire CLKIN,
    input  wire nPORESET,

    input  wire SYSRESETREQ,
    input  wire WATCHDOGREQ,
    input  wire DAPSYSRESETREQ,
    input  wire SW_SYSRESETREQ,
    input  wire R5_DBGRESETREQ,
    input  wire SW_R5RESETREQ,
    input  wire SW_M85RESETREQ,

    output wire nSYSRESET,
    output wire nR5RESET,
    output wire nM85RESET,
    output wire DAPSYSRESETACK
);

localparam [2:0] RESET_HOLD_CYCLES = 3'd4;

wire system_request;
wire r5_request;
wire m85_request;
wire system_request_event;
wire r5_request_event;
wire m85_request_event;

reg system_request_d;
reg r5_request_d;
reg m85_request_d;
reg [2:0] system_reset_count;
reg [2:0] r5_reset_count;
reg [2:0] m85_reset_count;
reg dap_request_seen;
reg dap_ack_pending;

assign system_request = SYSRESETREQ | WATCHDOGREQ | DAPSYSRESETREQ | SW_SYSRESETREQ;
assign r5_request = R5_DBGRESETREQ | SW_R5RESETREQ;
assign m85_request = SW_M85RESETREQ;

assign system_request_event = system_request & ~system_request_d;
assign r5_request_event = r5_request & ~r5_request_d;
assign m85_request_event = m85_request & ~m85_request_d;

assign nSYSRESET = (system_reset_count == 3'd0);
assign nR5RESET = nSYSRESET & (r5_reset_count == 3'd0);
assign nM85RESET = nSYSRESET & (m85_reset_count == 3'd0);
assign DAPSYSRESETACK = dap_ack_pending & nSYSRESET;

always @(posedge CLKIN or negedge nPORESET) begin
    if (!nPORESET) begin
        system_request_d <= 1'b0;
        r5_request_d <= 1'b0;
        m85_request_d <= 1'b0;
        system_reset_count <= RESET_HOLD_CYCLES;
        r5_reset_count <= RESET_HOLD_CYCLES;
        m85_reset_count <= RESET_HOLD_CYCLES;
        dap_request_seen <= 1'b0;
        dap_ack_pending <= 1'b0;
    end else begin
        system_request_d <= system_request;
        r5_request_d <= r5_request;
        m85_request_d <= m85_request;

        if (system_request_event)
            system_reset_count <= RESET_HOLD_CYCLES;
        else if (system_reset_count != 3'd0)
            system_reset_count <= system_reset_count - 1'b1;

        if (r5_request_event)
            r5_reset_count <= RESET_HOLD_CYCLES;
        else if (r5_reset_count != 3'd0)
            r5_reset_count <= r5_reset_count - 1'b1;

        if (m85_request_event)
            m85_reset_count <= RESET_HOLD_CYCLES;
        else if (m85_reset_count != 3'd0)
            m85_reset_count <= m85_reset_count - 1'b1;

        if (!DAPSYSRESETREQ) begin
            dap_request_seen <= 1'b0;
            dap_ack_pending <= 1'b0;
        end else if (!dap_request_seen) begin
            dap_request_seen <= 1'b1;
            dap_ack_pending <= 1'b1;
        end
    end
end

endmodule

`default_nettype wire
