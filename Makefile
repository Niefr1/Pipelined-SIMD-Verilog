run:
	verilator --binary --trace -Wall -Wno-EOFNEWLINE -Wno-UNUSEDSIGNAL -Wno-BLKSEQ --top-module tb src/*.v -o sim
	./obj_dir/sim
	gtkwave wave.vcd &