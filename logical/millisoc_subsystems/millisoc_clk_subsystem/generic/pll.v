// verilog
// filepath: /home/dwn1c21/SoC-Labs/axi-chiplet-controller/logical/PHY/generic/pll.v
// ...existing code...
`timescale 1ns/1ps

module pll(
    input wire       refclk,
    input wire [3:0] pre_div,
    input wire [3:0] post_div,
    input wire       reset_n,
    output reg       clk_out
);

parameter real LOCK_TIME = 1000.0; // time units (matches `timescale)
parameter real DEFAULT_REF_PERIOD = 10.0; // ns, used until first ref measurement

// internal state
real last_ref_time = 0.0;
real ref_period = 0.0;
reg locked = 1'b0;

initial begin
    clk_out <= 1'b0;
    locked <= 1'b0;
end

// Measure incoming reference clock period (realtime in timescale units)
always @(posedge refclk) begin
    real now_time;
    now_time = $realtime;
    if (last_ref_time > 0.0) begin
        ref_period = now_time - last_ref_time;
    end
    last_ref_time = now_time;
end

// Manage lock on reset release and when reference is available
always @(posedge reset_n or negedge reset_n) begin
    if (reset_n == 1'b0) begin
        // asynchronous reset: stop output and lose lock
        locked <= 1'b0;
        clk_out <= 1'b0;
        // disable any running clock generator by forcing a named block disable
        disable clk_gen;
        disable lock_proc;
    end else begin
        // on release start lock process
        fork : lock_proc
            begin
                // wait for a measured reference period (or timeout if none)
                real wait_time;
                wait_time = 0.0;
                if (ref_period <= 0.0) begin
                    // allow one ref period timeout before using default
                    # (DEFAULT_REF_PERIOD);
                end
                // simulate locking delay
                # (LOCK_TIME);
                locked <= 1'b1;
                // start/generate output clock using parameters
                disable clk_gen; // ensure no duplicate generator
                fork : clk_gen
                    begin
                        real eff_pre, eff_post;
                        real out_freq;
                        real half_period;
                        // compute effective pre/post values (treat zero as 1)
                        eff_pre = (pre_div == 0) ? 1.0 : pre_div;
                        eff_post = (post_div == 0) ? 1.0 : post_div;
                        // formula used:
                        // output_freq = ref_freq * eff_pre / eff_post
                        // where ref_freq = 1 / ref_period
                        if (ref_period > 0.0)
                            out_freq = (1.0 / ref_period) * (eff_pre / eff_post);
                        else
                            out_freq = (1.0 / DEFAULT_REF_PERIOD) * (eff_pre / eff_post);
                        // avoid divide-by-zero
                        if (out_freq <= 0.0) out_freq = 1.0;
                        half_period = (1.0 / out_freq) / 2.0;
                        // drive clk_out
                        clk_out <= 1'b0;
                        forever begin
                            # (half_period);
                            clk_out <= ~clk_out;
                        end
                    end
                join_none
            end
        join_none
    end
end

// If pre_div/post_div change while locked, restart generator to update frequency
always @(pre_div or post_div or ref_period) begin
    if (locked) begin
        disable clk_gen;
        // small delta to let lock_proc spawn new generator
        #1;
        // re-enter lock_proc to spawn clk_gen with new params if needed
        fork : restart_spawner
            begin
                // spawn only clk_gen (do not re-delay lock)
                fork : clk_gen
                    begin
                        real eff_pre, eff_post;
                        real out_freq;
                        real half_period;
                        eff_pre = (pre_div == 0) ? 1.0 : pre_div;
                        eff_post = (post_div == 0) ? 1.0 : post_div;
                        if (ref_period > 0.0)
                            out_freq = (1.0 / ref_period) * (eff_pre / eff_post);
                        else
                            out_freq = (1.0 / DEFAULT_REF_PERIOD) * (eff_pre / eff_post);
                        if (out_freq <= 0.0) out_freq = 1.0;
                        half_period = (1.0 / out_freq) / 2.0;
                        clk_out <= 1'b0;
                        forever begin
                            # (half_period);
                            clk_out <= ~clk_out;
                        end
                    end
                join_none
            end
        join_none
    end
end

endmodule
