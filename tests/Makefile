.PHONY: all clean

all:
	for d in $(wildcard task-*); do $(MAKE) -C $$d; done

clean:
	for d in $(wildcard task-*); do $(MAKE) -C $$d clean; done
	rm -f *~
