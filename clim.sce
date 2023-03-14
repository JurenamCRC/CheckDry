function [serie1, clim, dias]=moveavgt(serie,n)
a =1
m =2
[nf, nc] = size(serie)
ini = serie(1,a)
fin = serie(nf,a)
annos = linspace(ini,fin, fin+1-ini )'
serie1 = serie
dias = []
d = []

for i = annos(1):annos($)
    mask = find(serie(:,a)==i)
    d = dias
    dias = linspace(1,length(mask), length(mask)+1-1 )'
    dias = [d;dias]
end 

maskdc  find(serie(:,a)==2)
diasdc = linspace(1,length(mask), length(mask)+1-1 )'

for i = 1:12
    mask = find(serie(:,m)==i) // busco los datos del mes i
    climes = nanmean(serie(mask,e)) // promedio los días del mismo mes de toda la serie, se da en mm/dia para la estación e
    clim(i,e-3) = climes // guardo los 12 valores 
        
    // Rellenar los datos ausentes con la climatología del mse correspondiente
    mask = find(serie(:,m)==i) // busco los datos del mes i
    masknull = find(isnan(serie(mask,e))) //de los datos del mes i busco los datos nulos
    nulos = mask(masknull) // se genera la mascara del mes i con datos nulos
    serie1(nulos,e)=clim(i, e-3) // sustituyo la climatología del mes i por los datos nulos del mes i para toda la serie
end


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
    // Genero un año ficticio de climatologías para esa estación
end
endfunction

