`timescale 1ns/1ps
 
module tb_display_4dig_mux;
 
    localparam integer SIM_CLK = 1000;
    localparam integer SIM_REF = 10;
    localparam integer CA      = 0;   // 0 = cátodo común, 1 = ánodo común
 
    logic       clk;
    logic       rst;
    logic [3:0] d0, d1, d2, d3;
    logic [6:0] seg;
    logic [3:0] dig;
 
    integer u, de, c, m;
    integer numero_decimal;
 
    display_4dig_mux #(
        .CLK_FREQ    (SIM_CLK),
        .REFRESH_HZ  (SIM_REF),
        .COMMON_ANODE(CA)
    ) dut (
        .clk(clk),
        .rst(rst),
        .d0 (d0),
        .d1 (d1),
        .d2 (d2),
        .d3 (d3),
        .seg(seg),
        .dig(dig)
    );
 
    initial clk = 0;
    always #5 clk = ~clk;
 
    initial begin
        $dumpfile("tb_display_4dig_mux.vcd");
        $dumpvars(0, tb_display_4dig_mux);
    end
 
    always_comb
        numero_decimal = d3*1000 + d2*100 + d1*10 + d0;
 
    // Monitor: imprime cada vez que el dígito activo o los segmentos cambian
    always @(dig, seg) begin
        case (dig)
            (CA ? 4'b1110 : 4'b0001):
                $display("Numero: %04d  |  dig: %b  |  seg: %b  |  Unidades  (%0d)",
                         numero_decimal, dig, seg, d0);
            (CA ? 4'b1101 : 4'b0010):
                $display("Numero: %04d  |  dig: %b  |  seg: %b  |  Decenas   (%0d)",
                         numero_decimal, dig, seg, d1);
            (CA ? 4'b1011 : 4'b0100):
                $display("Numero: %04d  |  dig: %b  |  seg: %b  |  Centenas  (%0d)",
                         numero_decimal, dig, seg, d2);
            (CA ? 4'b0111 : 4'b1000):
                $display("Numero: %04d  |  dig: %b  |  seg: %b  |  Millares  (%0d)",
                         numero_decimal, dig, seg, d3);
            default: ; // transición entre dígitos, no se imprime
        endcase
    end
 
    initial begin
        rst = 1;
        d0 = 0; d1 = 0; d2 = 0; d3 = 0;
        #20;
        rst = 0;
 
        for (m = 0; m < 10; m++) begin
            for (c = 0; c < 10; c++) begin
                for (de = 0; de < 10; de++) begin
                    for (u = 0; u < 10; u++) begin
                        d3 = m[3:0];
                        d2 = c[3:0];
                        d1 = de[3:0];
                        d0 = u[3:0];
                        #300;
                    end
                end
            end
        end
 
        $finish;
    end
 
endmodule