
all:
	$(MAKE) -C full $(MAKECMDGOALS)
	cp full/tb.fst tb.fst
	cp full/results.xml results.xml

clean:
	rm -rf fast/__pycache__ fast/sim_build fast/results.xml fast/tb.fst fast/tb.fst.hier
	rm -rf full/__pycache__ full/sim_build full/results.xml full/tb.fst full/tb.fst.hier
	rm -rf shiftreg/__pycache__ shiftreg/sim_build shiftreg/results.xml
	rm -f tb.fst results.xml

.PHONY: all clean
