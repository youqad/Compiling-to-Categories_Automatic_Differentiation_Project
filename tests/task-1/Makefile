.PHONY: all clean

all:
	cp ../../category.ml .
	ocamlbuild testsuite.byte
	./testsuite.byte

clean:
	ocamlbuild -clean testsuite.byte
	rm -f *~
