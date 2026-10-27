`default_nettype none

module gpio_controller (
    input  wire        clk,
    input  wire        rst,

    input  wire        write_enable,
    input  wire [1:0]  register_select,
    input  wire [31:0] write_data,

    output wire [31:0] gpio_out,
    output wire [31:0] gpio_oeb,

    output reg  [31:0] gpio_out_reg,
    output reg  [31:0] gpio_dir_reg
);

    // register_select: 0 = GPIO_OUT, 1 = GPIO_DIR
    // GPIO_OEB: 0 = output, 1 = input

    always @(posedge clk) begin
        if (rst) begin
            gpio_out_reg <= 32'b0;
            gpio_dir_reg <= 32'b0;
        end else if (write_enable) begin
            case (register_select)
                2'd0: gpio_out_reg <= write_data;
                2'd1: gpio_dir_reg <= write_data;
                default: begin
                end
            endcase
        end
    end

    assign gpio_out = gpio_out_reg;
    assign gpio_oeb = ~gpio_dir_reg;

endmodule

`default_nettype wire
