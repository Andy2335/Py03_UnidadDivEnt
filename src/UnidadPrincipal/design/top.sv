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
        .clk(clk27),
        .rst_n(rst_n),
        .rst(rst)
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
    logic calcular;
    logic [1:0] seleccion_display;

    //--------------------------------------------------
    // Números
    //--------------------------------------------------
    logic [10:0] numero_a;
    logic [10:0] numero_b;
    logic [10:0] resultado;
    logic [10:0] numero_display;

    logic [1:0] cantidad_a;
    logic [1:0] cantidad_b;

    logic a_lleno;
    logic b_lleno;
    logic overflow;

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
        .clk(clk27),
        .rst(rst),
        .tick(scan_tick)
    );

    //--------------------------------------------------
    // Teclado hexadecimal (barrido 3 fases, sin parche)
    //--------------------------------------------------
    teclado_hex u_teclado (
        .clk(clk27),
        .rst(rst),
        .scan_tick(scan_tick),
        .rows_async(keypad_rows),

        .cols(keypad_cols),
        .key_valid(key_valid),
        .key_code(key_code)
    );

    //--------------------------------------------------
    // FSM de control
    //--------------------------------------------------
    control_entrada_fsm u_control (
        .clk(clk27),
        .rst(rst),

        .key_valid(key_valid),
        .key_code(key_code),

        .a_lleno(a_lleno),
        .b_lleno(b_lleno),

        .limpiar(limpiar),
        .cargar_a(cargar_a),
        .cargar_b(cargar_b),
        .calcular(calcular),

        .seleccion_display(seleccion_display)
    );

    //--------------------------------------------------
    // Constructor número A
    //--------------------------------------------------
    constructor_numero #(
        .WIDTH(11),
        .MAX_DIGITOS(3)
    ) u_numero_a (
        .clk(clk27),
        .rst(rst),
        .limpiar(limpiar),
        .cargar_digito(cargar_a),
        .digito(key_code),

        .numero(numero_a),
        .cantidad_digitos(cantidad_a),
        .lleno(a_lleno)
    );

    //--------------------------------------------------
    // Constructor número B
    //--------------------------------------------------
    constructor_numero #(
        .WIDTH(11),
        .MAX_DIGITOS(3)
    ) u_numero_b (
        .clk(clk27),
        .rst(rst),
        .limpiar(limpiar),
        .cargar_digito(cargar_b),
        .digito(key_code),

        .numero(numero_b),
        .cantidad_digitos(cantidad_b),
        .lleno(b_lleno)
    );

    //--------------------------------------------------
    // División entera
    //--------------------------------------------------
    subsistema_division u_div (

        .clk(clk27),
        .rst(rst),
        .A(numero_a),
        .B(numero_b),
        .valid(valid),
        .cociente(cociente),
        .residuo(residuo)
        .done(done)
    );

    //--------------------------------------------------
    // Selector del número a mostrar
    //--------------------------------------------------
    selector_numero_display u_selector_display (
        .seleccion_display(seleccion_display),

        .numero_a(numero_a),
        .numero_b(numero_b),
        .resultado(resultado),

        .numero_display(numero_display)
    );

    //--------------------------------------------------
    // Conversor BCD
    //--------------------------------------------------
    binario_a_bcd_4dig u_bcd (
        .bin(numero_display),

        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3)
    );

    //--------------------------------------------------
    // Display 4 dígitos
    //--------------------------------------------------
    display_4dig_mux #(
        .CLK_FREQ(27000000),
        .REFRESH_HZ(1000),
        .COMMON_ANODE(0)
    ) u_display (
        .clk(clk27),
        .rst(rst),

        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3),

        .seg(seg),
        .dig(dig)
    );

endmodule