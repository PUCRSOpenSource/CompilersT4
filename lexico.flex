%%

%byaccj
%integer
%line
%char
%caseless 
%ignorecase

%{
  private Parser yyparser;

  public Yylex(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
    yyline = 1;
  }

  public int getLine() {
      return yyline;
  }

%}

WHITE_SPACE = [\n\r\ \t\b\012]
ID          = {LETTER}+({LETTER}|{NUM}|"_")*
LETTER      = [a-zA-Z]
NUM         = [0-9]+

%%

"$TRACE_ON"  { yyparser.setDebug(true);  }
"$TRACE_OFF" { yyparser.setDebug(false); }

"PROGRAM"   {return Parser.PROGRAM;}

"VAR"       {return Parser.VAR;}      
"INTEGER"   {return Parser.INTEGER;}
"BOOLEAN"   {return Parser.BOOLEAN;}   

"BEGIN"     {return Parser.BEGIN;}
"END"       {return Parser.END;}
"IF"        {return Parser.IF;}
"THEN"      {return Parser.THEN;}
"ELSE"      {return Parser.ELSE;}
"WHILE"     {return Parser.WHILE;}
"DO"        {return Parser.DO;}
"READLN"    {return Parser.READLN;}
"WRITELN"   {return Parser.WRITELN;}


":="        {return Parser.ASSIGN;}
"DIV"       {return Parser.DIV;}
"MOD"       {return Parser.MOD;}
"AND"       {return Parser.AND;}
"OR"        {return Parser.OR;}
"NOT"       {return Parser.NOT;}
"<="        {return Parser.LEQ;}
"<"         {return Parser.LE;}
">"         {return Parser.GR;}
">="        {return Parser.GEQ;}
"="         {return Parser.EQ;}
"<>"        {return Parser.NEQ;}

"TRUE"      {return Parser.TRUE;}
"FALSE"     {return Parser.FALSE;}

":"|
";"|
"."|
","|
"("|
")"|
"+"|
"-"|
"*"    {return yytext().charAt(0);} 

\"[^\n]+\" { yyparser.yylval = new ParserVal(yytext().substring(1, yylength() -1));
	     return Parser.LITERAL; }


{ID}   {yyparser.yylval = new ParserVal(yytext()); return Parser.ID;}
{NUM}   {yyparser.yylval = new ParserVal(yytext()); return Parser.NUM;}

"{"[^.]*"}"   { }	
{WHITE_SPACE}+    { }
.      {System.out.println("Erro lexico: caracter inválido: <" + yytext() + ">");}
