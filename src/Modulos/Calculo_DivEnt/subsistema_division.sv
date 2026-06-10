module subsistema_division (
    input  logic       clk,
    input  logic       rst,
    input  logic [5:0] A,
    input  logic [3:0] B,
    input  logic       valid,

    output logic [5:0] cociente,
    output logic [3:0] residuo,
    output logic       done
);

    //--------------------------------------------------
    // Estados
    //--------------------------------------------------

    localparam ESPERA     = 2'd0;
    localparam CALCULO    = 2'd1;
    localparam FINALIZADO = 2'd2;

    logic [1:0] estado;

    //--------------------------------------------------
    // Registros internos
    //--------------------------------------------------

    logic [5:0] A_reg;
    logic [5:0] Q_reg;

    logic [4:0] R_reg;
    logic [4:0] D_reg;

    logic [2:0] indice;

    //--------------------------------------------------
    // Señales combinacionales del algoritmo
    //--------------------------------------------------

    logic [4:0] R_shift;
    logic [4:0] R_sub;

    assign R_shift = {R_reg[3:0], A_reg[indice]};
    assign R_sub   = R_shift - D_reg;

    //--------------------------------------------------
    // Máquina de estados
    //--------------------------------------------------

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin

            estado   <= ESPERA;

            cociente <= 6'd0;
            residuo  <= 4'd0;
            done     <= 1'b0;

            A_reg    <= 6'd0;
            Q_reg    <= 6'd0;
            R_reg    <= 5'd0;
            D_reg    <= 5'd0;

            indice   <= 3'd0;

        end
        else begin

            case (estado)

                //------------------------------------------
                // Espera de una nueva operación
                //------------------------------------------
                ESPERA: begin

                    done <= 1'b0;

                    if (valid) begin

                        //----------------------------------
                        // División por cero
                        //----------------------------------
                        if (B == 4'd0) begin

                            cociente <= 6'b111111;
                            residuo  <= 4'd0;

                            done <= 1'b1;

                            estado <= FINALIZADO;

                        end
                        else begin

                            A_reg  <= A;
                            D_reg  <= {1'b0,B};

                            Q_reg  <= 6'd0;
                            R_reg  <= 5'd0;

                            indice <= 3'd5;

                            estado <= CALCULO;

                        end

                    end

                end

                //------------------------------------------
                // Algoritmo restaurador
                //------------------------------------------
                CALCULO: begin

                    if (R_shift >= D_reg) begin

                        R_reg <= R_sub;

                        Q_reg[indice] <= 1'b1;

                        //----------------------------------
                        // Última iteración
                        //----------------------------------
                        if (indice == 3'd0) begin

                            cociente <= (Q_reg | 6'b000001);

                            residuo <= R_sub[3:0];

                            done <= 1'b1;

                            estado <= FINALIZADO;

                        end
                        else begin

                            indice <= indice - 3'd1;

                        end

                    end
                    else begin

                        R_reg <= R_shift;

                        Q_reg[indice] <= 1'b0;

                        //----------------------------------
                        // Última iteración
                        //----------------------------------
                        if (indice == 3'd0) begin

                            cociente <= Q_reg;

                            residuo <= R_shift[3:0];

                            done <= 1'b1;

                            estado <= FINALIZADO;

                        end
                        else begin

                            indice <= indice - 3'd1;

                        end

                    end

                end

                //------------------------------------------
                // Resultado estable
                //------------------------------------------
                FINALIZADO: begin

                    done <= 1'b1;

                    if (!valid)
                        estado <= ESPERA;

                end

                default: begin

                    estado <= ESPERA;

                end

            endcase

        end

    end

endmodule