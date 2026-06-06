module control_entrada_fsm (
    input  logic       clk,
    input  logic       rst,

    input  logic       key_valid,
    input  logic [3:0] key_code,

    input  logic       a_lleno,
    input  logic       b_lleno,
    input  logic       b_es_cero,

    input  logic       done,

    output logic       limpiar,
    output logic       cargar_a,
    output logic       cargar_b,
    output logic       borrar_a,
    output logic       borrar_b,
    output logic       valid,

    output logic       error,
    output logic       sel_resultado,
    output logic [1:0] seleccion_display
);

    localparam logic [2:0] INGRESO_A  = 3'd0;
    localparam logic [2:0] INGRESO_B  = 3'd1;
    localparam logic [2:0] CALCULANDO = 3'd2;
    localparam logic [2:0] RESULTADO  = 3'd3;
    localparam logic [2:0] ERROR      = 3'd4;

    logic [2:0] estado;

    // 0-7: key_code[3]==0 / 8-9: explícito
    logic es_digito;
    assign es_digito = (key_code[3] == 1'b0) ||
                       (key_code == 4'd8)     ||
                       (key_code == 4'd9);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado        <= INGRESO_A;
            sel_resultado <= 1'b0;
        end
        else begin
            if (key_valid && (key_code == 4'hC || key_code == 4'hD)) begin
                estado        <= INGRESO_A;
                sel_resultado <= 1'b0;
            end
            else begin
                case (estado)
                    INGRESO_A: begin
                        if (key_valid && key_code == 4'hA)
                            estado <= INGRESO_B;
                    end

                    INGRESO_B: begin
                        if (key_valid && key_code == 4'hA) begin
                            sel_resultado <= 1'b0;
                            if (b_es_cero)
                                estado <= ERROR;
                            else
                                estado <= CALCULANDO;
                        end
                    end

                    CALCULANDO: begin
                        if (done)
                            estado <= RESULTADO;
                    end

                    RESULTADO: begin
                        if (key_valid && (key_code == 4'hE || key_code == 4'hF))
                            sel_resultado <= ~sel_resultado;
                    end

                    ERROR: begin
                        // Sale solo con C o D
                    end

                    default: estado <= INGRESO_A;
                endcase
            end
        end
    end

    always_comb begin
        limpiar           = 1'b0;
        cargar_a          = 1'b0;
        cargar_b          = 1'b0;
        borrar_a          = 1'b0;
        borrar_b          = 1'b0;
        valid             = 1'b0;
        error             = 1'b0;
        seleccion_display = 2'd0;

        case (estado)
            INGRESO_A:  seleccion_display = 2'd0;
            INGRESO_B:  seleccion_display = 2'd1;
            CALCULANDO: seleccion_display = 2'd2;
            RESULTADO:  seleccion_display = 2'd2;
            ERROR:      seleccion_display = 2'd3;
            default:    seleccion_display = 2'd0;
        endcase

        if (estado == ERROR)
            error = 1'b1;

        if (key_valid) begin
            if (key_code == 4'hC || key_code == 4'hD) begin
                limpiar = 1'b1;
            end
            else begin
                case (estado)
                    INGRESO_A: begin
                        if (es_digito && !a_lleno)
                            cargar_a = 1'b1;
                        else if (key_code == 4'hB)
                            borrar_a = 1'b1;
                    end

                    INGRESO_B: begin
                        if (es_digito && !b_lleno)
                            cargar_b = 1'b1;
                        else if (key_code == 4'hB)
                            borrar_b = 1'b1;
                        else if (key_code == 4'hA && !b_es_cero)
                            valid = 1'b1;
                    end

                    default: ;
                endcase
            end
        end
    end

endmodule