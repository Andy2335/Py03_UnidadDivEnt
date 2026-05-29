`timescale 1ns/1ps

module display_4dig_mux_tb;

    // =========================================================
    // Señales
    // =========================================================
    logic clk;
    logic rst;
    logic [3:0] d0;   // unidades
    logic [3:0] d1;   // decenas
    logic [3:0] d2;   // centenas
    logic [3:0] d3;   // millares
    logic [6:0] seg;
    logic [3:0] dig;

    integer u, de, c, m;
    integer numero_decimal;

    // =========================================================
    // Instancia del DUT
    // =========================================================
    display_4dig_mux #(
        .CLK_FREQ(1000),
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

    // =========================================================
    // VCD
    // =========================================================
    initial begin
        $dumpfile("display_4dig_mux.vcd");
        $dumpvars(0, display_4dig_mux_tb);
    end

    // =========================================================
    // Cálculo del número representado
    // =========================================================
    always_comb begin
        numero_decimal = d3*1000 + d2*100 + d1*10 + d0;
    end

    // =========================================================
    // Encabezado
    // =========================================================
    initial begin
        $display("-----------------------------------------------------------------------------------------");
        $display("Tiempo | rst | d3 d2 d1 d0 | Numero | dig   | seg      | Display activo");
        $display("-----------------------------------------------------------------------------------------");
    end

    // =========================================================
    // Monitor
    // =========================================================
    always @(d0 or d1 or d2 or d3 or dig or seg or rst) begin
        $write("%0t |  %b  |  %0d  %0d  %0d  %0d | %04d   | %b | %b | ",
               $time, rst, d3, d2, d1, d0, numero_decimal, dig, seg);

        case (dig)
            4'b0001: $display("Unidades");
            4'b0010: $display("Decenas");
            4'b0100: $display("Centenas");
            4'b1000: $display("Millares");
            default: $display("Ninguno o invalido");
        endcase
    end

    // =========================================================
    // Prueba exhaustiva
    // =========================================================
    initial begin
        rst = 1;
        d0  = 0;
        d1  = 0;
        d2  = 0;
        d3  = 0;

        #20;
        rst = 0;

        for (m = 0; m < 10; m = m + 1) begin
            for (c = 0; c < 10; c = c + 1) begin
                for (de = 0; de < 10; de = de + 1) begin
                    for (u = 0; u < 10; u = u + 1) begin
                        d3 = m;
                        d2 = c;
                        d1 = de;
                        d0 = u;
                        #300;
                    end
                end
            end
        end

        $display("==========================================");
        $display("Se probaron todas las combinaciones 0000-9999");
        $display("==========================================");

        $finish;
    end

endmodule