.PHONY: all clean

INPUTS = $(wildcard *.j)
GENERATED_FILES = $(INPUTS:.j=.ml)

all: $(INPUTS)
	@ cp ../../category.ml .
	@ ocamlc -c category.ml
	@ ocamlc -c diffCat.ml
	@ echo '* Task 4: Differentiation of first-order functions' | tee task-4.log
	@for i in $(INPUTS); do \
	  (./test.sh $$i 2> log && echo "  - [OK] $$i") || echo "  - [KO] $$i"; \
	  cat log | sed 's/\(.*\)/    \1/'; \
	done | tee -a task-4.log
	@ echo '** Score for this task:' \
        `grep '\[OK\]' task-4.log | wc -l`/\
	`grep '^  -' task-4.log | wc -l | tr -d ' '`

clean:
	rm -f $(GENERATED_FILES) *.cmo *.cmi *_test *.cmx *~ *.o category.ml *log
