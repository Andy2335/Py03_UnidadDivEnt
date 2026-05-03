`timescale 1ns/1ps

module tb_top;

    logic        clk27;
    logic        rst_n;
    logic [3:0]  keypad_rows;
    logic [3:0]  keypad_cols;
    logic [6:0]  seg;
    logic [3:0]  dig;

    int errores;

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------
    top dut (
        .clk27       (clk27),
        .rst_n       (rst_n),
        .keypad_rows (keypad_rows),
        .keypad_cols (keypad_cols),
        .seg         (seg),
        .dig         (dig)
    );

    //--------------------------------------------------
    // Acelerar simulación.
    //--------------------------------------------------
    defparam dut.u_tick.DIV = 16;
    defparam dut.u_reset_inicio.CICLOS = 50;

    //--------------------------------------------------

    //--------------------------------------------------
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
    end

    //--------------------------------------------------
    // Clock 27 MHz aprox
    //--------------------------------------------------
    initial clk27 = 0;
    always #18 clk27 = ~clk27;

    //--------------------------------------------------
    // Modelo del teclado matricial
    //--------------------------------------------------
    logic        pressing;
    logic [1:0]  press_col_idx;
    logic [1:0]  press_row_idx;

    always_comb begin
        keypad_rows = 4'b1111;

        if (pressing) begin
            case (press_col_idx)
                2'd0: if (keypad_cols == 4'b1110) keypad_rows[press_row_idx] = 1'b0;
                2'd1: if (keypad_cols == 4'b1101) keypad_rows[press_row_idx] = 1'b0;
                2'd2: if (keypad_cols == 4'b1011) keypad_rows[press_row_idx] = 1'b0;
                2'd3: if (keypad_cols == 4'b0111) keypad_rows[press_row_idx] = 1'b0;
                default: ;
            endcase
        end
    end

    //--------------------------------------------------
    // Presionar una tecla rápido
    //--------------------------------------------------
    task automatic presionar_tecla(
        input logic [1:0] col_idx,
        input logic [1:0] row_idx,
        input string      nombre
    );
        int timeout;
        begin
            repeat (30) @(posedge clk27);

            press_col_idx = col_idx;
            press_row_idx = row_idx;
            pressing      = 1'b1;

            timeout = 0;
            while (dut.key_valid !== 1'b1 && timeout < 3000) begin
                @(posedge clk27);
                timeout++;
            end

            if (timeout >= 3000) begin
                $display("  TIMEOUT tecla '%s' col=%0d row=%0d", nombre, col_idx, row_idx);
                errores++;
            end

            // Mantener un poco presionada
            repeat (80) @(posedge clk27);

            // Soltar
            pressing = 1'b0;

            // Esperar desbloqueo del teclado
            repeat (600) @(posedge clk27);
        end
    endtask

    //--------------------------------------------------
    // Mapa de dígitos
    //--------------------------------------------------
    task automatic presionar_digito(input int d);
        begin
            case (d)
                0: presionar_tecla(2'd1, 2'd3, "0");
                1: presionar_tecla(2'd0, 2'd0, "1");
                2: presionar_tecla(2'd1, 2'd0, "2");
                3: presionar_tecla(2'd2, 2'd0, "3");
                4: presionar_tecla(2'd0, 2'd1, "4");
                5: presionar_tecla(2'd1, 2'd1, "5");
                6: presionar_tecla(2'd2, 2'd1, "6");
                7: presionar_tecla(2'd0, 2'd2, "7");
                8: presionar_tecla(2'd1, 2'd2, "8");
                9: presionar_tecla(2'd2, 2'd2, "9");
                default: begin
                    $display("  ERROR digito invalido: %0d", d);
                    errores++;
                end
            endcase
        end
    endtask

    //--------------------------------------------------
    // Teclas especiales
    //--------------------------------------------------
    task automatic presionar_suma();
        begin
            presionar_tecla(2'd0, 2'd3, "*");
        end
    endtask

    task automatic presionar_igual();
        begin
            presionar_tecla(2'd2, 2'd3, "#");
        end
    endtask

    task automatic limpiar();
        begin
            presionar_tecla(2'd3, 2'd2, "C");
            repeat (100) @(posedge clk27);
        end
    endtask

    //--------------------------------------------------
    // Escribir número decimal de 0 a 999
    //--------------------------------------------------
    task automatic escribir_numero(input int n);
        int c;
        int d;
        int u;
        begin
            if (n == 0) begin
                presionar_digito(0);
            end else begin
                c = n / 100;
                d = (n / 10) % 10;
                u = n % 10;

                if (c != 0) begin
                    presionar_digito(c);
                    presionar_digito(d);
                    presionar_digito(u);
                end else if (d != 0) begin
                    presionar_digito(d);
                    presionar_digito(u);
                end else begin
                    presionar_digito(u);
                end
            end
        end
    endtask

    //--------------------------------------------------
    // Leer display BCD interno
    //--------------------------------------------------
    function automatic int display_a_int();
        return dut.u_bcd.d3 * 1000 +
               dut.u_bcd.d2 * 100  +
               dut.u_bcd.d1 * 10   +
               dut.u_bcd.d0;
    endfunction

    //--------------------------------------------------
    // Check
    //--------------------------------------------------
    task automatic check(
        input string nombre,
        input int obtenido,
        input int esperado
    );
        begin
            if (obtenido === esperado) begin
                $display("  OK    %-20s = %0d", nombre, obtenido);
            end else begin
                $display("  ERROR %-20s esperado=%0d obtenido=%0d",
                         nombre, esperado, obtenido);
                errores++;
            end
        end
    endtask

    //--------------------------------------------------
    // Hacer suma completa
    //--------------------------------------------------
    task automatic hacer_suma(
        input int a,
        input int b,
        input int esperado,
        input string nombre
    );
        begin
            $display("");
            $display("=== PRUEBA: %s ===", nombre);

            escribir_numero(a);
            presionar_suma();
            escribir_numero(b);
            presionar_igual();

            repeat (100) @(posedge clk27);

            check(nombre, display_a_int(), esperado);

            limpiar();
        end
    endtask

    //--------------------------------------------------
    // TEST PRINCIPAL
    //--------------------------------------------------
    initial begin
        errores       = 0;
        pressing      = 1'b0;
        press_col_idx = 2'd0;
        press_row_idx = 2'd0;

        rst_n = 1'b0;
        repeat (10) @(posedge clk27);
        rst_n = 1'b1;

        // Esperar reset_inicio acelerado
        repeat (200) @(posedge clk27);

        hacer_suma(1,   1,   2,    "1+1");
        hacer_suma(9,   9,   18,   "9+9");
        hacer_suma(123, 456, 579,  "123+456");
        hacer_suma(999, 999, 1998, "999+999");
        hacer_suma(0,   0,   0,    "0+0");
        hacer_suma(909, 9,   918,  "909+9");
        hacer_suma(199, 199, 398,  "199+199");
        hacer_suma(45,  45,  90,   "45+45");
        hacer_suma(457, 753, 1210, "457+753");
        hacer_suma(500, 0,   500,  "500+0");
        hacer_suma(90,  9,   99,   "90+9");

        $display("");
        $display("======================================");
        if (errores == 0)
            $display("TODAS LAS PRUEBAS PASARON");
        else
            $display("FALLARON %0d PRUEBAS", errores);
        $display("======================================");

        #1000;
        $finish;
    end

endmodule