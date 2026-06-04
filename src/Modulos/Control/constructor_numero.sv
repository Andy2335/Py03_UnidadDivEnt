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

    //--------------------------------------------------
    // Estados
    //--------------------------------------------------
    localparam ESPERA = 2'd0;
    localparam CARGAR = 2'd1;
    localparam BORRAR = 2'd2;

    logic [1:0] estado;

    //--------------------------------------------------
    // Registros internos
    //--------------------------------------------------
    logic [3:0] digito_guardado;
    logic [3:0] primer_digito;

    localparam int CALC_WIDTH = WIDTH + 4;

    logic [CALC_WIDTH-1:0] numero_ext;
    logic [CALC_WIDTH-1:0] digito_ext;
    logic [CALC_WIDTH-1:0] candidato;

    //--------------------------------------------------
    // Salidas simples
    //--------------------------------------------------
    assign lleno   = (cantidad_digitos >= MAX_DIGITOS);
    assign es_cero = (numero == '0);

    //--------------------------------------------------
    // Cálculo del próximo número SIN división
    //--------------------------------------------------
    always_comb begin
        numero_ext = '0;
        numero_ext[WIDTH-1:0] = numero;

        digito_ext = '0;
        digito_ext[3:0] = digito_guardado;

        candidato = numero_ext;

        if (cantidad_digitos == 2'd0) begin
            candidato = digito_ext;
        end
        else if (cantidad_digitos == 2'd1) begin
            // numero * 10 + digito
            // Se hace con shifts para no usar multiplicador pesado
            candidato = (numero_ext << 3) + (numero_ext << 1) + digito_ext;
        end
    end

    //--------------------------------------------------
    // Máquina de estados
    //--------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado           <= ESPERA;
            numero           <= '0;
            cantidad_digitos <= 2'd0;
            digito_guardado  <= 4'd0;
            primer_digito    <= 4'd0;
        end
        else begin
            if (limpiar) begin
                estado           <= ESPERA;
                numero           <= '0;
                cantidad_digitos <= 2'd0;
                digito_guardado  <= 4'd0;
                primer_digito    <= 4'd0;
            end
            else begin
                case (estado)

                    //--------------------------------------------------
                    // Espera una orden de cargar o borrar
                    //--------------------------------------------------
                    ESPERA: begin
                        if (cargar_digito && !lleno && digito <= 4'd9) begin
                            digito_guardado <= digito;
                            estado <= CARGAR;
                        end
                        else if (borrar && cantidad_digitos > 2'd0) begin
                            estado <= BORRAR;
                        end
                    end

                    //--------------------------------------------------
                    // Carga el dígito si no excede el máximo
                    //--------------------------------------------------
                    CARGAR: begin
                        if (candidato <= CALC_WIDTH'(MAX_VAL)) begin

                            if (cantidad_digitos == 2'd0) begin
                                numero           <= candidato[WIDTH-1:0];
                                cantidad_digitos <= 2'd1;
                                primer_digito    <= digito_guardado;
                            end
                            else if (cantidad_digitos == 2'd1) begin
                                numero           <= candidato[WIDTH-1:0];
                                cantidad_digitos <= 2'd2;
                            end

                        end

                        estado <= ESPERA;
                    end

                    //--------------------------------------------------
                    // Borra el último dígito SIN hacer numero / 10
                    //--------------------------------------------------
                    BORRAR: begin
                        if (cantidad_digitos == 2'd2) begin
                            numero           <= WIDTH'(primer_digito);
                            cantidad_digitos <= 2'd1;
                        end
                        else if (cantidad_digitos == 2'd1) begin
                            numero           <= '0;
                            cantidad_digitos <= 2'd0;
                            primer_digito    <= 4'd0;
                        end

                        estado <= ESPERA;
                    end

                    default: begin
                        estado <= ESPERA;
                    end

                endcase
            end
        end
    end

endmodule