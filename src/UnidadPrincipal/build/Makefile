BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

PROYECT = sumador_teclado_matricial

MODULOS = ../../modulos
DESIGN = ../design

SOURCES = \
	$(wildcard $(MODULOS)/Teclado/*.sv) \
	$(wildcard $(MODULOS)/Control/*.sv) \
	$(wildcard $(MODULOS)/Calculo_Suma/*.sv) \
	$(wildcard $(MODULOS)/Display_7Seg/*.sv) \
	$(DESIGN)/top.sv

TESTBENCH = ../sim/tb_top.sv

CONSTRAINTS = ../constr/Constraints.cst

TOP_DESIGN = top
TOP_TB     = tb_top

VCD_FILE = tb_top.vcd
 

#****************
#NOTA - SOLO SE CAMBIAN EL TESTBENCH, EL TOP_TB Y EL VCD_FILE PARA HACER LAS SIMULACIONES.
#****************

all: synth pnr bitstream load

synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1
	@echo "COMPLETADO"

pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1
	@echo "COMPLETADO"

bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

test: ${SOURCES} ${TESTBENCH}
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o

wv: ${VCD_FILE}
	gtkwave ${VCD_FILE}

load: ${PROYECT}_${BOARD}.fs
	openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs

clean:
	@echo "Limpiando archivos temporales..."
	-del /Q *.json *.log *.o *.out *.fs *.vcd 2>nul
	-del /Q *_pnr.json *_test.o 2>nul
	@echo "Limpieza completada"

.PHONY: load wv test
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json