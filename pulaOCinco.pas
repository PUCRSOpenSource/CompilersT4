program pulaOCinco;
var
        cont : integer;
begin
        cont := 0;
        while (cont < 10) do 
        begin 
                cont := cont + 1;
                if (cont = 5) then
                        continue;
                writeln("Num par: ", cont);
        end;
end .
