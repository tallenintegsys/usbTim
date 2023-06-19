PROJ=usb
VFLAGS= -Wall -g2005
PCF = orangecrab_r0.2.pcf
DEVICE = 85k

all: ${PROJ}.json

dfu: ${PROJ}.dfu
	dfu-util -a0 -D $<

%.json: verilog/*.v
	yosys -p "read_verilog -sv -Iverilog $^; synth_ecp5 -flatten -json $@"

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --$(DEVICE) --package CSFBGA285 --lpf $(PCF)

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

.PHONY:  clean sim verilator

sim:
	iverilog -g2012 -I verilog verilog/usb_annunciator_tb.v
	vvp a.out
#	iverilog -g2012 -I verilog verilog/usb_top_tb.v
#	vvp a.out
#	iverilog -I verilog verilog/uart_tx_tb.v -o uart_tx_tb
#	vvp uart_tx_tb

verilator:
	verilator --lint-only -Iverilog verilog/usb_annunciator.v

clean:
	rm -rf *.vcd a.out *.svf *.bit *.config *.json *.dfu 
