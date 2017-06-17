flex spl.l
bison spl.y -t
gcc -o spl.exe spl.c spl.tab.c -lfl -pipe