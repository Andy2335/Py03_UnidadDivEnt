module subsistema_division (
    input wire clk,
    input wire rst,
    input wire [5:0] A,
    input wire [3:0] B,
    input wire valid,

    output reg [5:0] cociente,
    output reg [3:0] residuo,
    output reg done,
    output reg error_div0
);

    //--------------------------------------------------
    // Estados
    //--------------------------------------------------
    localparam ESPERA  = 1'b0;
    localparam CALCULO = 1'b1;

    reg estado_actual;

    //--------------------------------------------------
    // Detección de flanco ascendente de valid
    //--------------------------------------------------
    reg valid_d;

    always @(posedge clk or posedge rst) begin
        if (rst)
            valid_d <= 1'b0;
        else
            valid_d <= valid;
    end

    wire valid_rise;
    assign valid_rise = valid & ~valid_d;

    //--------------------------------------------------
    // Máquina de estados
    //--------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= ESPERA;
            cociente      <= 6'd0;
            residuo       <= 4'd0;
            done          <= 1'b0;
            error_div0    <= 1'b0;
        end
        else begin

            case (estado_actual)

                //--------------------------------------------------
                // ESPERA
                //--------------------------------------------------
                ESPERA: begin
                    done       <= 1'b0;
                    error_div0 <= 1'b0;

                    // Solo responde al flanco ascendente
                    if (valid_rise)
                        estado_actual <= CALCULO;
                end

                //--------------------------------------------------
                // CALCULO
                //--------------------------------------------------
                CALCULO: begin

                    if (B == 4'd0) begin
                        cociente   <= 6'd0;
                        residuo    <= 4'd0;
                        error_div0 <= 1'b1;
                    end
                    else begin
                        cociente   <= A / B;
                        residuo    <= A % B;
                        error_div0 <= 1'b0;
                    end

                    done <= 1'b1;

                    estado_actual <= ESPERA;
                end

            endcase
        end
    end

endmodule

