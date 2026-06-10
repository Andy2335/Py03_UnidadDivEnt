`timescale 1ns/1ps

module tb_control_entrada;

    // ------------------------------------------------------------
    // Reloj y reset
    // ------------------------------------------------------------
    logic clk;
    logic rst_n;
    logic rst;

    initial clk = 1'b0;
    always #5 clk = ~clk;   // Periodo = 10 ns

    // Reset de inicio con pocos ciclos para simulacion
    reset_inicio #(
        .CICLOS(3)
    ) u_reset_inicio (
        .clk   (clk),
        .rst_n (rst_n),
        .rst   (rst)
    );

    // ------------------------------------------------------------
    // Senales tipo teclado
    // ------------------------------------------------------------
    logic       key_valid;
    logic [3:0] key_code;

    // ------------------------------------------------------------
    // Senales del control
    // ------------------------------------------------------------
    logic limpiar;
    logic cargar_a;
    logic cargar_b;
    logic borrar_a;
    logic borrar_b;
    logic valid;
    logic error;
    logic sel_resultado;
    logic [1:0] seleccion_display;

    // ------------------------------------------------------------
    // Numeros construidos
    // ------------------------------------------------------------
    logic [5:0] numero_a;
    logic [3:0] numero_b;

    logic [1:0] cantidad_a;
    logic [1:0] cantidad_b;

    logic a_lleno;
    logic b_lleno;
    logic a_es_cero;
    logic b_es_cero;

    // ------------------------------------------------------------
    // Resultado simulado de division
    // ------------------------------------------------------------
    logic [5:0] cociente;
    logic [3:0] residuo;
    logic       done;

    // ------------------------------------------------------------
    // Display
    // ------------------------------------------------------------
    logic [5:0] numero_display;
    logic       display_error;

    // ------------------------------------------------------------
    // DUTs
    // ------------------------------------------------------------

    control_entrada_fsm u_control (
        .clk                (clk),
        .rst                (rst),
        .key_valid          (key_valid),
        .key_code           (key_code),
        .a_lleno            (a_lleno),
        .b_lleno            (b_lleno),
        .b_es_cero          (b_es_cero),
        .done               (done),
        .limpiar            (limpiar),
        .cargar_a           (cargar_a),
        .cargar_b           (cargar_b),
        .borrar_a           (borrar_a),
        .borrar_b           (borrar_b),
        .valid              (valid),
        .error              (error),
        .sel_resultado      (sel_resultado),
        .seleccion_display  (seleccion_display)
    );

    constructor_numero #(
        .WIDTH       (6),
        .MAX_DIGITOS (2),
        .MAX_VAL     (63)
    ) u_constructor_a (
        .clk              (clk),
        .rst              (rst),
        .limpiar          (limpiar),
        .cargar_digito    (cargar_a),
        .borrar           (borrar_a),
        .digito           (key_code),
        .numero           (numero_a),
        .cantidad_digitos (cantidad_a),
        .lleno            (a_lleno),
        .es_cero          (a_es_cero)
    );

    constructor_numero #(
        .WIDTH       (4),
        .MAX_DIGITOS (1),
        .MAX_VAL     (9)
    ) u_constructor_b (
        .clk              (clk),
        .rst              (rst),
        .limpiar          (limpiar),
        .cargar_digito    (cargar_b),
        .borrar           (borrar_b),
        .digito           (key_code),
        .numero           (numero_b),
        .cantidad_digitos (cantidad_b),
        .lleno            (b_lleno),
        .es_cero          (b_es_cero)
    );

    selector_numero_display u_selector (
        .seleccion_display (seleccion_display),
        .sel_resultado     (sel_resultado),
        .numero_a          (numero_a),
        .numero_b          (numero_b),
        .cociente          (cociente),
        .residuo           (residuo),
        .numero_display    (numero_display),
        .display_error     (display_error)
    );

    // ------------------------------------------------------------
    // Modelo simple de la division.
    // Cuando el control levanta valid, este bloque calcula el
    // cociente/residuo y levanta done por un ciclo.
    // ------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cociente <= 6'd0;
            residuo  <= 4'd0;
            done     <= 1'b0;
        end else begin
            if (valid) begin
                cociente <= numero_a / numero_b;
                residuo  <= numero_a % numero_b;
                done     <= 1'b1;
            end else begin
                done     <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------
    // Utilidades del testbench
    // ------------------------------------------------------------
    int errores;

    task automatic presionar_tecla(input logic [3:0] tecla);
        begin
            @(negedge clk);
            key_code  = tecla;
            key_valid = 1'b1;

            @(negedge clk);
            key_valid = 1'b0;
            key_code  = 4'h0;

            // El constructor_numero tiene registros internos
            // cargar_r y digito_r, por eso se esperan ciclos extra.
            repeat (2) @(posedge clk);
            #1;
        end
    endtask

    task automatic verificar(input bit condicion, input string mensaje);
        begin
            if (!condicion) begin
                errores++;
                $error("FALLO: %s", mensaje);
            end else begin
                $display("OK: %s", mensaje);
            end
        end
    endtask

    task automatic mostrar_estado(input string titulo);
        begin
            $display("\n[%0t] %s", $time, titulo);
            $display("A=%0d cantA=%0d llenoA=%0b | B=%0d cantB=%0d llenoB=%0b ceroB=%0b", 
                     numero_a, cantidad_a, a_lleno, numero_b, cantidad_b, b_lleno, b_es_cero);
            $display("sel_disp=%0d sel_res=%0b display=%0d display_error=%0b valid=%0b done=%0b error=%0b", 
                     seleccion_display, sel_resultado, numero_display, display_error, valid, done, error);
        end
    endtask

    // ------------------------------------------------------------
    // Estimulos principales
    // ------------------------------------------------------------
    initial begin
        errores   = 0;
        rst_n     = 1'b0;
        key_valid = 1'b0;
        key_code  = 4'h0;

        $dumpfile("tb_control_entrada.vcd");
        $dumpvars(0, tb_control_entrada);

        // Liberar reset externo
        repeat (2) @(posedge clk);
        rst_n = 1'b1;

        // Esperar a que reset_inicio baje rst
        wait (rst == 1'b0);
        repeat (2) @(posedge clk);
        #1;

        mostrar_estado("Despues de reset");
        verificar(numero_a == 6'd0, "A inicia en 0");
        verificar(numero_b == 4'd0, "B inicia en 0");
        verificar(seleccion_display == 2'd0, "Display inicia mostrando A");
        verificar(error == 1'b0, "No hay error inicial");

        // ========================================================
        // Caso 1: Ingresar A=42, B=7, calcular 42/7
        // Teclas: 4, 2, A, 7, A
        // ========================================================
        $display("\n================ CASO 1: 42 / 7 = 6 r 0 ================");

        presionar_tecla(4'd4);
        verificar(numero_a == 6'd4, "Despues de tecla 4, A = 4");
        verificar(cantidad_a == 2'd1, "A tiene 1 digito");

        presionar_tecla(4'd2);
        verificar(numero_a == 6'd42, "Despues de tecla 2, A = 42");
        verificar(cantidad_a == 2'd2, "A tiene 2 digitos");
        verificar(a_lleno == 1'b1, "A esta lleno");

        presionar_tecla(4'd9);
        verificar(numero_a == 6'd42, "Si A esta lleno, otro digito no cambia A");

        presionar_tecla(4'hA);
        verificar(seleccion_display == 2'd1, "Con tecla A se pasa a ingreso de B");
        verificar(numero_display == 6'd0, "Al entrar a B, display muestra B=0");

        presionar_tecla(4'd7);
        verificar(numero_b == 4'd7, "Despues de tecla 7, B = 7");
        verificar(b_lleno == 1'b1, "B esta lleno con 1 digito");

        presionar_tecla(4'hA);
        mostrar_estado("Despues de calcular 42/7");
        verificar(seleccion_display == 2'd2, "Despues de calcular, display muestra resultado");
        verificar(error == 1'b0, "No hay error en 42/7");
        verificar(cociente == 6'd6, "Cociente = 6");
        verificar(residuo == 4'd0, "Residuo = 0");
        verificar(sel_resultado == 1'b0, "Por defecto se muestra cociente");
        verificar(numero_display == 6'd6, "Display muestra cociente 6");

        presionar_tecla(4'hE);
        verificar(sel_resultado == 1'b1, "Tecla E alterna a residuo");
        verificar(numero_display == 6'd0, "Display muestra residuo 0");

        presionar_tecla(4'hF);
        verificar(sel_resultado == 1'b0, "Tecla F alterna de vuelta a cociente");
        verificar(numero_display == 6'd6, "Display vuelve a mostrar cociente 6");

        // ========================================================
        // Caso 2: Limpiar con C
        // ========================================================
        $display("\n================ CASO 2: limpiar con C ================");
        presionar_tecla(4'hC);
        mostrar_estado("Despues de limpiar");
        verificar(numero_a == 6'd0, "C limpia A");
        verificar(numero_b == 4'd0, "C limpia B");
        verificar(cantidad_a == 2'd0, "C limpia cantidad de digitos de A");
        verificar(cantidad_b == 2'd0, "C limpia cantidad de digitos de B");
        verificar(seleccion_display == 2'd0, "C vuelve a ingreso de A");
        verificar(error == 1'b0, "C quita error si existia");

        // ========================================================
        // Caso 3: Borrar digitos de A
        // Teclas: 5, 6, B, B
        // ========================================================
        $display("\n================ CASO 3: borrar digitos ================");
        presionar_tecla(4'd5);
        presionar_tecla(4'd6);
        verificar(numero_a == 6'd56, "A = 56 antes de borrar");

        presionar_tecla(4'hB);
        verificar(numero_a == 6'd5, "Primer borrar deja A = 5");
        verificar(cantidad_a == 2'd1, "A queda con 1 digito");

        presionar_tecla(4'hB);
        verificar(numero_a == 6'd0, "Segundo borrar deja A = 0");
        verificar(cantidad_a == 2'd0, "A queda con 0 digitos");

        // ========================================================
        // Caso 4: Evitar valor fuera de rango A > 63
        // Teclas: C, 6, 4. El 64 no debe cargarse.
        // ========================================================
        $display("\n================ CASO 4: limite MAX_VAL de A = 63 ================");
        presionar_tecla(4'hC);
        presionar_tecla(4'd6);
        presionar_tecla(4'd4);
        verificar(numero_a == 6'd6, "A no acepta 64 porque MAX_VAL = 63");
        verificar(cantidad_a == 2'd1, "Cantidad de A se mantiene en 1 digito");

        // ========================================================
        // Caso 5: Error por division entre cero
        // Teclas: C, 1, 2, A, 0, A
        // ========================================================
        $display("\n================ CASO 5: division entre cero ================");
        presionar_tecla(4'hC);
        presionar_tecla(4'd1);
        presionar_tecla(4'd2);
        presionar_tecla(4'hA);
        presionar_tecla(4'd0);
        presionar_tecla(4'hA);
        mostrar_estado("Despues de intentar 12/0");
        verificar(error == 1'b1, "12/0 activa error");
        verificar(seleccion_display == 2'd3, "En error, seleccion_display = 3");
        verificar(display_error == 1'b1, "Selector activa display_error");

        presionar_tecla(4'hD);
        verificar(error == 1'b0, "D limpia el estado de error");
        verificar(numero_a == 6'd0, "D limpia A");
        verificar(numero_b == 4'd0, "D limpia B");
        verificar(seleccion_display == 2'd0, "D vuelve a ingreso de A");

        // --------------------------------------------------------
        // Resultado final
        // --------------------------------------------------------
        if (errores == 0) begin
            $display("\n========================================================");
            $display("TODAS LAS PRUEBAS PASARON CORRECTAMENTE");
            $display("========================================================");
        end else begin
            $display("\n========================================================");
            $display("PRUEBAS TERMINADAS CON %0d ERROR(ES)", errores);
            $display("========================================================");
        end

        $finish;
    end

endmodule
