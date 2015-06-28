%{
   import java.io.*;
  import java.util.ArrayList;
  import java.util.Stack;
%}

%token  PROGRAM FUNCTION PROCEDURE
%token VAR INTEGER BOOLEAN REAL 
%token BEGIN END IF THEN ELSE WHILE DO READLN WRITELN FACA ENQUANTO SE SENAO BREAK
%token ASSIGN DIV MOD AND OR NOT
%token TRUE FALSE
%token LEQ LE GRE GEQ EQ NEQ
%token LITERAL ID NUM 

%right EQ
%nonassoc LEQ LE GR GEQ NEQ 
%left '+' '-' OR
%left '*' DIV MOD AND
%left NOT

%type <sval> ID
%type <sval> NUM
%type <sval> LITERAL
%type <ival> type


%%

program : PROGRAM ID { geraInicio(); } ';' declarationOpc { System.out.println("_start:"); } compoundStmt '.' { geraFinal(); geraAreaDados(); geraAreaLiterais(); }
        ;

declarationOpc : varDeclarations 
                ;

varDeclarations : VAR declarationList
                |
                ;

declarationList : declaration ';' declarationList
                | declaration ';'
          		| error { System.out.println("Erro na declaração, linha: " + lexer.getLine() ); }
                ;

declaration : ID ':' type {  TS_entry nodo = ts.pesquisa($1);
    	                	if (nodo != null) 
                            	yyerror("(sem) variavel >" + $1 + "< jah declarada");
                        	else ts.insert(new TS_entry($1, $3)); 
			     }
			     ;

type : INTEGER { $$ = INTEGER; }
     | BOOLEAN { $$ = BOOLEAN; }
     | REAL    { $$ = REAL; }
     ;


compoundStmt : BEGIN statementList END ;

statementList : statement ';' statementList
              | statement
              | error ';' { System.out.println("Erro nos comandos, linha: " + lexer.getLine() ); }
              ;

statement : ID ASSIGN exp {  System.out.println("\tPOPL %EDX");
                             System.out.println("\tMOVL %EDX, _"+$1); }

          | WHILE { pRot.push(proxRot); whileRot.push(proxRot);  proxRot += 2;
                    System.out.printf("rot_%02d:\n",pRot.peek()); } 
	    exp  { System.out.println("\tPOPL %EAX   # desvia se falso...");
	           System.out.println("\tCMPL $0, %EAX");
	           System.out.printf("\tJE rot_%02d\n", (int)pRot.peek()+1); } 
	    DO statement { System.out.printf("\tJMP rot_%02d   # terminou cmd na linha de cima\n", pRot.peek());
	                   System.out.printf("rot_%02d:\n",(int)pRot.peek()+1);
	                   pRot.pop(); whileRot.pop(); } 

          | BREAK { System.out.printf("\tJMP rot_%02d\n", whileRot.peek() + 1); }

	  | FACA  statement { System.out.printf("\tJMP rot_%02d   # terminou cmd na linha de cima\n", pRot.peek());
                              System.out.printf("rot_%02d:\n",(int)pRot.peek()+1);
                              pRot.pop(); } 
            ENQUANTO { pRot.push(proxRot);  proxRot += 2;
                       System.out.printf("rot_%02d:\n",pRot.peek()); } 
	    exp  { System.out.println("\tPOPL %EAX   # desvia se falso...");
	           System.out.println("\tCMPL $0, %EAX");
	           System.out.printf("\tJE rot_%02d\n", (int)pRot.peek()+1); } 

          | compoundStmt

          | READLN '(' ID ')' { System.out.println("\tPUSHL $_"+$3);
                                System.out.println("\tCALL _read");
	                        System.out.println("\tPOPL %EDX");
	                        System.out.println("\tMOVL %EAX, (%EDX)"); }

          | WRITELN '(' LITERAL ')' { strTab.add($3);
                                      System.out.println("\tMOVL $_str_"+strCount+"Len, %EDX"); 
                                      System.out.println("\tMOVL $_str_"+strCount+", %ECX"); 
                                      System.out.println("\tCALL _writeLit"); 
                                      System.out.println("\tCALL _writeln"); 
                                      strCount++; }
      
	  | WRITELN '(' LITERAL { strTab.add($3);
                                  System.out.println("\tMOVL $_str_"+strCount+"Len, %EDX"); 
                                  System.out.println("\tMOVL $_str_"+strCount+", %ECX"); 
                                  System.out.println("\tCALL _writeLit"); 
	                          strCount++; }
            ',' exp ')' { System.out.println("\tPOPL %EAX"); 
                          System.out.println("\tCALL _write");	
                          System.out.println("\tCALL _writeln"); }

          | IF  exp THEN { pRot.push(proxRot);  proxRot += 2;
                           System.out.println("\tPOPL %EAX");
	                   System.out.println("\tCMPL $0, %EAX");
	                   System.out.printf("\tJE rot_%02d\n", pRot.peek()); }
	    statement restoIf { System.out.printf("rot_%02d:\n",pRot.peek()+1);
	                        pRot.pop(); }

	  |  exp SE { pRot.push(proxRot);  proxRot += 2;
	              System.out.println("\tPOPL %EAX");
	              System.out.println("\tCMPL $0, %EAX");
	              System.out.printf("\tJE rot_%02d\n", pRot.peek()); }
	    statement restoSe { System.out.printf("rot_%02d:\n",pRot.peek()+1);
	                        pRot.pop(); }
							
	  |
          ;
     
     
