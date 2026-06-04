/*
    Instituto Tecnológico de Costa Rica
    Curso: Diseño Lógico.

    Proyecto 03 - Unidad de división entera con teclado y display
    Integrantes:
    - [Mariana Solano Gutiérrez] - [2023090199]
    - [Andrés Obregón López] - [2022072248]
    - [Mariana Guerrero Morales] - [Carné 3]


    Módulo top que integra los componentes del sistema:
    - Generación de reset interno seguro
    - Generación de tick para escaneo del teclado
    - Control y lectura del teclado hexadecimal
    - Logica de control para la entrada de datos y cálculo
    - Constructor de números a partir de los dígitos ingresados
    - Subsistema de división entera (Dividendo, divisor, cociente, residuo)
    - Selector del número a mostrar en el display
    - Conversor de binario a BCD para el display
    - Control del display 4 dígitos multiplexado

*/

module top(
    input  logic       clk27,
    input  logic       rst_n,
    input  logic [3:0] keypad_rows,
    output logic [3:0] keypad_cols,
    output logic [6:0] seg,
    output logic [3:0] dig
);

    //--------------------------------------------------
    // Reset interno seguro
    //--------------------------------------------------
    logic rst;

    reset_inicio #(
        .CICLOS(5_000_000)
    ) u_reset_inicio (
        .clk   (clk27),
        .rst_n (rst_n),
        .rst   (rst)
    );

    //--------------------------------------------------
    // Señales teclado
    //--------------------------------------------------
    logic scan_tick;
    logic key_valid;
    logic [3:0] key_code;

    //--------------------------------------------------
    // Señales control
    //--------------------------------------------------
    logic limpiar;
    logic cargar_a;
    logic cargar_b;
    logic borrar_a;
    logic borrar_b;

    logic valid_division;
    logic done_division;

    logic error_division;
    logic error_div0_subsistema;
    logic sel_resultado;

    logic [1:0] seleccion_display;

    //--------------------------------------------------
    // Números
    //--------------------------------------------------
    logic [5:0] numero_a;
    logic [3:0] numero_b;

    logic [5:0] cociente;
    logic [3:0] residuo;

    logic [5:0]  numero_display;
    logic [10:0] numero_display_bcd;

    logic [1:0] cantidad_a;
    logic [1:0] cantidad_b;

    logic a_lleno;
    logic b_lleno;

    logic a_es_cero;
    logic b_es_cero;

    logic display_error;

    //--------------------------------------------------
    // Dígitos BCD
    //--------------------------------------------------
    logic [3:0] d0;
    logic [3:0] d1;
    logic [3:0] d2;
    logic [3:0] d3;

    //--------------------------------------------------
    // Generador de tick para teclado
    //--------------------------------------------------
    generador_tick #(
        .DIV(54000)
    ) u_tick (
        .clk  (clk27),
        .rst  (rst),
        .tick (scan_tick)
    );

    //--------------------------------------------------
    // Teclado hexadecimal
    //--------------------------------------------------
    teclado_hex u_teclado (
        .clk        (clk27),
        .rst        (rst),
        .scan_tick  (scan_tick),
        .rows_async (keypad_rows),

        .cols       (keypad_cols),
        .key_valid  (key_valid),
        .key_code   (key_code)
    );

    //--------------------------------------------------
    // FSM de control
    //--------------------------------------------------
    control_entrada_fsm u_control (
        .clk   (clk27),
        .rst   (rst),

        .key_valid (key_valid),
        .key_code  (key_code),

        .a_lleno   (a_lleno),
        .b_lleno   (b_lleno),
        .b_es_cero (b_es_cero),

        .done      (done_division),

        .limpiar   (limpiar),
        .cargar_a  (cargar_a),
        .cargar_b  (cargar_b),
        .borrar_a  (borrar_a),
        .borrar_b  (borrar_b),
        .valid     (valid_division),

        .error             (error_division),
        .sel_resultado     (sel_resultado),
        .seleccion_display (seleccion_display)
    );

    //--------------------------------------------------
    // Constructor número A // Dividendo Máximo 63
    //--------------------------------------------------
    constructor_numero #(
        .WIDTH       (6),
        .MAX_DIGITOS (2),
        .MAX_VAL     (63)
    ) u_numero_a (
        .clk           (clk27),
        .rst           (rst),

        .limpiar       (limpiar),
        .cargar_digito (cargar_a),
        .borrar        (borrar_a),
        .digito        (key_code),

        .numero           (numero_a),
        .cantidad_digitos (cantidad_a),
        .lleno            (a_lleno),
        .es_cero          (a_es_cero)
    );

    //--------------------------------------------------
    // Constructor número B // Divisor Máximo 15
    //--------------------------------------------------
    constructor_numero #(
        .WIDTH       (4),
        .MAX_DIGITOS (2),
        .MAX_VAL     (15)
    ) u_numero_b (
        .clk           (clk27),
        .rst           (rst),

        .limpiar       (limpiar),
        .cargar_digito (cargar_b),
        .borrar        (borrar_b),
        .digito        (key_code),

        .numero           (numero_b),
        .cantidad_digitos (cantidad_b),
        .lleno            (b_lleno),
        .es_cero          (b_es_cero)
    );

    //--------------------------------------------------
    // División entera
    //--------------------------------------------------
    subsistema_division u_div (
        .clk      (clk27),
        .rst      (rst),

        .A        (numero_a),
        .B        (numero_b),
        .valid    (valid_division),

        .cociente   (cociente),
        .residuo    (residuo),
        .done       (done_division),
        .error_div0 (error_div0_subsistema)
    );

    //--------------------------------------------------
    // Selector del número a mostrar
    //--------------------------------------------------
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

    //--------------------------------------------------
    // Adaptación para BCD
    //--------------------------------------------------
    assign numero_display_bcd = (display_error || error_division || error_div0_subsistema)
                           ? 11'd0
                           : {5'd0, numero_display};

    //--------------------------------------------------
    // Conversor BCD
    //--------------------------------------------------
    binario_a_bcd_4dig u_bcd (
        .bin (numero_display_bcd),

        .d0  (d0),
        .d1  (d1),
        .d2  (d2),
        .d3  (d3)
    );

    //--------------------------------------------------
    // Display 4 dígitos
    //--------------------------------------------------
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