.PHONY: all clean

JOUJOU=../../joujou --typecheck

GOODS = $(wildcard *-good.j)
BADS  = $(wildcard *-bad.j)

all:
	@ echo '* Task 2: Writing a typechecker' | tee task-2.log
	@for good in $(GOODS); do \
	  ($(JOUJOU) $$good && echo "  - [OK] $$good") || echo "  - [KO] $$good"; \
	done | tee -a task-2.log
	@for bad in $(BADS); do \
	  ($(JOUJOU) $$bad 2> $$bad.log && echo "  - [KO] $$bad") \
          || echo "  - [XFAIL] $$bad"; \
	  cat $$bad.log; \
	done | tee -a task-2.log
	@ echo '** Score for this task:' \
        `grep '\[OK\]\|\[XFAIL\]' task-2.log | wc -l`/\
	`grep '^  -' task-2.log | wc -l | tr -d ' '`

clean:
	rm -f *~ *.log
