.PHONY: all clean

all:
	dune build joujou.exe
	ln -sf _build/default/joujou.exe joujou

clean:
	dune clean
	rm -f *~ joujou
