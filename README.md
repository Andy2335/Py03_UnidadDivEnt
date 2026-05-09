# Proyecto corto II – Diseño digital sincrónico en HDL
# Implementación de un Sumador de 4 bits

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
Implementar un sistema digital sincrónico que reciba dos cadenas de 8 bits mediante un teclado matricial, estos dos números se suman mediante un sumador y mostrar el resultado en un display de 4x7 segmentos.

# Descripción general del sistema

En este proyecto se abordará el diseño e implementación de un sistema digital sincrónico que mediante un teclado matricial se ingresarán dos números enteros de 3 cifras decimales (8 bits por número), los cuales serán sumados utilizando un sumador de 16 bits. El resultado de la suma se mostrará en un display de 4x7 segmentos, permitiendo visualizar el resultado de la operación, este limita el desbordamiento debido a la candidad de bits utilizado. El sistema se implementará utilizando el lenguaje de descripción de hardware Verilog y se probará en una FPGA Nano Tang 9k.

<img src="https://github.com/Andy2335/Py02DispSec/blob/3f3f60fa3e27a0b1f55e09d4d0992d0f4d454024/doc/Imagenes/Montaje%20Sistema%20Animado.png" width="700">

Montaje paso a paso del proyecto visita:
[** Wiki Home ** ](https://github.com/Andy2335/Py02DispSec/wiki)

## Estructura de la documentación
- `README.md`, Descripción general del proyecto
- `docs`, Especificaciones, esquemas, hojas de datos, imagenes, simulaciones, etc.
- `wiki`, Explicación detallada "Tutorial"
- `src`, Código fuente del proyecto, organizado en dispositivo y módulos
- `build`, Makerfile, scripts de compilación, archivos de configuración, etc.
- `constr`, Constraints - Definición de pines.
- `design`, Implementación lógica programada y funciones.
- `sim`, Testbenches y archivos de simulación.

## Jerarquía del sistema
- 4.1 Lector Teclado Hexadecimal - Diagrama de bloques y circuito lógico

    ### Diagrama de bloques:
    <img src="" width="700">

    ### Circuito lógico:
    <img src="" width="700">

    ### Visualización de Señales:
    <img src="" width="700">

- 4.2 Sumador - Diagrama de bloques y circuito lógico

    ### Diagrama de bloques:
    <img src="" width="700">

    ### Circuito lógico:
    <img src="" width="700">

    ### Visualización de Señales:
    <img src="" width="700">

- 4.3 Visualización DecoDisplay7SEG - Diagrama de bloques y circuito lógico

    ### Diagrama de bloques:
    <img src="" width="700">

    ### Circuito lógico:
    <img src="" width="700">

    ### Visualización de Señales:
    <img src="" width="700">


- Testbench y Simulación de Ondas
  [wiki]()

    El testbench se utilizó para verificar automáticamente el funcionamiento 

## Diagrama de Bloques:

El diagrama muestra la estructura funcional del módulo principal del sistema emisor. El dato de entrada de 4 bits es procesado por el codificador, el cual genera una palabra codificada de 7 bits, luego, esta señal es enviada al módulo de inserción de error, donde se puede alterar un bit según el valor de BitError, dando los bits finales del transmisor para que estos pasen al receptor. El dato original también es enviado al decodificador de 7 segmentos para su visualización en el display.

  <a href="https://raw.githubusercontent.com/Andy2335/Py01_DisLog_EmisorReceptorHamming/main/doc/imagenes/Diagrama.png">
  <img src="https://raw.githubusercontent.com/Andy2335/Py01_DisLog_EmisorReceptorHamming/main/doc/imagenes/Diagrama.png" width="700">
</a>

## Resultados
- Pendiente de desarrollo.



## Mejora en el sistema 
Pendiente de desarrollo.
[wiki]()




## Laboratorio  
Pendiente de desarrollo.
[wiki]()


## Conclusion
Pendiente de desarrollo.
