# Proyecto corto III – Unidad división de enteros HDL
## Implementación de máquinas de estados para el diseño de algoritmos

## Escuela de Ingeniería Electrónica
**Curso:** EL-3307 Diseño Lógico

**Profesor:** Oscar Caravaca

**Semestre:** I Semestre 2026  

--- 
## Integrantes
- Andrés Obregón López
- Mariana Solano Gutiérrez
- Mariana Guerrero Morales
---

## Abreviaturas y definiciones
- **FPGA**: Field Programmable Gate Arrays
- **HDL**: Hardware Description Language
- **SRC**: Source

## Herramientas Utilizadas
- **Lenguaje de descripción de hardware**: Verilog
- **Plataforma de desarrollo**: FPGA Nano Tang 9k
- **Multisim**: Para simulación de circuitos digitales
- **Digital works**: Para simulación de circuitos digitales
- **GTKWave**: Para verificación gráfica de señales en simulaciones

## Referencias
[0] David Harris y Sarah Harris. *Digital Design and Computer Architecture. RISC-V Edition.* Morgan Kaufmann, 2022. ISBN: 978-0-12-820064-3

[1] [FZumb4do. open_source_fpga_environment](https://github.com/FZumb4do/open_source_fpga_environment.git) 

[2] [LUSHAYLABS. Tang Nano 9K: Getting Setup](https://learn.lushaylabs.com/getting-setup-with-the-tang-nano-9k/)

[3] [Sipeed Wiki — Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)


## Objetivo
Implementar una unidad de división de enteros sin signo mediante la utilización de máquinas de estados en Verilog HDL.

# Descripción general del sistema

En este proyecto se abordará el diseño e implementación de una unidad de división de enteros sin signo. Este sistema recibe dos números: Un dividendo de 6bits (63D máx) y un divisor de 4bits (15D máx) mediante una entrada en teclado matricial y representado para el usuario en una matriz de 4x7 segmentos. Luego el sistema realiza la operación de división mediante el algoritmo visto en clase basado en maquina de estados. El resultado "Cociente" y "Residuo" serán mostrados en la matriz de 4x7 segmentos. El sistema se implementará utilizando el lenguaje de descripción de hardware Verilog y se probará en una FPGA Nano Tang 9k.

<img src="https://github.com/Andy2335/Py02DispSec/blob/3f3f60fa3e27a0b1f55e09d4d0992d0f4d454024/doc/Imagenes/Montaje%20Sistema%20Animado.png" width="700">

Montaje paso a paso del proyecto visita:
[** Wiki Home ** ](https://github.com/Andy2335/Py03_UnidadDivEnt/wiki)

## Estructura de la documentación
- `README.md`, Descripción general del proyecto
- `docs`, Especificaciones, esquemas, hojas de datos, imagenes, simulaciones, etc.
- `wiki`, Explicación detallada "Tutorial"
- `src`, Código fuente del proyecto, organizado en dispositivo y módulos
- `build`, Makerfile, scripts de compilación, archivos de configuración, etc.
- `constr`, Constraints - Definición de pines.
- `design`, Implementación lógica programada y funciones.
- `sim`, Testbenches y archivos de simulación.

## Diagrama de Bloques - Unidad División de Enteros:
<a href="">
  <img src="https://github.com/Andy2335/Py03_UnidadDivEnt/blob/6bb05b87e605d0433d7a6879e747e27481df14d8/doc/Imagenes/Sistema%20de%20divisi%C3%B3n%20de%20enteros.png" width="700">
</a>

## Jerarquía del sistema
```
                                  display_4dig_mux
===================================================================================
 
 clk ───► ┌────────────────────────┐  sel[1:0]
          │   Divisor de frec.     │─────────────────────────┐
 rst ───► │  cnt[log2(TPD)-1:0]    │                         │
          └────────────────────────┘                         ▼
                                                    ┌─────────────────┐
 d0[3:0] ─────────────────────────────────────────► │    Mux 4:1      │
 d1[3:0] ─────────────────────────────────────────► │                 │──► digit_val[3:0]
 d2[3:0] ─────────────────────────────────────────► │  sel → d0/d1/   │
 d3[3:0] ─────────────────────────────────────────► │        d2/d3    │──► dig_raw[3:0]
                                                    └─────────────────┘
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │ Decodificador   │
                                                    │  BCD → 7 seg.   │──► seg_raw[6:0]
                                                    │   (gfedcba)     │
                                                    └─────────────────┘
                                                             │
                                                             ▼
                                                    ┌─────────────────┐
                                                    │ Reg. de salida  │──► seg[6:0]
                                                    │ (inversión por  │──► dig[3:0]
                                                    │  COMMON_ANODE)  │
                                                    └─────────────────┘

```


