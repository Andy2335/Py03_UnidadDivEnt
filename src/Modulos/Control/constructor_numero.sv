// constructor_numero.sv
// Soporta MAX_DIGITOS = 2 ó 3.
// Para MAX_DIGITOS=3 (número A, hasta 127) se agrega la rama
// cantidad_digitos==2 en la lógica combinacional de candidato.

module constructor_numero #(
    parameter int WIDTH       = 7,
    parameter int MAX_DIGITOS = 3,
    parameter int MAX_VAL     = 127
)(
    input  logic             clk,
    input  logic             rst,
    input  logic             limpiar,
    input  logic             cargar_digito,
    input  logic             borrar,
    input  logic [3:0]       digito,

    output logic [WIDTH-1:0] numero,
    output logic [1:0]       cantidad_digitos,
    output logic             lleno,
    output logic             es_cero
);

    localparam int CALC_WIDTH = WIDTH + 4;

    logic cargar_r;
    logic borrar_r;
    logic [3:0] digito_r;
    logic [3:0] primer_digito;
    logic [3:0] segundo_digito;

    logic [CALC_WIDTH-1:0] numero_ext;
    logic [CALC_WIDTH-1:0] digito_ext;
    logic [CALC_WIDTH-1:0] primer_ext;
    logic [CALC_WIDTH-1:0] candidato;

    assign lleno   = (cantidad_digitos >= MAX_DIGITOS[1:0]);
    assign es_cero = (numero == '0);

    logic es_digito_r;
    assign es_digito_r = (digito_r[3] == 1'b0) ||
                         (digito_r == 4'd8)     ||
                         (digito_r == 4'd9);

    always_comb begin
        numero_ext = '0;
        numero_ext[WIDTH-1:0] = numero;

        digito_ext = '0;
        digito_ext[3:0] = digito_r;

        primer_ext = '0;
        primer_ext[3:0] = primer_digito;

        candidato = numero_ext;

        if (cantidad_digitos == 2'd0) begin
            // primer dígito ingresado
            candidato = digito_ext;
        end
        else if (cantidad_digitos == 2'd1) begin
            // segundo dígito: numero*10 + digito
            candidato = (numero_ext << 3) + (numero_ext << 1) + digito_ext;
        end
        else if (cantidad_digitos == 2'd2) begin
            // tercer dígito: numero*10 + digito  (sólo válido si MAX_DIGITOS==3)
            candidato = (numero_ext << 3) + (numero_ext << 1) + digito_ext;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
            primer_digito    <= 4'd0;
            segundo_digito   <= 4'd0;
            cargar_r         <= 1'b0;
            borrar_r         <= 1'b0;
            digito_r         <= 4'd0;
        end
        else begin
            cargar_r <= cargar_digito;
            borrar_r <= borrar;
            digito_r <= digito;

            if (limpiar) begin
                numero           <= '0;
                cantidad_digitos <= 2'd0;
                primer_digito    <= 4'd0;
                segundo_digito   <= 4'd0;
                cargar_r         <= 1'b0;
                borrar_r         <= 1'b0;
                digito_r         <= 4'd0;
            end
            else if (borrar_r && cantidad_digitos > 2'd0) begin
                if (cantidad_digitos == 2'd3) begin
                    // Deshacer tercer dígito: volver a los dos primeros
                    // numero = primer_digito*10 + segundo_digito
                    numero           <= WIDTH'(({4'b0,primer_digito} << 3) +
                                               ({4'b0,primer_digito} << 1) +
                                                {4'b0,segundo_digito});
                    cantidad_digitos <= 2'd2;
                end
                else if (cantidad_digitos == 2'd2) begin
                    // Deshacer segundo dígito: volver al primero
                    numero           <= WIDTH'({4'b0, primer_digito});
                    cantidad_digitos <= 2'd1;
                end
                else begin
                    // Deshacer primer dígito
                    numero           <= '0;
                    cantidad_digitos <= 2'd0;
                    primer_digito    <= 4'd0;
                    segundo_digito   <= 4'd0;
                end
            end
            else if (cargar_r && !lleno && es_digito_r) begin
                if (candidato <= CALC_WIDTH'(MAX_VAL)) begin
                    numero <= candidato[WIDTH-1:0];

                    if (cantidad_digitos == 2'd0) begin
                        cantidad_digitos <= 2'd1;
                        primer_digito    <= digito_r;
                    end
                    else if (cantidad_digitos == 2'd1) begin
                        cantidad_digitos <= 2'd2;
                        segundo_digito   <= digito_r;
                    end
                    else if (cantidad_digitos == 2'd2) begin
                        cantidad_digitos <= 2'd3;
                    end
                end
            end
        end
    end

endmodule