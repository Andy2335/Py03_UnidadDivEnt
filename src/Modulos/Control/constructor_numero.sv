module constructor_numero #(
    parameter int WIDTH      = 6,   // 6 para dividendo, 4 para divisor
    parameter int MAX_DIGITOS = 2,
    parameter int MAX_VAL    = 63   // 63 para dividendo, 15 para divisor
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             limpiar,
    input  logic             cargar_digito,
    input  logic             borrar,        // elimina ultimo digito
    input  logic [3:0]       digito,

    output logic [WIDTH-1:0] numero,
    output logic [1:0]       cantidad_digitos,
    output logic             lleno,
    output logic             es_cero        // numero == 0 o vacio
);

    // Registro de entradas (igual que P2)
    logic             cargar_digito_r;
    logic             borrar_r;
    logic [3:0]       digito_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            cargar_digito_r <= 1'b0;
            borrar_r        <= 1'b0;
            digito_r        <= 4'd0;
        end else begin
            cargar_digito_r <= cargar_digito;
            borrar_r        <= borrar;
            digito_r        <= digito;
        end
    end

    localparam int CALC_WIDTH = WIDTH + 4;

    logic                    es_digito;
    logic [CALC_WIDTH-1:0]   numero_ext;
    logic [CALC_WIDTH-1:0]   digito_ext;
    logic [CALC_WIDTH-1:0]   numero_x10;
    logic [CALC_WIDTH-1:0]   numero_next;
    logic [CALC_WIDTH-1:0]   numero_div10;
    logic                    excede_max;

    assign es_digito = (digito_r <= 4'd9);
    assign lleno     = (cantidad_digitos >= MAX_DIGITOS);
    assign es_cero   = (numero == '0);

    always_comb begin
        numero_ext   = CALC_WIDTH'(numero);
        digito_ext   = CALC_WIDTH'(digito_r);

        numero_x10   = (numero_ext << 3) + (numero_ext << 1);  // * 10 sin truncar
        numero_div10 = numero_ext / 10;                         // para borrar

        if (cantidad_digitos == 2'd0)
            numero_next = digito_ext;
        else
            numero_next = numero_x10 + digito_ext;

        // Comparacion en ancho extendido: sin riesgo de overflow
        excede_max = (numero_next > CALC_WIDTH'(MAX_VAL));
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
        end else if (limpiar) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
        end else if (borrar_r && cantidad_digitos > 2'd0) begin
            numero           <= numero_div10[WIDTH-1:0];
            cantidad_digitos <= cantidad_digitos - 2'd1;
        end else if (cargar_digito_r && !lleno && es_digito && !excede_max) begin
            numero           <= numero_next[WIDTH-1:0];
            cantidad_digitos <= cantidad_digitos + 2'd1;
        end
    end

endmodule