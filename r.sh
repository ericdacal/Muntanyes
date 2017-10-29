antlr -gt mountains.g
dlg -ci parser.dlg scan.c
g++ -w -o mountains mountains.c scan.c err.c -I/home/eric/Documentos/Universidad/LP/Compiladors/pccts/h
rm -f *.o mountains.c scan.c err.c parser.dlg tokens.h mode.h
./mountains < inp1.txt
