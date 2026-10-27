`default_nettype none

module timer_gpio_controller (
    input  wire        wb_clk_i,
    input  wire        wb_rst_i,
    input  wire        wbs_stb_i,
    input  wire        wbs_cyc_i,
    input  wire        wbs_we_i,
    input  wire [3:0]  wbs_sel_i,
    input  wire [31:0] wbs_dat_i,
    input  wire [31:0] wbs_adr_i,
    output reg         wbs_ack_o,
    output reg  [31:0] wbs_dat_o,

    input  wire [31:0] gpio_in,
    output wire [31:0] gpio_out,
    output wire [31:0] gpio_oeb,

    output wire        irq
);

    localparam ADDR_CTRL      = 6'h00;
    localparam ADDR_RELOAD    = 6'h04;
    localparam ADDR_COUNT     = 6'h08;
    localparam ADDR_STATUS    = 6'h0C;
    localparam ADDR_GPIO_OUT  = 6'h10;
    localparam ADDR_GPIO_IN   = 6'h14;
    localparam ADDR_GPIO_DIR  = 6'h18;

    reg        timer_enable;
    reg [31:0] timer_reload;
    wire [31:0] timer_count;
    wire        timer_done;

    reg [31:0] gpio_out_reg;
    reg [31:0] gpio_dir_reg;

    wire valid;
    wire [5:0] addr;

    assign valid = wbs_cyc_i && wbs_stb_i;
    assign addr = wbs_adr_i[5:0];

    assign gpio_out = gpio_out_reg;
    assign gpio_oeb = ~gpio_dir_reg;
    assign irq = timer_done;

    timer32 u_timer (
        .clk(wb_clk_i),
        .rst(wb_rst_i),
        .enable(timer_enable),
        .reload(timer_reload),
        .count(timer_count),
        .done(timer_done)
    );

    always @(posedge wb_clk_i) begin
        if (wb_rst_i) begin
            wbs_ack_o   <= 1'b0;
            wbs_dat_o   <= 32'b0;
            timer_enable <= 1'b0;
            timer_reload <= 32'd0;
            gpio_out_reg <= 32'b0;
            gpio_dir_reg <= 32'b0;
        end else begin
            wbs_ack_o <= 1'b0;

            if (valid && !wbs_ack_o) begin
                wbs_ack_o <= 1'b1;

                if (wbs_we_i) begin
                    case (addr)
                        ADDR_CTRL: begin
                            if (wbs_sel_i[0])
                                timer_enable <= wbs_dat_i[0];
                        end

                        ADDR_RELOAD: begin
                            if (wbs_sel_i[0]) timer_reload[7:0]   <= wbs_dat_i[7:0];
                            if (wbs_sel_i[1]) timer_reload[15:8]  <= wbs_dat_i[15:8];
                            if (wbs_sel_i[2]) timer_reload[23:16] <= wbs_dat_i[23:16];
                            if (wbs_sel_i[3]) timer_reload[31:24] <= wbs_dat_i[31:24];
                        end

                        ADDR_GPIO_OUT: begin
                            if (wbs_sel_i[0]) gpio_out_reg[7:0]   <= wbs_dat_i[7:0];
                            if (wbs_sel_i[1]) gpio_out_reg[15:8]  <= wbs_dat_i[15:8];
                            if (wbs_sel_i[2]) gpio_out_reg[23:16] <= wbs_dat_i[23:16];
                            if (wbs_sel_i[3]) gpio_out_reg[31:24] <= wbs_dat_i[31:24];
                        end

                        ADDR_GPIO_DIR: begin
                            if (wbs_sel_i[0]) gpio_dir_reg[7:0]   <= wbs_dat_i[7:0];
                            if (wbs_sel_i[1]) gpio_dir_reg[15:8]  <= wbs_dat_i[15:8];
                            if (wbs_sel_i[2]) gpio_dir_reg[23:16] <= wbs_dat_i[23:16];
                            if (wbs_sel_i[3]) gpio_dir_reg[31:24] <= wbs_dat_i[31:24];
                        end

                        default: begin
                        end
                    endcase
                end else begin
                    case (addr)
                        ADDR_CTRL:     wbs_dat_o <= {31'b0, timer_enable};
                        ADDR_RELOAD:   wbs_dat_o <= timer_reload;
                        ADDR_COUNT:    wbs_dat_o <= timer_count;
                        ADDR_STATUS:   wbs_dat_o <= {31'b0, timer_done};
                        ADDR_GPIO_OUT: wbs_dat_o <= gpio_out_reg;
                        ADDR_GPIO_IN:  wbs_dat_o <= gpio_in;
                        ADDR_GPIO_DIR: wbs_dat_o <= gpio_dir_reg;
                        default:       wbs_dat_o <= 32'b0;
                    endcase
                end
            end
        end
    end

endmodule

`default_nettype wire
