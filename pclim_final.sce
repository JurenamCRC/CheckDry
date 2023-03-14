function [clim,salida]  = climmt(serie,n)
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
diar = []
dias = []
dr = []
d = []
serierell = []

for i = annos(1):annos($)
    mask = find(serie(:,a)==i)
    d = dias
    dias = linspace(1,length(mask), length(mask)+1-1 )'
    dias = [d;dias]
end 

// Aquí genero tres años de referencia y le coloco el numero del dia del año
for i = annos(2):annos(4)
    maskrell = find(serie(:,a)==i)
    dr = diar
    diar = linspace(1,length(maskrell), length(maskrell)+1-1 )'
    diar = [dr;diar]
    serier = serierell
    serierell = serie(maskrell,1:3)
    serierell = [serier;serierell]
    nulosr = %nan*ones(size(serierell,'r'),nc-3)
end 


serierell = [serierell nulosr diar] //genero una columnas de Nan para luego rellenarlos con la climatologia
serie1rell = serierell


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
        mask00 = find(serie(:,m)==i) // busco los datos del mes i
        masknull00 = find(isnan(serie(mask00,e))) //de los datos del mes i busco los datos nulos
        nulos00 = mask00(masknull00) // se genera la mascara del mes i con datos nulos
        serie1(nulos00,e)=clim(i, e-3) // sustituyo la climatología del mes i por los datos nulos del mes i para toda la serie
        // para la serie de referencia para rellenar antes de la media movil
        //Aqui relleno los tres años de prueba con los datos nulos por la climatologia.
        mask01 = find(serierell(:,m)==i) // busco los datos del mes i
        masknull01 = find(isnan(serierell(mask01,4))) //de los datos del mes i busco los datos nulos
        nulos01 = mask01(masknull01) // se genera la mascara del mes i con datos nulos
        serie1rell(nulos01,e)=clim(i, e-3) // sustituyo la climatología del mes i por los datos nulos del mes i para toda la serie
    end
    
end

// Aquí busco la primer y ultima fecha de los datos de entrada
vini = serie(1,1:3) 
vfin = serie($,1:3)

// Se busca el numero de dia juliano correspondiente a esa fecha
// Nota: si los datos de entrada empiezan o finalizan un 29 de Feb, el proceso explota.
maskini = find(serie1rell(:,2)==vini(:,2) & serie1rell(:,3)==vini(:,3))
v_ini = serie1rell(maskini(1),:)
maskfin = find(serie1rell(:,2)==vfin(:,2) & serie1rell(:,3)==vfin(:,3))
v_fin = serie1rell(maskfin(1),:)
v1_i = v_ini(1,$)+365
v2_f = v_fin(1,$)+365 
ag_i = serie1rell(v1_i-N:v1_i-1,1:nc) // primeros (n-1)/2 datos rellenados con la climatologia 
ag_f = serie1rell(v2_f+1:v2_f+N,1:nc) // ultimos (n-1)/2 datos rellenados con la climatologia 
seriepmmovil = [ ag_i;serie1;ag_f] // serie original con los Nan rellenados con la climatología, además con 15
// (n-1)/2 dias extra al inicio y al final rellenados con la climatología para no perder datos con la media movil.

serfilt=mmovil(seriepmmovil,n)
mprintf("La climatología mensual en mm/día de enero a diciembre para las %i estaciones es:\n (mes, e)",nc-3)
disp(clim)
// se obtiene la media movil triangular para las e estaciones con los datos 
// ausentes rellenados con la slimatología

salida = [seriepmmovil(1+N:$-N,1:3) serfilt dias] //se ajusta la salida, esta tiene N datos menos al inicio y al final (por la definición de la media movil triangular, la ultima columna es el número del día por año.)

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
