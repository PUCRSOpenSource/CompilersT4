# only works with the Java extension of yacc: 
# byacc/j from http://troi.lincom-asg.com/~rjamison/byacc/

JFLEX  = java -jar JFlex.jar
OS := $(shell uname)
ifeq ($(OS), Darwin)
BYACCJ = ./yacc.macosx -tv -J
else
BYACCJ = ./yacc.linux -tv -J
endif
JAVAC  = javac

# targets:

all: Parser.class

run: Parser.class
	java Parser

build: clean Parser.class

clean:
	rm -f *~ *.class Yylex.java Parser.java y.output *.s *.o breiku contaAte90 fat vazio soma doWhile pulaOCinco

Parser.class: TS_entry.java TabSimb.java Yylex.java Parser.java
	$(JAVAC) Parser.java

Yylex.java: lexico.flex
	$(JFLEX) lexico.flex

Parser.java: gramatica.y
	$(BYACCJ) gramatica.y
