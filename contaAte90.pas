program contaAte90;
var
        whileExterno : integer;
        whileInterno : integer;
begin
        whileExterno := 50;
        whileInterno := 0;
        while (whileExterno < 100) do 
        begin
                while (whileInterno < 100) do
                begin
                        if (whileInterno = 50) then
                                break;
                        writeln("int",whileInterno);
                        whileInterno := whileInterno + 1;
                end;
                if (whileExterno = 91) then
                        break;
                writeln("ext",whileExterno);
                whileExterno := whileExterno + 1;
        end;
end .
