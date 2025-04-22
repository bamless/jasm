build/jasm: build/jasm.o
	ld -o $@ $< -rpath '$$ORIGIN/../lib' -L./lib/ -ljstar -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2

build/jasm.o: jasm.asm jstar.inc.asm libc.inc.asm
	@mkdir -p build
	fasm $< $@

.PHONY: clean
clean:
	rm -rf build
