.PHONY: all clean

INPUTS = $(wildcard *.j)
GENERATED_FILES = $(INPUTS:.j=.ml)

all: $(INPUTS)
	@ cp ../../category.ml .
	@ ocamlc -c category.ml
	@ echo '* Task 3: Writing a compiler to categories' | tee task-3.log
	@for i in $(INPUTS); do \
	  (./test.sh $$i 2> log && echo "  - [OK] $$i") || echo "  - [KO] $$i"; \
	  cat log | sed 's/\(.*\)/    \1/'; \
	done | tee -a task-3.log
	@ echo '** Score for this task:' \
        `grep '\[OK\]' task-3.log | wc -l`/\
	`grep '^  -' task-3.log | wc -l | tr -d ' '`

clean:
	rm -f $(GENERATED_FILES) *.cmo *~ *.cmi *_test *.log category.ml
