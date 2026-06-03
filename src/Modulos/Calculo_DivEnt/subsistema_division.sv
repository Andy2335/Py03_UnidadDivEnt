module subsistema_division (
    input wire clk,             // Señal de reloj
    input wire rst,             // Señal de reinicio (activo en alto)
    input wire [5:0] A,         // Dividendo de 6 bits
    input wire [3:0] B,         // Divisor de 4 bits
    input wire valid,           // Bandera de inicio de operación
    output reg [5:0] cociente,  // Cociente de la división
    output reg [3:0] residuo,   // Residuo de la división
    output reg done             // Bandera de resultado estable
);

    // Definición de los estados
    localparam ESPERA = 1'b0;
    localparam CALCULO = 1'b1;

    reg estado_actual;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reinicio de todos los registros
            estado_actual <= ESPERA;
            cociente <= 6'b000000;
            residuo <= 4'b0000;
            done <= 1'b0;
        end else begin
            case (estado_actual)
                ESPERA: begin
                    done <= 1'b0; // Se apaga la bandera done
                    
                    // Condición 2: Inicia cuando valid es 1
                    if (valid) begin
                        estado_actual <= CALCULO;
                    end
                end

                CALCULO: begin
                    // Prevención de error matemático (división por cero)
                    if (B != 4'b0000) begin
                        cociente <= A / B;
                        residuo  <= A % B;
                    end else begin
                        // Manejo de error si B es 0
                        cociente <= 6'b111111; 
                        residuo  <= 4'b0000;
                    end
                    
                    // Condición 3: Se levanta la bandera done al tener resultado estable
                    done <= 1'b1;
                    
                    // Regresa al estado de espera para la siguiente operación
                    estado_actual <= ESPERA;
                end
            endcase
        end
    end

endmodule