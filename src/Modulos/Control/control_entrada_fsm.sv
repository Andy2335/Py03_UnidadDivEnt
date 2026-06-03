module control_entrada_fsm (
    input  logic       clk,
    input  logic       rst,

    input  logic       key_valid,
    input  logic [3:0] key_code,

    input  logic       a_lleno,
    input  logic       b_lleno,
    input  logic       b_es_cero,     // divisor == 0 (del constructor_numero)

    // Senal del subsistema de division
    input  logic       done,          // resultado estable

    output logic       limpiar,
    output logic       cargar_a,
    output logic       cargar_b,
    output logic       borrar_a,
    output logic       borrar_b,
    output logic       valid,         // pulso: inicia la division

    output logic       error,         // division entre cero
    output logic       sel_resultado, // 0=cociente, 1=residuo
    output logic [1:0] seleccion_display
);

    localparam [2:0] INGRESO_A  = 3'd0;
    localparam [2:0] INGRESO_B  = 3'd1;
    localparam [2:0] CALCULANDO = 3'd2;
    localparam [2:0] RESULTADO  = 3'd3;
    localparam [2:0] ERROR      = 3'd4;

    logic [2:0] estado;

    logic es_digito;
    assign es_digito = (key_code <= 4'd9);

    // --------------------------------------------------
    // Registro de sel_resultado
    // Alterna con * (4'hE) o # (4'hF) estando en RESULTADO
    // --------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst)
            sel_resultado <= 1'b0;
        else if (key_valid && (key_code == 4'hC || key_code == 4'hD))
            sel_resultado <= 1'b0;
        else if (key_valid && (key_code == 4'hE || key_code == 4'hF)
                 && estado == RESULTADO)
            sel_resultado <= ~sel_resultado;
    end

    // --------------------------------------------------
    // Registro de estado
    // --------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) estado <= INGRESO_A;
        else begin
            // C o D reinician desde cualquier estado
            if (key_valid && (key_code == 4'hC || key_code == 4'hD))
                estado <= INGRESO_A;
            else begin
                case (estado)
                    INGRESO_A:  if (key_valid && key_code == 4'hA)
                                    estado <= INGRESO_B;

                    INGRESO_B:  if (key_valid && key_code == 4'hA) begin
                                    if (b_es_cero)
                                        estado <= ERROR;      // division entre cero
                                    else
                                        estado <= CALCULANDO; // todo ok
                                end

                    CALCULANDO: if (done)
                                    estado <= RESULTADO;

                    RESULTADO:  ;  // solo sale con C/D

                    ERROR:      ;  // solo sale con C/D

                    default:    ;
                endcase
            end
        end
    end

    // --------------------------------------------------
    // Salidas combinacionales puras
    // --------------------------------------------------
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
            ERROR:      seleccion_display = 2'd3;  // display mostrara "Err"
            default:    seleccion_display = 2'd0;
        endcase

        if (key_valid) begin
            if (key_code == 4'hC || key_code == 4'hD) begin
                limpiar = 1'b1;
            end else begin
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
                            valid    = 1'b1;  // dispara la division solo si b != 0
                    end
                    ERROR: begin
                        error = 1'b1;         // nivel activo mientras se este en ERROR
                    end
                    default: ;
                endcase
            end
        end

        // error activo como nivel en estado ERROR (independiente de tecla)
        if (estado == ERROR)
            error = 1'b1;
    end

endmodule