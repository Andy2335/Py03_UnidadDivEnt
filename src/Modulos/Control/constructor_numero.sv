module constructor_numero #(
    parameter int WIDTH = 11,
    parameter int MAX_DIGITOS = 3
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              limpiar,
    input  logic              cargar_digito,
    input  logic [3:0]        digito,

    output logic [WIDTH-1:0]  numero,
    output logic [1:0]        cantidad_digitos,
    output logic              lleno
);

    // Registrar entradas 1 ciclo para alinear con logica combinacional de la FSM
    logic              cargar_digito_r;
    logic [3:0]        digito_r;

    always_ff @(posedge clk) begin
        if (rst) begin
            cargar_digito_r <= 1'b0;
            digito_r        <= 4'd0;
        end else begin
            cargar_digito_r <= cargar_digito;
            digito_r        <= digito;
        end
    end

    logic es_digito;
    logic [WIDTH-1:0] digito_ext;
    logic [WIDTH-1:0] numero_x10;
    logic [WIDTH-1:0] numero_next;

    assign es_digito  = (digito_r == 4'd0) || (digito_r == 4'd1) ||
                        (digito_r == 4'd2) || (digito_r == 4'd3) ||
                        (digito_r == 4'd4) || (digito_r == 4'd5) ||
                        (digito_r == 4'd6) || (digito_r == 4'd7) ||
                        (digito_r == 4'd8) || (digito_r == 4'd9);

    assign lleno = (cantidad_digitos >= MAX_DIGITOS);

    always_comb begin
        digito_ext  = {{(WIDTH-4){1'b0}}, digito_r};
        numero_x10  = (numero << 3) + (numero << 1);
        numero_next = numero;

        if (cargar_digito_r && !lleno && es_digito) begin
            if (cantidad_digitos == 2'd0)
                numero_next = digito_ext;
            else
                numero_next = numero_x10 + digito_ext;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
        end else if (limpiar) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
        end else if (cargar_digito_r && !lleno && es_digito) begin
            numero           <= numero_next;
            cantidad_digitos <= cantidad_digitos + 2'd1;
        end
    end

endmodule