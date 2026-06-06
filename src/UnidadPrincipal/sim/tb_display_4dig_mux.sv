`timescale 1ns/1ps

module tb_display_4dig_mux;

    logic clk;
    logic rst;

    logic [3:0] d0; // Unidades
    logic [3:0] d1; // Decenas
    logic [3:0] d2; // Centenas
    logic [3:0] d3; // Miles

    logic [6:0] seg;
    logic [3:0] dig;

    integer u, de, c, m;
    integer numero_decimal;

    // =========================================================
    // Instancia del DUT
    // =========================================================
    display_4dig_mux #(
        .CLK_FREQ(100),
        .REFRESH_HZ(10),
        .COMMON_ANODE(0)
    ) dut (
        .clk(clk),
        .rst(rst),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .seg(seg),
        .dig(dig)
    );

    // =========================================================
    // Reloj
    // =========================================================
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        rst = 1;

        d0 = 4'd1;
        d1 = 4'd2;
        d2 = 4'd3;
        d3 = 4'd4;

        repeat(3) @(posedge clk);
        rst = 0;

        repeat(50) begin
            @(posedge clk);

            $display(
                "t=%0t  dig=%b  seg=%b",
                $time,
                dig,
                seg
            );
        end

        $finish;
    end

endmodule
