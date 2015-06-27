program breiku;
var
        N : integer;
        cont : integer;
begin
        writeln("informe um numero qualquer");
        readln(N);
        cont :=1;
        while (cont <= N) do 
        begin 
                cont := cont + 1;
                if (cont < 101) then
                        break;
        end;
        writeln("Num informado: ", N);
        writeln("ateh onde o laco foi: ", cont);
end .
