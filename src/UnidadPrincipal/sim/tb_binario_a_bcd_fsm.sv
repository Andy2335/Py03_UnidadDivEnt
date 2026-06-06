`timescale 1ns/1ps

module tb_binario_a_bcd_fsm;

    localparam N_BITS = 6;

    logic clk;
    logic rst;
    logic valid_i;
    logic [N_BITS-1:0] bin_i;

    logic [3:0] d0;
    logic [3:0] d1;
    logic [3:0] d2;
    logic [3:0] d3;
    logic done_o;

    // DUT 
    binario_a_bcd_fsm #(
        .N_BITS(N_BITS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .valid_i(valid_i),
        .bin_i(bin_i),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),
        .done_o(done_o)
    );

    // Clock 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Tarea para probar un número
    task convertir(input [N_BITS-1:0] valor);
    begin
        @(posedge clk);
        bin_i   <= valor;
        valid_i <= 1'b1;

        wait(done_o);

        $display("----------------------------------");
        $display("Binario = %0d", valor);
        $display("BCD = %0d%0d%0d%0d",
                 d3,d2,d1,d0);

        @(posedge clk);
        valid_i <= 1'b0;

        wait(!done_o);
    end
    endtask

    initial begin

        rst     = 1;
        valid_i = 0;
        bin_i   = 0;

        repeat(3) @(posedge clk);
        rst = 0;

        convertir(0);
        convertir(5);
        convertir(9);
        convertir(12);
        convertir(25);
        convertir(37);
        convertir(63);

        #100;

        $display("FIN DE SIMULACION");
        $finish;
    end

endmodule