restoIf : ELSE  {
											System.out.printf("\tJMP rot_%02d\n", pRot.peek()+1);
											System.out.printf("rot_%02d:\n",pRot.peek());
								
										} 							
							statement  
							
							
		| {
		    System.out.printf("\tJMP rot_%02d\n", pRot.peek()+1);
				System.out.printf("rot_%02d:\n",pRot.peek());
				} 
		;	
		
restoSe : SENAO  {
											System.out.printf("\tJMP rot_%02d\n", pRot.peek()+1);
											System.out.printf("rot_%02d:\n",pRot.peek());
								
										} 							
							statement  
          ;

printList : LITERAL printList2
          | exp printList2
          ;

printList2 : ',' printList
           |
           ;

exp :  		   NUM  { System.out.println("\tPUSHL $"+$1); } 
		|  TRUE  { System.out.println("\tPUSHL $1"); } 
 		|  FALSE  { System.out.println("\tPUSHL $0"); }      
 		| ID   { System.out.println("\tPUSHL _"+$1); }
    		| '(' exp ')' 
    
		| exp '+' exp		{ gcExpArit('+'); }
		| exp '-' exp		{ gcExpArit('-'); }
		| exp '*' exp		{ gcExpArit('*'); }
		| exp DIV exp		{ gcExpArit('/'); }
		| exp MOD exp		{ gcExpArit('%'); }
		| NOT exp       	{ gcExpNot(); }
																			
		| exp GR exp		{ gcExpRel('>'); }
		| exp LE exp		{ gcExpRel('<'); }											
		| exp EQ exp		{ gcExpRel(EQ); }											
		| exp LEQ exp		{ gcExpRel(LEQ); }											
		| exp GEQ exp		{ gcExpRel(GEQ); }											
		| exp NEQ exp		{ gcExpRel(NEQ); }											
												
		| exp OR exp		{ gcExpLog(OR); }											
		| exp AND exp		{ gcExpLog(AND); }											
		
		;					


