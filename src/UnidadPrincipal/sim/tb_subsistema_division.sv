`timescale 1ns/1ps

module tb_subsistema_division;

    // Señales del testbench
    reg clk;
    reg rst;
    reg [5:0] A;
    reg [3:0] B;
    reg valid;

    wire [5:0] cociente;
    wire [3:0] residuo;
    wire done;

    integer errores;

    // Instancia del módulo a probar
    subsistema_division dut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .valid(valid),
        .cociente(cociente),
        .residuo(residuo),
        .done(done)
    );

    // Generador de reloj
    // Periodo = 10 ns
    always #5 clk = ~clk;

    // Tarea para probar una división
    task probar_division;
        input [5:0] entrada_A;
        input [3:0] entrada_B;
        input [5:0] esperado_cociente;
        input [3:0] esperado_residuo;

        begin
            // Poner entradas antes del flanco de subida
            @(negedge clk);
            A = entrada_A;
            B = entrada_B;
            valid = 1'b1;

            // Mantener valid activo solo un ciclo
            @(negedge clk);
            valid = 1'b0;

            // Esperar a que done se active
            wait(done == 1'b1);
            #1;

            // Verificación de resultados
            if (cociente === esperado_cociente && residuo === esperado_residuo) begin
                $display("OK: A=%0d, B=%0d -> cociente=%0d, residuo=%0d",
                         entrada_A, entrada_B, cociente, residuo);
            end else begin
                $display("ERROR: A=%0d, B=%0d", entrada_A, entrada_B);
                $display("       Esperado: cociente=%0d, residuo=%0d",
                         esperado_cociente, esperado_residuo);
                $display("       Obtenido: cociente=%0d, residuo=%0d",
                         cociente, residuo);
                errores = errores + 1;
            end

            // Esperar a que el módulo vuelva a ESPERA y done baje
            @(posedge clk);
        end
    endtask

    initial begin
        // Archivo para GTKWave
        $dumpfile("tb_subsistema_division.vcd");
        $dumpvars(0, tb_subsistema_division);

        // Inicialización
        clk = 1'b0;
        rst = 1'b1;
        A = 6'd0;
        B = 4'd0;
        valid = 1'b0;
        errores = 0;

        // Reset inicial
        #20;
        rst = 1'b0;

        $display("Iniciando pruebas del subsistema_division...");

        // Pruebas normales
        probar_division(6'd20, 4'd4,  6'd5,  4'd0);  // 20 / 4 = 5 residuo 0
        probar_division(6'd25, 4'd4,  6'd6,  4'd1);  // 25 / 4 = 6 residuo 1
        probar_division(6'd63, 4'd15, 6'd4,  4'd3);  // 63 / 15 = 4 residuo 3
        probar_division(6'd7,  4'd2,  6'd3,  4'd1);  // 7 / 2 = 3 residuo 1
        probar_division(6'd0,  4'd5,  6'd0,  4'd0);  // 0 / 5 = 0 residuo 0

        // Prueba de división por cero
        probar_division(6'd30, 4'd0,  6'b111111, 4'd0);

        // Resultado final
        if (errores == 0) begin
            $display("Todas las pruebas pasaron correctamente.");
        end else begin
            $display("Cantidad de errores: %0d", errores);
        end

        #20;
        $finish;
    end

endmodule