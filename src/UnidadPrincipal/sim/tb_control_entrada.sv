`timescale 1ns/1ps

module tb_control_entrada;

    logic clk;
    logic rst;

    logic        key_valid;
    logic [3:0]  key_code;

    logic        limpiar;
    logic        cargar_a;
    logic        cargar_b;
    logic        calcular;
    logic [1:0]  seleccion_display;

    logic [10:0] numA;
    logic [10:0] numB;
    logic [1:0]  digitosA;
    logic [1:0]  digitosB;
    logic        llenoA;
    logic        llenoB;

    int errores;

    // -----------------------------------------------------------------------
    // DUT: FSM de control
    // -----------------------------------------------------------------------
    control_entrada_fsm u_control (
        .clk               (clk),
        .rst               (rst),
        .key_valid         (key_valid),
        .key_code          (key_code),
        .a_lleno           (llenoA),
        .b_lleno           (llenoB),
        .limpiar           (limpiar),
        .cargar_a          (cargar_a),
        .cargar_b          (cargar_b),
        .calcular          (calcular),
        .seleccion_display (seleccion_display)
    );

    // -----------------------------------------------------------------------
    // Constructores conectados igual que en el top
    // -----------------------------------------------------------------------
    constructor_numero u_numA (
        .clk              (clk),
        .rst              (rst),
        .limpiar          (limpiar),
        .cargar_digito    (cargar_a),
        .digito           (key_code),
        .numero           (numA),
        .cantidad_digitos (digitosA),
        .lleno            (llenoA)
    );

    constructor_numero u_numB (
        .clk              (clk),
        .rst              (rst),
        .limpiar          (limpiar),
        .cargar_digito    (cargar_b),
        .digito           (key_code),
        .numero           (numB),
        .cantidad_digitos (digitosB),
        .lleno            (llenoB)
    );

    initial begin
        $dumpfile("tb_control_entrada.vcd");
        $dumpvars(0, tb_control_entrada);
    end

    initial clk = 0;
    always #5 clk = ~clk;

    // -----------------------------------------------------------------------
    // Task: simula un pulso de key_valid de un ciclo de reloj
    // El constructor registra cargar_digito un ciclo, por lo que se espera
    // un ciclo extra antes de leer numA/numB.
    // -----------------------------------------------------------------------
    task automatic presionar_tecla(input logic [3:0] tecla);
        begin
            @(negedge clk);
            key_code  = tecla;
            key_valid = 1'b1;

            @(negedge clk);
            key_valid = 1'b0;
            key_code  = 4'h0;

            // Esperar 3 ciclos: 1 para que la FSM actualice + 1 de registro
            // en constructor_numero + 1 de margen
            repeat (3) @(negedge clk);
        end
    endtask

    // -----------------------------------------------------------------------
    // Tasks de verificacion
    // -----------------------------------------------------------------------
    task automatic verificar_numero(
        input string       nombre,
        input logic [10:0] obtenido,
        input logic [10:0] esperado
    );
        if (obtenido == esperado)
            $display("OK    %s = %0d", nombre, obtenido);
        else begin
            $display("ERROR %s: esperado = %0d, obtenido = %0d",
                     nombre, esperado, obtenido);
            errores++;
        end
    endtask

    task automatic verificar_estado(
        input string      nombre,
        input logic [1:0] obtenido,
        input logic [1:0] esperado
    );
        if (obtenido == esperado)
            $display("OK    FSM en %s (seleccion_display = %0d)", nombre, obtenido);
        else begin
            $display("ERROR FSM no esta en %s: esperado seleccion=%0d, obtenido=%0d",
                     nombre, esperado, obtenido);
            errores++;
        end
    endtask

    task automatic verificar_bit(
        input string nombre,
        input logic  obtenido,
        input logic  esperado
    );
        if (obtenido == esperado)
            $display("OK    %s = %0b", nombre, obtenido);
        else begin
            $display("ERROR %s: esperado = %0b, obtenido = %0b",
                     nombre, esperado, obtenido);
            errores++;
        end
    endtask

    // -----------------------------------------------------------------------
    // Secuencia principal
    // -----------------------------------------------------------------------
    initial begin
        errores   = 0;
        rst       = 1'b1;
        key_valid = 1'b0;
        key_code  = 4'h0;

        repeat (20) @(negedge clk);
        rst = 1'b0;
        repeat (3)  @(negedge clk);

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 1: ingreso 123 * 45 #");
        $display("(* = 4'hE confirma A, # = 4'hF calcula)");
        $display("======================================");

        presionar_tecla(4'h1);
        presionar_tecla(4'h2);
        presionar_tecla(4'h3);

        verificar_numero("numA despues de 1,2,3", numA, 11'd123);
        verificar_numero("numB antes de ingresar B", numB, 11'd0);
        verificar_estado("INGRESO_A", seleccion_display, 2'd0);

        // Tecla * (4'hE): confirma A y pasa a INGRESO_B
        presionar_tecla(4'hE);
        verificar_estado("INGRESO_B", seleccion_display, 2'd1);

        presionar_tecla(4'h4);
        presionar_tecla(4'h5);

        verificar_numero("numB despues de 4,5", numB, 11'd45);

        // Tecla # (4'hF): calcula y pasa a MOSTRAR_RESULTADO
        presionar_tecla(4'hF);
        verificar_estado("MOSTRAR_RESULTADO", seleccion_display, 2'd2);
        verificar_bit("calcular se activo", calcular, 1'b0); // ya paso, debe estar en 0

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 2: limpiar con tecla D (4'hD)");
        $display("======================================");

        presionar_tecla(4'hD);

        // El limpiar resetea los constructores; esperar el ciclo de registro
        repeat (3) @(negedge clk);

        verificar_numero("numA despues de D", numA, 11'd0);
        verificar_numero("numB despues de D", numB, 11'd0);
        verificar_estado("INGRESO_A tras D", seleccion_display, 2'd0);

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 3: limpiar con tecla C (4'hC)");
        $display("======================================");

        presionar_tecla(4'h7);
        presionar_tecla(4'h7);
        presionar_tecla(4'hE); // pasar a INGRESO_B
        presionar_tecla(4'h3);

        verificar_numero("numA antes de C", numA, 11'd77);
        verificar_numero("numB antes de C", numB, 11'd3);

        presionar_tecla(4'hC);
        repeat (3) @(negedge clk);

        verificar_numero("numA despues de C", numA, 11'd0);
        verificar_numero("numB despues de C", numB, 11'd0);
        verificar_estado("INGRESO_A tras C", seleccion_display, 2'd0);

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 4: limite de 3 digitos en A");
        $display("======================================");

        presionar_tecla(4'h9);
        presionar_tecla(4'h8);
        presionar_tecla(4'h7);
        presionar_tecla(4'h6); // debe ignorarse: A ya esta lleno

        verificar_numero("numA limitado a 3 digitos", numA, 11'd987);
        verificar_bit("a_lleno activo", llenoA, 1'b1);

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 5: # ignorado en INGRESO_A");
        $display("(calcular solo funciona desde INGRESO_B)");
        $display("======================================");

        presionar_tecla(4'hD); // limpiar
        repeat (3) @(negedge clk);

        presionar_tecla(4'h5);
        presionar_tecla(4'hF); // # en INGRESO_A: debe ignorarse
        verificar_estado("sigue en INGRESO_A", seleccion_display, 2'd0);

        // -------------------------------------------------------------------
        $display("======================================");
        $display("PRUEBA 6: operacion completa 999 + 1");
        $display("======================================");

        presionar_tecla(4'hD); // limpiar
        repeat (3) @(negedge clk);

        presionar_tecla(4'h9);
        presionar_tecla(4'h9);
        presionar_tecla(4'h9);
        presionar_tecla(4'hE);

        presionar_tecla(4'h1);
        presionar_tecla(4'hF);

        verificar_numero("numA = 999", numA, 11'd999);
        verificar_numero("numB = 1",   numB, 11'd1);
        verificar_estado("MOSTRAR_RESULTADO", seleccion_display, 2'd2);

        // -------------------------------------------------------------------
        repeat (10) @(negedge clk);

        $display("======================================");
        if (errores == 0)
            $display("TODAS LAS PRUEBAS DE CONTROL PASARON");
        else
            $display("FALLARON %0d PRUEBAS DE CONTROL", errores);
        $display("======================================");

        $finish;
    end

endmodule