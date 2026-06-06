module binario_a_bcd_fsm #(
    parameter integer N_BITS = 6   // Ajustado por defecto a 6 bits para el proyecto
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 valid_i,   // Señal de inicio (debe conectarse al done del divisor)
    input  logic [N_BITS-1:0]    bin_i,     // Número binario de entrada
    output logic [3:0]           d0,        // Unidades
    output logic [3:0]           d1,        // Decenas
    output logic [3:0]           d2,        // Centenas
    output logic [3:0]           d3,        // Millares (se mantiene en 0 para N_BITS <= 6)
    output logic                 done_o     // Bandera de resultado estable y conversión finalizada
);

    // =============================================================
    // Definición de estados FSM (Estilo Codificación TEC)
    // =============================================================
    typedef enum logic [1:0] {
        S_IDLE  = 2'd0,
        S_SHIFT = 2'd1,
        S_DONE  = 2'd2
    } state_t;

    state_t state_r, state_nx;

    // =============================================================
    // Registros Internos de la FSM
    // =============================================================
    // Registro de desplazamiento completo: [ BCD (16 bits) | Binario (N_BITS) ]
    logic [15:0] bcd_r, bcd_nx;
    logic [N_BITS-1:0] bin_r, bin_nx;
    logic [3:0]  cnt_r, cnt_nx;

    // =============================================================
    // Función Auxiliar Combinacional: Algoritmo Double Dabble (Suma 3 si >= 5)
    // =============================================================
    function automatic logic [15:0] add3_if_gte5(input logic [15:0] bcd_val);
        logic [3:0] hundreds;
        logic [3:0] tens;
        logic [3:0] ones;

        ones     = bcd_val[3:0];
        tens     = bcd_val[7:4];
        hundreds = bcd_val[11:8];

        if (ones >= 4'd5)     ones     = ones + 4'd3;
        if (tens >= 4'd5)     tens     = tens + 4'd3;
        if (hundreds >= 4'd5) hundreds = hundreds + 4'd3;

        return {bcd_val[15:12], hundreds, tens, ones};
    endfunction

    // =============================================================
    // Bloque Secuencial: Actualización de Estados y Registros
    // =============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_r <= S_IDLE;
            bcd_r   <= '0;
            bin_r   <= '0;
            cnt_r   <= '0;
        end else begin
            state_r <= state_nx;
            bcd_r   <= bcd_nx;
            bin_r   <= bin_nx;
            cnt_r   <= cnt_nx;
        end
    end

    // =============================================================
    // Bloque Combinacional: Lógica de Próximo Estado y Desplazamientos
    // =============================================================
    always_comb begin
        // Valores por defecto para evitar Latches
        state_nx = state_r;
        bcd_nx   = bcd_r;
        bin_nx   = bin_r;
        cnt_nx   = cnt_r;
        done_o   = 1'b0;

        case (state_r)
            S_IDLE: begin
                if (valid_i) begin
                    bcd_nx   = '0;             // Limpia el registro BCD
                    bin_nx   = bin_i;          // Carga el nuevo número binario
                    cnt_nx   = '0;             // Inicializa el contador de iteraciones
                    state_nx = S_SHIFT;
                end
            end

            S_SHIFT: begin
                logic [15:0] bcd_adjusted;
                
                // 1. Evaluar si algún dígito BCD es >= 5 y sumarle 3
                bcd_adjusted = add3_if_gte5(bcd_r);

                // 2. Realizar el desplazamiento unificado hacia la izquierda (Shift << 1)
                bcd_nx = {bcd_adjusted[14:0], bin_r[N_BITS-1]};
                bin_nx = {bin_r[N_BITS-2:0], 1'b0};
                
                // Incrementamos contador de bits procesados
                cnt_nx = cnt_r + 4'd1;

                // Condición de salida estricta: terminar tras procesar todos los bits
                if (cnt_r == (N_BITS - 1)) begin
                    state_nx = S_DONE;
                end
            end

            S_DONE: begin
                done_o = 1'b1; // Se levanta la bandera de conversión lista
                
                // Protocolo Handshake: Esperar de forma segura que el módulo de control
                // apague la señal valid_i para retornar limpiamente al estado de espera.
                if (!valid_i) begin
                    state_nx = S_IDLE;
                end
            end

            default: state_nx = S_IDLE;
        endcase
    end

    // =============================================================
    // Salidas Registradas de los Dígitos BCD hacia los Displays
    // Actualización síncrona solo al terminar la conversión (Evita Glitches)
    // =============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            d0 <= '0;
            d1 <= '0;
            d2 <= '0;
            d3 <= '0;
        end else if (state_r == S_DONE) begin
            d0 <= bcd_r[3:0];   // Unidades
            d1 <= bcd_r[7:4];   // Decenas
            d2 <= bcd_r[11:8];  // Centenas
            d3 <= bcd_r[15:12]; // Millares
        end
    end

endmodule