lextest: driver.o lex.yy.o errormsg.o util.o
	gcc -g -o lextest driver.o lex.yy.o errormsg.o util.o

lextestref: driver.o lexref.yy.o errormsg.o util.o
	gcc -g -o lextestref driver.o lexref.yy.o errormsg.o util.o

driver.o: driver.c tokens.h errormsg.h util.h
	gcc -g -c driver.c

errormsg.o: errormsg.c errormsg.h util.h
	gcc -g -c errormsg.c

util.o: util.c util.h
	gcc -g -c util.c

# --- student lexer ---
lex.yy.c: tiger.lex
	flex tiger.lex

lex.yy.o: lex.yy.c tokens.h errormsg.h util.h
	gcc -g -c lex.yy.c

# --- reference lexer ---
lexref.yy.c: tigerref.lex
	flex -o lexref.yy.c tigerref.lex

lexref.yy.o: lexref.yy.c tokens.h errormsg.h util.h
	gcc -g -c lexref.yy.c

clean:
	rm -f *.o lex.yy.c lexref.yy.c lextest lextestref