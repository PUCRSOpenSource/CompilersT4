program breiku;
var
        N : integer;
        cont : integer;
begin
        writeln("informe um numero qualquer");
        readln(N);
        cont := 0;
        while (cont < N) do 
        begin 
                if (cont > 99) then
                        break;
                cont := cont + 1;
        end;
        writeln("Num informado: ", N);
        writeln("ateh onde o laco foi: ", cont);
end .
