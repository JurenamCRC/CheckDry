function [numday]=dayoftheyear(year, month, dia, prec)
%[numday]=dayoftheyear(year, month, dia, prec)
% calcula el número del día para datos entrantes se parados por columna
% de la forma [año, mes, día]
t = datetime(year,month,dia);
num= day(t,'dayofyear');
numday = [num,prec]
end