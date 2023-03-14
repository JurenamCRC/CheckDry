function [numday]=dayoftheyear(year, month, dia, prec)
%[numday]=dayoftheyear(year, month, dia, prec)
% calcula el n�mero del d�a para datos entrantes se parados por columna
% de la forma [a�o, mes, d�a]
t = datetime(year,month,dia);
num= day(t,'dayofyear');
numday = [num,prec]
end