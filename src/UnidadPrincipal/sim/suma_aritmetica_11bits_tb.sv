`timescale 1ns/1ps

module suma_aritmetica_11bits_tb;

    // Señales del testbench
    logic        clk;
    logic        rst;
    logic [10:0] dato_a;
    logic [10:0] dato_b;
    logic [10:0] resultado;
    logic        overflow;

    // Variables auxiliares
    integer i;
    integer j;
    integer errores;
    logic [11:0] suma_esperada;

    // Instancia del módulo bajo prueba
    suma_aritmetica_11bits dut (
        .clk       (clk),
        .rst       (rst),
        .dato_a    (dato_a),
        .dato_b    (dato_b),
        .resultado (resultado),
        .overflow  (overflow)
    );

    // Generación del reloj
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;   // Periodo de 10 ns
    end

    // Pruebas
    initial begin
        errores = 0;

        // Valores iniciales
        rst    = 1'b1;
        dato_a = 11'd0;
        dato_b = 11'd0;

        // Mantener reset activo unos ciclos
        repeat (3) @(posedge clk);

        rst = 1'b0;

        @(posedge clk);

        // Recorrer todas las combinaciones desde 0+0 hasta 999+999
        for (i = 0; i <= 999; i = i + 1) begin
            for (j = 0; j <= 999; j = j + 1) begin

                dato_a = i[10:0];
                dato_b = j[10:0];

                // Esperar flanco de reloj porque el módulo registra la salida
                @(posedge clk);
                #1;

                suma_esperada = i + j;

                if (resultado !== suma_esperada[10:0] || overflow !== suma_esperada[11]) begin
                    $display("ERROR: %0d + %0d", i, j);
                    $display("Esperado: resultado = %0d, overflow = %b",
                              suma_esperada[10:0], suma_esperada[11]);
                    $display("Obtenido : resultado = %0d, overflow = %b",
                              resultado, overflow);
                    errores = errores + 1;
                end

            end
        end

        // Resultado final de la simulación
        if (errores == 0) begin
            $display("SIMULACION EXITOSA: todas las sumas de 0+0 hasta 999+999 fueron correctas.");
        end else begin
            $display("SIMULACION FINALIZADA CON %0d ERRORES.", errores);
        end

        $finish;
    end

endmodule