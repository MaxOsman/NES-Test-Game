ca65 test.asm -o test.o --debug-info
ld65 test.o -o test.nes -t nes
timeout /t -1