function [serie1, clim]=moveavgt(serie,n)
a =1
m =2
[nf, nc] = size(serie)
ini = serie(1,a)
fin = serie(nf,a)
annos = linspace(ini,fin, fin+1-ini )'
serie1 = serie

// Se obtiene la climatología
[nfa nca] = size(annos)
clim = []
for e = 4:nc
    for i = 1:12
        mask = find(serie(:,m)==i) // busco los datos del mes i
        climes = nanmean(serie(mask,e)) // promedio los días del mismo mes de toda la serie, se da en mm/dia para la estación e
        clim(i,e-3) = climes // guardo los 12 valores 
    end
    // Rellenar los datos ausentes con la climatología del mse correspondiente
    for i = 1:12
        mask = find(serie(:,m)==i) // busco los datos del mes i
        masknull = find(isnan(serie(mask,e))) //de los datos del mes i busco los datos nulos
        nulos = mask(masknull) // se genera la mascara del mes i con datos nulos
        serie1(nulos,e)=clim(i, e-3) // sustituyo la climatología del mes i por los datos nulos del mes i para toda la serie
    end
end
endfunction

