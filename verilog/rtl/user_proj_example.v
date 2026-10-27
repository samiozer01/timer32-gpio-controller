`default_nettype none

module user_proj_example #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif

    input wb_clk_i,
    input wb_rst_i,

    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    input [127:0] la_data_in,
    output [127:0] la_data_out,
    input [127:0] la_oenb,

    input [BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,

    output [2:0] irq
);

    wire [31:0] gpio_in;
    wire [31:0] gpio_out;
    wire [31:0] gpio_oeb;
    wire timer_irq;

    assign gpio_in = {{(32-BITS){1'b0}}, io_in};

    assign io_out = gpio_out[BITS-1:0];
    assign io_oeb = gpio_oeb[BITS-1:0];

    assign irq = {2'b00, timer_irq};

    // Logic Analyzer interface is retained for Caravel compatibility.
    assign la_data_out = 128'b0;

    timer_gpio_controller u_controller (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .gpio_oeb(gpio_oeb),
        .irq(timer_irq)
    );

endmodule

`default_nettype wire
