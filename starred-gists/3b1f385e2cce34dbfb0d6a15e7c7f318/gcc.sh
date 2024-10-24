gcc -E -dM test.cpp #end after preprocessing, print defined macros
gcc -c file.cpp; objdump -d file.o #compile without linking, dissasemble object file 
gcc -mno-red-zone file.cpp #turn off red zone for leaf functions
gcc -DSNIP #compile macro defined betwee  in #if SNIP #endif 
gcc -fno-exceptions #smaller binaries without exception handling
readelf -SW a.out #show elf tables like .eh_frame, exception handling framework
readelf --debug-dump=frames a.out #show table content
hexdump -C a.out #ELF string
readelf -hW a.out #ELF header
g++ file.cpp -v #compilation flags
readelf -lW a.out #ELF segments