module top(
    input  logic       clk27,
    input  logic       rst_n,
    input  logic [3:0] keypad_rows,
    output logic [3:0] keypad_cols,
    output logic [6:0] seg,
    output logic [3:0] dig
);

    logic rst;

    reset_inicio #(
        .CICLOS(5_000_000)
    ) u_reset_inicio (
        .clk   (clk27),
        .rst_n (rst_n),
        .rst   (rst)
    );

    logic scan_tick;

    generador_tick #(
        .DIV(54000)
    ) u_tick (
        .clk  (clk27),
        .rst  (rst),
        .tick (scan_tick)
    );

    logic       key_valid;
    logic [3:0] key_code;

    teclado_hex u_teclado (
        .clk        (clk27),
        .rst        (rst),
        .scan_tick  (scan_tick),
        .rows_async (keypad_rows),
        .cols       (keypad_cols),
        .key_valid  (key_valid),
        .key_code   (key_code)
    );

    logic limpiar_fsm;
    logic cargar_a_fsm;
    logic cargar_b_fsm;
    logic borrar_a_fsm;
    logic borrar_b_fsm;

    logic valid_division;
    logic done_division;

    logic error_division;
    logic sel_resultado;
    logic [1:0] seleccion_display;

    logic [5:0] numero_a;
    logic [3:0] numero_b;

    logic [5:0] cociente;
    logic [3:0] residuo;

    logic [5:0] numero_display;
    logic       display_error;

    logic [1:0] cantidad_a;
    logic [1:0] cantidad_b;

    logic a_lleno;
    logic b_lleno;

    logic a_es_cero;
    logic b_es_cero;

    control_entrada_fsm u_control (
        .clk   (clk27),
        .rst   (rst),

        .key_valid (key_valid),
        .key_code  (key_code),

        .a_lleno   (a_lleno),
        .b_lleno   (b_lleno),
        .b_es_cero (b_es_cero),

        .done      (done_division),

        .limpiar   (limpiar_fsm),
        .cargar_a  (cargar_a_fsm),
        .cargar_b  (cargar_b_fsm),
        .borrar_a  (borrar_a_fsm),
        .borrar_b  (borrar_b_fsm),
        .valid     (valid_division),

        .error             (error_division),
        .sel_resultado     (sel_resultado),
        .seleccion_display (seleccion_display)
    );

    logic es_digito;
    assign es_digito = (key_code[3] == 1'b0) ||
                       (key_code == 4'd8)     ||
                       (key_code == 4'd9);

    logic limpiar_directo;
    logic cargar_a_directo;
    logic cargar_b_directo;
    logic borrar_a_directo;
    logic borrar_b_directo;

    assign limpiar_directo  = key_valid && ((key_code == 4'hC) || (key_code == 4'hD));
    assign cargar_a_directo = key_valid && es_digito && (seleccion_display == 2'd0);
    assign cargar_b_directo = key_valid && es_digito && (seleccion_display == 2'd1);
    assign borrar_a_directo = key_valid && (key_code == 4'hB) && (seleccion_display == 2'd0);
    assign borrar_b_directo = key_valid && (key_code == 4'hB) && (seleccion_display == 2'd1);

    constructor_numero #(
        .WIDTH       (6),
        .MAX_DIGITOS (2),
        .MAX_VAL     (63)
    ) u_numero_a (
        .clk           (clk27),
        .rst           (rst),
        .limpiar       (limpiar_directo),
        .cargar_digito (cargar_a_directo),
        .borrar        (borrar_a_directo),
        .digito        (key_code),
        .numero           (numero_a),
        .cantidad_digitos (cantidad_a),
        .lleno            (a_lleno),
        .es_cero          (a_es_cero)
    );

    constructor_numero #(
        .WIDTH       (4),
        .MAX_DIGITOS (2),
        .MAX_VAL     (15)
    ) u_numero_b (
        .clk           (clk27),
        .rst           (rst),
        .limpiar       (limpiar_directo),
        .cargar_digito (cargar_b_directo),
        .borrar        (borrar_b_directo),
        .digito        (key_code),
        .numero           (numero_b),
        .cantidad_digitos (cantidad_b),
        .lleno            (b_lleno),
        .es_cero          (b_es_cero)
    );

    subsistema_division u_div (
        .clk      (clk27),
        .rst      (rst),
        .A        (numero_a),
        .B        (numero_b),
        .valid    (valid_division),
        .cociente (cociente),
        .residuo  (residuo),
        .done     (done_division)
    );

    selector_numero_display u_selector_display (
        .seleccion_display (seleccion_display),
        .sel_resultado     (sel_resultado),
        .numero_a          (numero_a),
        .numero_b          (numero_b),
        .cociente          (cociente),
        .residuo           (residuo),
        .numero_display    (numero_display),
        .display_error     (display_error)
    );

    logic [10:0] bin_bcd;
    assign bin_bcd = (display_error || error_division || 
                     (b_es_cero && seleccion_display == 2'd2))
                   ? 6'd0
                   : numero_display;

    logic [3:0] d0, d1, d2, d3;

    binario_a_bcd_fsm u_bcd (
        .clk (clk27),
        .rst (rst),
        .bin (bin_bcd),
        .d0  (d0),
        .d1  (d1),
        .d2  (d2),
        .d3  (d3)
    );

    display_4dig_mux #(
        .CLK_FREQ     (27000000),
        .REFRESH_HZ   (1000),
        .COMMON_ANODE (0)
    ) u_display (
        .clk (clk27),
        .rst (rst),
        .d0  (d0),
        .d1  (d1),
        .d2  (d2),
        .d3  (d3),
        .seg (seg),
        .dig (dig)
    );

endmodule