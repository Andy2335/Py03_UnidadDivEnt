module control_entrada_fsm(
    input  logic       clk,
    input  logic       rst,

    input  logic       key_valid,
    input  logic [3:0] key_code,

    input  logic       a_lleno,
    input  logic       b_lleno,

    output logic       limpiar,
    output logic       cargar_a,
    output logic       cargar_b,
    output logic       calcular,

    output logic [1:0] seleccion_display
);

    localparam [1:0] INGRESO_A         = 2'd0;
    localparam [1:0] INGRESO_B         = 2'd1;
    localparam [1:0] MOSTRAR_RESULTADO = 2'd2;

    logic [1:0] estado;

    logic es_digito;
    assign es_digito = (key_code == 4'd0) || (key_code == 4'd1) ||
                       (key_code == 4'd2) || (key_code == 4'd3) ||
                       (key_code == 4'd4) || (key_code == 4'd5) ||
                       (key_code == 4'd6) || (key_code == 4'd7) ||
                       (key_code == 4'd8) || (key_code == 4'd9);

    // Estado registrado
    always_ff @(posedge clk) begin
        if (rst) estado <= INGRESO_A;
        else begin
            if (key_valid) begin
                if (key_code == 4'hC || key_code == 4'hD)
                    estado <= INGRESO_A;
                else begin
                    case (estado)
                        INGRESO_A: if (key_code == 4'hE) estado <= INGRESO_B;
                        INGRESO_B: if (key_code == 4'hF) estado <= MOSTRAR_RESULTADO;
                        default: ;
                    endcase
                end
            end
        end
    end

    // Salidas combinacionales puras
    always_comb begin
        limpiar           = 1'b0;
        cargar_a          = 1'b0;
        cargar_b          = 1'b0;
        calcular          = 1'b0;
        seleccion_display = 2'd0;

        case (estado)
            INGRESO_A:         seleccion_display = 2'd0;
            INGRESO_B:         seleccion_display = 2'd1;
            MOSTRAR_RESULTADO: seleccion_display = 2'd2;
            default:           seleccion_display = 2'd0;
        endcase

        if (key_valid) begin
            if (key_code == 4'hC || key_code == 4'hD) begin
                limpiar = 1'b1;
            end else begin
                case (estado)
                    INGRESO_A: begin
                        if (es_digito && !a_lleno)
                            cargar_a = 1'b1;
                    end
                    INGRESO_B: begin
                        if (es_digito && !b_lleno)
                            cargar_b = 1'b1;
                        else if (key_code == 4'hF)
                            calcular = 1'b1;
                    end
                    default: ;
                endcase
            end
        end
    end

endmodule