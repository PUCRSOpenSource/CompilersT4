program vazio;
var
        N : integer;
        cont : integer;
        res : integer;
begin
        writeln("informe o valor de N");
        readln(N);
        cont :=1;
        res :=1;
        while (cont <= N) do 
        begin 
                res := res * cont;
                cont := cont + 1;
        end;
        writeln("fatorial de N ", res);
end .