%%

  private Yylex lexer;

  private TabSimb ts = new TabSimb();

  private int strCount = 0;
  private ArrayList<String> strTab = new ArrayList<String>();

  private Stack<Integer> pRot = new Stack<Integer>();
  private Stack<Integer> whileRot = new Stack<Integer>();
  private int proxRot = 1;


  public static int ARRAY = 100;


  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("Error: " + error + "  linha: " + lexer.getLine());
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }  

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  public static void main(String args[]) throws IOException {

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
      yyparser.yyparse();
      // yyparser.listarTS();

    }
    else {
      // interactive mode
      System.out.println("\n\tFormato: java Parser entrada.cmm >entrada.s\n");
    }

  }

							
		void gcExpArit(int oparit) {
 				System.out.println("\tPOPL %EDX");
   			System.out.println("\tPOPL %EAX");

   		switch (oparit) {
     		case '+' : System.out.println("\tADDL %EDX, %EAX" ); break;
     		case '-' : System.out.println("\tSUBL %EDX, %EAX" ); break;
     		case '*' : System.out.println("\tIMULL %EDX, %EAX" ); break;
     		case '/':  System.out.println("\tMOVL %EAX, %EBX");
        	         System.out.println("\tMOVL %EDX, %EAX");
           		     System.out.println("\tMOVL $0, %EDX");
           		     System.out.println("\tIDIVL %EBX");
           		     break;
     		case '%':  System.out.println("\tMOVL %EAX, %EBX");
        	         System.out.println("\tMOVL %EDX, %EAX");
           		     System.out.println("\tMOVL $0, %EDX");
           		     System.out.println("\tIDIVL %EBX");
           		     System.out.println("\tMOVL %EDX, %EAX");
           		     break;
    		}
   		System.out.println("\tPUSHL %EAX");
		}

	public void gcExpRel(int oprel) {

    System.out.println("\tPOPL %EAX");
    System.out.println("\tPOPL %EDX");
    System.out.println("\tCMPL %EAX, %EDX");
    System.out.println("\tMOVL $0, %EAX");
    
    switch (oprel) {
       case '<':  			System.out.println("\tSETL  %AL"); break;
       case '>':  			System.out.println("\tSETG  %AL"); break;
       case Parser.EQ:  System.out.println("\tSETE  %AL"); break;
       case Parser.GEQ: System.out.println("\tSETGE %AL"); break;
       case Parser.LEQ: System.out.println("\tSETLE %AL"); break;
       case Parser.NEQ: System.out.println("\tSETNE %AL"); break;
       }
    
    System.out.println("\tPUSHL %EAX");

	}


	public void gcExpLog(int oplog) {

	   	System.out.println("\tPOPL %EDX");
 		 	System.out.println("\tPOPL %EAX");

  	 	System.out.println("\tCMPL $0, %EAX");
 		  System.out.println("\tMOVL $0, %EAX");
   		System.out.println("\tSETNE %AL");
   		System.out.println("\tCMPL $0, %EDX");
   		System.out.println("\tMOVL $0, %EDX");
   		System.out.println("\tSETNE %DL");

   		switch (oplog) {
    			case Parser.OR:  System.out.println("\tORL  %EDX, %EAX");  break;
    			case Parser.AND: System.out.println("\tANDL  %EDX, %EAX"); break;
       }

    	System.out.println("\tPUSHL %EAX");
	}

	public void gcExpNot(){

  	 System.out.println("\tPOPL %EAX" );
 	   System.out.println("	\tNEGL %EAX" );
  	 System.out.println("	\tPUSHL %EAX");
	}

   private void geraInicio() {
			System.out.println(".text\n\n#\t nome COMPLETO e matricula dos componentes do grupo...\n#\n"); 
			System.out.println(".GLOBL _start\n\n");  
   }

   private void geraFinal(){
	
			System.out.println("\n\n");
			System.out.println("#");
			System.out.println("# devolve o controle para o SO (final da main)");
			System.out.println("#");
			System.out.println("\tmov $0, %ebx");
			System.out.println("\tmov $1, %eax");
			System.out.println("\tint $0x80");
	
			System.out.println("\n");
			System.out.println("#");
			System.out.println("# Funcoes da biblioteca (IO)");
			System.out.println("#");
			System.out.println("\n");
			System.out.println("_writeln:");
			System.out.println("\tMOVL $__fim_msg, %ECX");
			System.out.println("\tDECL %ECX");
			System.out.println("\tMOVB $10, (%ECX)");
			System.out.println("\tMOVL $1, %EDX");
			System.out.println("\tJMP _writeLit");
			System.out.println("_write:");
			System.out.println("\tMOVL $__fim_msg, %ECX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tCMPL $0, %EAX");
			System.out.println("\tJGE _write3");
			System.out.println("\tNEGL %EAX");
			System.out.println("\tMOVL $1, %EBX");
			System.out.println("_write3:");
			System.out.println("\tPUSHL %EBX");
			System.out.println("\tMOVL $10, %EBX");
			System.out.println("_divide:");
			System.out.println("\tMOVL $0, %EDX");
			System.out.println("\tIDIVL %EBX");
			System.out.println("\tDECL %ECX");
			System.out.println("\tADD $48, %DL");
			System.out.println("\tMOVB %DL, (%ECX)");
			System.out.println("\tCMPL $0, %EAX");
			System.out.println("\tJNE _divide");
			System.out.println("\tPOPL %EBX");
			System.out.println("\tCMPL $0, %EBX");
			System.out.println("\tJE _print");
			System.out.println("\tDECL %ECX");
			System.out.println("\tMOVB $'-', (%ECX)");
			System.out.println("_print:");
			System.out.println("\tMOVL $__fim_msg, %EDX");
			System.out.println("\tSUBL %ECX, %EDX");
			System.out.println("_writeLit:");
			System.out.println("\tMOVL $1, %EBX");
			System.out.println("\tMOVL $4, %EAX");
			System.out.println("\tint $0x80");
			System.out.println("\tRET");
			System.out.println("_read:");
			System.out.println("\tMOVL $15, %EDX");
			System.out.println("\tMOVL $__msg, %ECX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tMOVL $3, %EAX");
			System.out.println("\tint $0x80");
			System.out.println("\tMOVL $0, %EAX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tMOVL $0, %EDX");
			System.out.println("\tMOVL $__msg, %ECX");
			System.out.println("\tCMPB $'-', (%ECX)");
			System.out.println("\tJNE _reading");
			System.out.println("\tINCL %ECX");
			System.out.println("\tINC %BL");
			System.out.println("_reading:");
			System.out.println("\tMOVB (%ECX), %DL");
			System.out.println("\tCMP $10, %DL");
			System.out.println("\tJE _fimread");
			System.out.println("\tSUB $48, %DL");
			System.out.println("\tIMULL $10, %EAX");
			System.out.println("\tADDL %EDX, %EAX");
			System.out.println("\tINCL %ECX");
			System.out.println("\tJMP _reading");
			System.out.println("_fimread:");
			System.out.println("\tCMPB $1, %BL");
			System.out.println("\tJNE _fimread2");
			System.out.println("\tNEGL %EAX");
			System.out.println("_fimread2:");
			System.out.println("\tRET");
			System.out.println("\n");
     }

     private void geraAreaDados(){
			System.out.println("");		
			System.out.println("#");
			System.out.println("# area de dados");
			System.out.println("#");
			System.out.println(".data");
			System.out.println("#");
			System.out.println("# variaveis globais");
			System.out.println("#");
			ts.geraGlobais();	
			System.out.println("");
	
    }

     private void geraAreaLiterais() { 

         System.out.println("#\n# area de literais\n#");
         System.out.println("__msg:");
	       System.out.println("\t.zero 30");
	       System.out.println("__fim_msg:");
	       System.out.println("\t.byte 0");
	       System.out.println("\n");

         for (int i = 0; i<strTab.size(); i++ ) {
             System.out.println("_str_"+i+":");
             System.out.println("\t .ascii \""+strTab.get(i)+"\""); 
	           System.out.println("_str_"+i+"Len = . - _str_"+i);  
	      }		
   }
   
