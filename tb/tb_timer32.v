`timescale 1ns / 1ps

module tb_timer32;

    reg clk;
    reg rst;
    reg enable;
    reg [31:0] reload;

    wire [31:0] count;
    wire done;

    timer32 dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .reload(reload),
        .count(count),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk    = 0;
        rst    = 1;
        enable = 0;
        reload = 3;

        // Reset kontrolü
        @(posedge clk);
        #1;
        if (count !== 0 || done !== 0)
            $fatal(1, "FAIL: Reset");

        rst = 0;

        // Timer saymamalı
        repeat (2) @(posedge clk);
        #1;
        if (count !== 0)
            $fatal(1, "FAIL: Disabled timer");

        // Timer saymalı
        enable = 1;
        @(posedge clk); #1;
        if (count !== 1)
            $fatal(1, "FAIL: Count 1");

        @(posedge clk); #1;
        if (count !== 2)
            $fatal(1, "FAIL: Count 2");

        @(posedge clk); #1;
        if (count !== 3)
            $fatal(1, "FAIL: Count 3");

        // Reload=3 iken sonraki clock'ta tamamlanmalı
        @(posedge clk); #1;
        if (count !== 0 || done !== 1)
            $fatal(1, "FAIL: Timer completion");

        $display("PASS: All timer tests passed.");
        $finish;
    end

endmodule
