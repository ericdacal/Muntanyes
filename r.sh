antlr -gt mountains.g
dlg -ci parser.dlg scan.c
g++ -w -o mountains mountains.c scan.c err.c -I/home/eric/Documentos/Universitat/LP/Compiladors/PCCTS_v1.33/include
rm -f *.o mountains.c scan.c err.c parser.dlg tokens.h mode.h
./mountains < inp.txt
