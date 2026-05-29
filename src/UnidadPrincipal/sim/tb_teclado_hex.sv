`timescale 1ns/1ps

module tb_teclado_hex;

    logic clk;
    logic rst;
    logic scan_tick;
    logic [3:0] rows_async;
    logic [3:0] cols;
    logic key_valid;
    logic [3:0] key_code;

    int errores;
    int pruebas;

    teclado_hex dut (
        .clk        (clk),
        .rst        (rst),
        .scan_tick  (scan_tick),
        .rows_async (rows_async),
        .cols       (cols),
        .key_valid  (key_valid),
        .key_code   (key_code)
    );

    initial begin
        $dumpfile("tb_teclado_hex.vcd");
        $dumpvars(0, tb_teclado_hex);
    end

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        scan_tick = 0;
        forever begin
            repeat (9) @(posedge clk);
            @(posedge clk);
            scan_tick = 1'b1;
            @(posedge clk);
            scan_tick = 1'b0;
        end
    end

    initial rows_async = 4'b1111;

    // -----------------------------------------------------------------------
    // Task: probar_celda
    // Sin return ni fork/join_any (no soportados en vvp).
    // Usa @(cols) para detectar el cambio de columna y un contador
    // manual para el timeout de key_valid.
    // -----------------------------------------------------------------------
    task automatic probar_celda(
        input logic [3:0] col_pattern,
        input logic [3:0] row_pattern,
        input logic [3:0] esperado,
        input string      nombre
    );
        integer ciclos;
        logic   detectado;
        logic   col_ok;

        pruebas++;

        // 1. Esperar que cols llegue al patron deseado usando @(cols)
        col_ok = 1'b0;
        ciclos = 0;
        while (!col_ok && ciclos < 1000) begin
            if (cols === col_pattern)
                col_ok = 1'b1;
            else begin
                @(cols);
                ciclos = ciclos + 1;
            end
        end

        if (!col_ok) begin
            $display("TIMEOUT COL tecla %s: cols nunca llego a %b",
                     nombre, col_pattern);
            errores++;
            // No hacemos return: continuamos con rows en alto para no bloquear
            rows_async = 4'b1111;
            repeat (250) @(posedge clk);
        end else begin
            // 2. Bajar fila (modulo en fase DRIVE de esta columna)
            rows_async = row_pattern;

            // 3. Esperar key_valid con contador manual
            detectado = 1'b0;
            ciclos    = 0;
            while (!detectado && ciclos < 400) begin
                @(posedge clk);
                ciclos = ciclos + 1;
                if (key_valid === 1'b1)
                    detectado = 1'b1;
            end

            // 4. Verificar
            if (!detectado) begin
                $display("TIMEOUT tecla %s: key_valid nunca se activo", nombre);
                errores++;
            end else if (key_code === esperado) begin
                $display("OK    tecla %s: obtenido = %h", nombre, key_code);
            end else begin
                $display("ERROR tecla %s: esperado = %h, obtenido = %h",
                         nombre, esperado, key_code);
                errores++;
            end

            // 5. Soltar tecla
            @(posedge clk);
            rows_async = 4'b1111;

            // 6. Esperar liberacion de locked (2 barridos completos ~ 250 ciclos)
            repeat (250) @(posedge clk);
        end

    endtask

    // -----------------------------------------------------------------------
    // Secuencia de pruebas
    // -----------------------------------------------------------------------
    initial begin
        errores = 0;
        pruebas = 0;

        rst        = 1'b1;
        rows_async = 4'b1111;

        repeat (20) @(posedge clk);
        rst = 1'b0;
        repeat (200) @(posedge clk);

        $display("======================================");
        $display("TESTBENCH teclado_hex");
        $display("       COL0   COL1   COL2   COL3");
        $display("ROW0    1      2      3      A");
        $display("ROW1    4      5      6      B");
        $display("ROW2    7      8      9      C");
        $display("ROW3    *=E    0      #=F    D");
        $display("======================================");

        probar_celda(4'b1110, 4'b1110, 4'h1, "1");
        probar_celda(4'b1101, 4'b1110, 4'h2, "2");
        probar_celda(4'b1011, 4'b1110, 4'h3, "3");
        probar_celda(4'b0111, 4'b1110, 4'hA, "A");

        probar_celda(4'b1110, 4'b1101, 4'h4, "4");
        probar_celda(4'b1101, 4'b1101, 4'h5, "5");
        probar_celda(4'b1011, 4'b1101, 4'h6, "6");
        probar_celda(4'b0111, 4'b1101, 4'hB, "B");

        probar_celda(4'b1110, 4'b1011, 4'h7, "7");
        probar_celda(4'b1101, 4'b1011, 4'h8, "8");
        probar_celda(4'b1011, 4'b1011, 4'h9, "9");
        probar_celda(4'b0111, 4'b1011, 4'hC, "C");

        probar_celda(4'b1110, 4'b0111, 4'hE, "*");
        probar_celda(4'b1101, 4'b0111, 4'h0, "0");
        probar_celda(4'b1011, 4'b0111, 4'hF, "#");
        probar_celda(4'b0111, 4'b0111, 4'hD, "D");

        repeat (20) @(posedge clk);

        $display("======================================");
        if (errores == 0)
            $display("TODAS LAS PRUEBAS PASARON: %0d/%0d", pruebas, pruebas);
        else
            $display("FALLARON %0d DE %0d PRUEBAS", errores, pruebas);
        $display("======================================");

        $finish;
    end

endmodule