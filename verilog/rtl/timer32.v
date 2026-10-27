`default_nettype none

module timer32 (
    input  wire        clk,
    input  wire        rst,
    input  wire        enable,
    input  wire [31:0] reload,
    output reg  [31:0] count,
    output reg         done
);

    always @(posedge clk) begin
        if (rst) begin
            count <= 32'd0;
            done  <= 1'b0;
        end else begin
            done <= 1'b0;

            if (enable) begin
                if (count >= reload) begin
                    count <= 32'd0;
                    done  <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

endmodule

`default_nettype wire
