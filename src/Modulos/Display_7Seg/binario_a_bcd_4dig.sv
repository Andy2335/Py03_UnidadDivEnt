module binario_a_bcd_4dig(
    input  logic        clk,
    input  logic        rst,
    input  logic [10:0] bin,

    output logic [3:0]  d0,
    output logic [3:0]  d1,
    output logic [3:0]  d2,
    output logic [3:0]  d3
);

    //--------------------------------------------------
    // Estados de la FSM
    //--------------------------------------------------
    localparam IDLE  = 2'd0;
    localparam ADD3  = 2'd1;
    localparam SHIFT = 2'd2;
    localparam DONE  = 2'd3;

    logic [1:0] estado;

    //--------------------------------------------------
    // Registros internos
    //--------------------------------------------------
    logic [10:0] bin_shift;
    logic [10:0] bin_guardado;

    logic [15:0] bcd_work;
    logic [15:0] bcd_add3;
    logic [15:0] bcd_next;
    logic [10:0] bin_next;

    logic [3:0] contador;

    //--------------------------------------------------
    // Etapa combinacional: sumar 3 si el dígito >= 5
    //--------------------------------------------------
    always_comb begin
        bcd_add3 = bcd_work;

        if (bcd_work[3:0] >= 4'd5)
            bcd_add3[3:0] = bcd_work[3:0] + 4'd3;

        if (bcd_work[7:4] >= 4'd5)
            bcd_add3[7:4] = bcd_work[7:4] + 4'd3;

        if (bcd_work[11:8] >= 4'd5)
            bcd_add3[11:8] = bcd_work[11:8] + 4'd3;

        if (bcd_work[15:12] >= 4'd5)
            bcd_add3[15:12] = bcd_work[15:12] + 4'd3;
    end

    //--------------------------------------------------
    // Cálculo del corrimiento
    //--------------------------------------------------
    always_comb begin
        {bcd_next, bin_next} = {bcd_add3, bin_shift} << 1;
    end

    //--------------------------------------------------
    // FSM principal
    //--------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            estado       <= IDLE;
            bin_shift    <= 11'd0;
            bin_guardado <= 11'd0;
            bcd_work     <= 16'd0;
            contador     <= 4'd0;

            d0 <= 4'd0;
            d1 <= 4'd0;
            d2 <= 4'd0;
            d3 <= 4'd0;
        end
        else begin
            // Si bin cambia en cualquier estado fuera de IDLE, reiniciar
            if (bin != bin_guardado && estado != IDLE) begin
                estado   <= IDLE;
                bcd_work <= 16'd0;
                contador <= 4'd0;
            end
            else begin
                case (estado)

                    //--------------------------------------------------
                    // Cargar número inicial
                    //--------------------------------------------------
                    IDLE: begin
                        bin_guardado <= bin;
                        bin_shift    <= bin;
                        bcd_work     <= 16'd0;
                        contador     <= 4'd0;
                        estado       <= ADD3;
                    end

                    //--------------------------------------------------
                    // Sumar 3 a cada dígito BCD si hace falta
                    //--------------------------------------------------
                    ADD3: begin
                        estado <= SHIFT;
                    end

                    //--------------------------------------------------
                    // Desplazar izquierda
                    //--------------------------------------------------
                    SHIFT: begin
                        bcd_work  <= bcd_next;
                        bin_shift <= bin_next;

                        if (contador == 4'd10) begin
                            d0 <= bcd_next[3:0];
                            d1 <= bcd_next[7:4];
                            d2 <= bcd_next[11:8];
                            d3 <= bcd_next[15:12];

                            estado <= DONE;
                        end
                        else begin
                            contador <= contador + 4'd1;
                            estado   <= ADD3;
                        end
                    end

                    //--------------------------------------------------
                    // Esperar hasta que cambie el número
                    //--------------------------------------------------
                    DONE: begin
                        if (bin != bin_guardado) begin
                            estado <= IDLE;
                        end
                    end

                    default: begin
                        estado <= IDLE;
                    end

                endcase
            end
        end
    end

endmodule