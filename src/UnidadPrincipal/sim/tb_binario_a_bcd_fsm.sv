`timescale 1ns/1ps
 
module tb_binario_a_bcd_fsm;
 
    localparam integer N       = 6;
    localparam real    CLK_PER = 37.037; // Periodo exacto para los 27 MHz de la TangNano
 
    logic           clk;
    logic           rst;
    logic           valid_i;
    logic [N-1:0]   bin_i;
    logic [3:0]     d0, d1, d2, d3;
    logic           done_o;
 
    // Instanciación del Diseño Bajo Prueba (DUT)
    binario_a_bcd_fsm #(.N_BITS(N)) dut (
        .clk     (clk),
        .rst     (rst),
        .valid_i (valid_i),
        .bin_i   (bin_i),
        .d0      (d0),
        .d1      (d1),
        .d2      (d2),
        .d3      (d3),
        .done_o  (done_o)
    );
 
    // Generador de Reloj Global
    initial clk = 0;
    always #(CLK_PER / 2.0) clk = ~clk;
 
    // Configuración de volcado de ondas para GTKWave / iverilog
    initial begin
        $dumpfile("tb_binario_a_bcd_fsm.vcd");
        $dumpvars(0, tb_binario_a_bcd_fsm);
    end
 
    // Monitor de terminal: Imprime resultados en consola cada vez que done_o cambia a alto
    always @(posedge done_o) begin
        $display("[MONITOR] Tiempo: %0t ns | Entrada Binaria = %2d  ->  Salida Display BCD: %0d%0d%0d%0d",
                 $time, bin_i, d3, d2, d1, d0);
    end
 
    // Tarea Síncrona para Envío Automático de Datos respetando el Handshake
    task enviar_numero(input logic [N-1:0] valor);
        begin
            @(posedge clk);
            bin_i   = valor;
            valid_i = 1'b1; // Iniciar conversión
            
            // Espera activa y síncrona hasta que el hardware termine de procesar el dato
            @(posedge done_o); 
            
            @(posedge clk);
            valid_i = 1'b0; // Apagar valid de inmediato (Finalización del ciclo de Handshake)
            
            #(CLK_PER * 2); // Pequeña pausa de estabilidad entre pruebas
        end
    endtask
 
    // =============================================================
    // Bloque de Estímulos Principal
    // =============================================================
    initial begin
        $display("======= INICIANDO SIMULACIÓN MÁQUINA DE ESTADOS BCD =======");
        
        // --- Condición Inicial de Reset ---
        rst     = 1'b1;
        valid_i = 1'b0;
        bin_i   = '0;
        #(CLK_PER * 3);
        
        rst     = 1'b0; // Quitar reset
        #(CLK_PER * 2);
 
        // --- Secuencia de Pruebas Unitarias ---
        
        $display("\n[TEST] Prueba 1: Número 45 (Debe mostrar 0045)");
        enviar_numero(6'd45);
 
        $display("\n[TEST] Prueba 2: Número 7 (Debe mostrar 0007)");
        enviar_numero(6'd7);
 
        $display("\n[TEST] Prueba 3: Número 63 (Valor máximo para 6 bits - Debe mostrar 0063)");
        enviar_numero(6'd63);
 
        $display("\n[TEST] Prueba 4: Número 0 (Caso límite - Debe mostrar 0000)");
        enviar_numero(6'd0);
 
        $display("\n[TEST] Prueba 5: Número 20 (Debe mostrar 0020)");
        enviar_numero(6'd20);
 
        // Tiempo de espera final antes de cerrar simulación
        #(CLK_PER * 10);
        $display("\n======= SIMULACIÓN FINALIZADA CON ÉXITO =======");
        $finish;
    end
 
endmodule