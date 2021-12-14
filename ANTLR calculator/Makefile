# makefile for Expr Evaluation in C++
PROG=expr.exe
G4=Expr.g4

ANTLR4=java -jar /usr/local/lib/antlr-complete.jar -Dlanguage=Cpp -o antlr4-cpp
ANTLR4_RUNTIME=/usr/local/include/antlr4-runtime
CFLAGS=-I. -I$(ANTLR4_RUNTIME)
LIBS=-lantlr4-runtime

ANTLR4DIR=antlr4-cpp
OBJ=ExprMain.o $(ANTLR4DIR)/ExprBaseListener.o $(ANTLR4DIR)/ExprLexer.o $(ANTLR4DIR)/ExprListener.o $(ANTLR4DIR)/ExprParser.o

default: antlr $(PROG)
	
$(PROG): $(OBJ)
	$(CXX) -o $@ $^ $(CFLAGS) $(LIBS)

%.o:	%.cpp
	$(CXX) -c -o $@ $< $(CFLAGS)

antlr: $(G4)
	$(ANTLR4) $<

.PHONY: clean

clean:
	rm -f $(PROG) *.o $(ANTLR4DIR)/*.o *~ core

wipe:	clean
	rm -rf $(ANTLR4DIR)
	
