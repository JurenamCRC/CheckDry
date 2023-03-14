function [clim, salida ]  = climmt(serie,n)
//    [clim, salida ]  = todas(serie,n);
// este programita recibe una serie de datos diarios, calcula su climatología
// mensual en mm/dia, sustituye los valores nulos por la climatología de esa estación y
// luego calcula una media movil triangular de n elementos, esto se guarda en "salida" 
// ENTRADA  
// serie: matriz de datos donde las columnas son [año mes dia e1 e2 e3 ...],
// donde e1, e2, e3,... e_i son valores de precipitación diaria en mm, con datos 
// faltantes codificados como Nan.
// n: es la media movil triangular de n elementos. ESTA DEBE SER IMPAR!!
// SALIDA
// clim: matríz de datos (12, e_i) donde cada fila es el valor climatológico
// mensual de Ene a Dic en mm/día para la estación e_i.
// salida: matriz resultante de dimensiones [año mes dia e1 e2 e3 ...e_i, dia], esta 
// matríz tiene los primeros (n-1)/2 datos y los últimos (n-1)/2 datos rellenados con su
// climatología mensual según la estación correspondiente, ya que la media movil triangular
// de n valores empieza a calcularse (n-1)/2 datos después y termina (n-1)/2 datos antes.
// NOTA: los datos de las estaciones de "serie" deben empezar en la columna 4 y el resto
// de columnas deben ser de otras estaciones.
    
// Se calcula el num de día del año para la cantidad de años de "serie"    
a =1 // número de columna donde está ubicado el valor de los años
[nf, nc] = size(serie)
ini = serie(1,a)
fin = serie(nf,a)
annos = linspace(ini,fin, fin+1-ini )'
serie2 = serie
dias = []
d = []

for i = annos(1):annos($)
    mask = find(serie(:,a)==i)
    d = dias
    dias = linspace(1,length(mask), length(mask)+1-1 )'
    dias = [d;dias]
end 

// RELLENA CON LA CLIMATOLOGÍA
// se rellenan los datos diaros faltantes (Nan) con la climatología mensual
// correspondiente por cada estación

// Esta parte calcula los años que hay entre los datos
a = 1 // Columna donde están los años en "serie"
m = 2 // Columna donde están los meses
d = 3 // columna donde están los dias
/////e = 4 // columna donde están las estaciones

ini = serie(1,a)
fin = serie(nf,a)
annos = linspace(ini,fin, fin+1-ini )'
serie1 = serie

// Se obtiene la climatología
[nfa nca] = size(annos)
clim = []
mi = []
mf = []
N=(n-1)/2;
for e = 4:nc
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
//    Esta parte genera los primeros N datos y los últimos N datos según la climatología de la estación
//    correspondiente
    for dd=1:N
        mi1(dd,e-3)=serie1(dd,2)
        mi(dd,e-3) = clim(mi1(dd,1),e-3)
        mf1(dd,e-3)=serie1(nf-N+dd,2)
        mf(dd,e-3) = clim(mf1(dd,1), e-3)
    end
    serfilt=mmovil(serie1,n)
end
mprintf("La climatología mensual en mm/día para las %i estaciones es:\n (mes, e)",nc-3)
disp(clim)
// se obtiene la media movil triangular para las e estaciones con los datos 
// ausentes rellenados con la slimatología

salida1 = [serie1(1+N:nf-N,1:3) serfilt dias(1+N:nf-N,1)] //se ajusta la salida, esta tiene N datos menos al inicio y al final (por la definición de la media movil triangular, la ultima columna es el número del día por año.)

//Aquí se generan los primeros 15 días y los últimos 15 días con todo y eje temporal, luego se pegan en la 
//salida de la matriz ya procesada por la media movil triangular.
salidaini = [serie1(1:N,1:3) mi dias(1:N,1)]
salidafin = [serie1(nf-N+1:nf,1:3) mf dias(nf-N+1:nf,1)]
salida = [salidaini;salida1;salidafin]


endfunction

function [serfilt]=mmovil(serie1,n)
// [serfilt]=momovil(serie,n)
// calcula una ventana triangular de un promedio movil
// de n elementos
// donde serie son los datos de entrada y
// seriefilt son los datos filtrados con la ventana triangular 
// de n observaciones
// seriefilt tiene n datos menos que la serie original
k=zeros(n,1);
[nf,nc]=size(serie1);
serfilt = []
for i=1:n
    N=(n-1)/2;
    k(i)=(N+1-abs(-(N+1)+i))/((N+1)^2);
end
serfilt=zeros(length(serie1(:,1))-2*N,nc+1-4);
for e = 4:nc
    for i=1:length(serie1(:,e))-2*N
        serfilt(i,e-3)=sum(k .* serie1(i:i+n-1,e));
     end
end
endfunction
