module subsistema_division (
    input wire clk,             // Señal de reloj
    input wire rst,             // Señal de reinicio (activo en alto)
    input wire [6:0] A,         // Dividendo de 7 bits (0-127)
    input wire [4:0] B,         // Divisor de 5 bits  (0-31)
    input wire valid,           // Bandera de inicio de operación
    output reg [6:0] cociente,  // Cociente de la división (máx 127)
    output reg [4:0] residuo,   // Residuo de la división  (máx 30)
    output reg done             // Bandera de resultado estable
);

    // Definición de los estados
    localparam ESPERA   = 1'b0;
    localparam CALCULO  = 1'b1;

    reg estado_actual;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado_actual <= ESPERA;
            cociente      <= 7'b0;
            residuo       <= 5'b0;
            done          <= 1'b0;
        end else begin
            case (estado_actual)
                ESPERA: begin
                    done <= 1'b0;
                    if (valid)
                        estado_actual <= CALCULO;
                end

                CALCULO: begin
                    if (B != 5'b00000) begin
                        cociente <= A / B;
                        residuo  <= A % B;
                    end else begin
                        // División por cero
                        cociente <= 7'b1111111;
                        residuo  <= 5'b00000;
                    end
                    done          <= 1'b1;
                    estado_actual <= ESPERA;
                end
            endcase
        end
    end

endmodule