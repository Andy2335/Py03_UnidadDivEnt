module constructor_numero #(
    parameter int WIDTH       = 6,
    parameter int MAX_DIGITOS = 2,
    parameter int MAX_VAL     = 63
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

    logic [CALC_WIDTH-1:0] numero_ext;
    logic [CALC_WIDTH-1:0] digito_ext;
    logic [CALC_WIDTH-1:0] primer_ext;
    logic [CALC_WIDTH-1:0] candidato;

    assign lleno   = (cantidad_digitos >= MAX_DIGITOS[1:0]);
    assign es_cero = (numero == '0);

    // 0-7: digito_r[3]==0 / 8-9: explícito
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

        if (cantidad_digitos == 2'd0)
            candidato = digito_ext;
        else if (cantidad_digitos == 2'd1)
            candidato = (numero_ext << 3) + (numero_ext << 1) + digito_ext;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            numero           <= '0;
            cantidad_digitos <= 2'd0;
            primer_digito    <= 4'd0;
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
                cargar_r         <= 1'b0;
                borrar_r         <= 1'b0;
                digito_r         <= 4'd0;
            end
            else if (borrar_r && cantidad_digitos > 2'd0) begin
                if (cantidad_digitos == 2'd2) begin
                    numero           <= primer_ext[WIDTH-1:0];
                    cantidad_digitos <= 2'd1;
                end
                else begin
                    numero           <= '0;
                    cantidad_digitos <= 2'd0;
                    primer_digito    <= 4'd0;
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
                    end
                end
            end
        end
    end

endmodule