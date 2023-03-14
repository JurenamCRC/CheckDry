function [ v_min,pro_mm,rango_ev,f_min_jul,f_min,fin_ev_jul,fin_ev,ini_ev_jul,ini_ev,clim,serie ] = dryev(datos, v1, v2, n)
// creado por B.Sc. Pablo Ureña Mora para Scilab 6.0.2 
// contacto: juan.urenamora@ucr.ac.cr jpablm@gmail.com 

// Edit: 28-Ago 2019 por P.Ureña
//(agregado el método para agregar (n-1)2 días al inicio y al final rellenados con la climatologia
// para no perder datos con la media movil )   

// [ v_min,pro_mm,rango_ev,f_min_jul,f_min,fin_ev_jul,fin_ev,ini_ev_jul,ini_ev,clim,serie ] = dryev(serie, 227, 304, 31);
     
//Esta rutina detecta los eventos secos entre dos fechas con número de día del año v1 y v2. Para esto calcula primero la climatología.
//Si hay datos ausentes (Nan) los rellena con el valor correspondiente de la climatología mensual según la estación que corresponda, se agregan
// (n-1)2 días al inicio y al final correspondientes y  rellenados con la climatologia, luego calcula 
//la media movil triangular de n valores y con esa métrica detecta la fecha del inicio, mínimo, y final del evento entre v1 y v2, rango en días, 
// promedio en mm, valor del mínimo, fecha del mínimo, entre otros. 

// ENTRADA  
// datos: matriz de datos donde las columnas son [año mes dia e1 e2 e3 ...],
// donde e1, e2, e3,... e_i son valores de precipitación diaria en mm (punto como separador decimal), con datos 
// faltantes codificados como Nan.
// v1: numero del dia del año para empezar el periodo de deteccion del evento.
// v2: numero del dia del año donde finaliza el periodo de deteccion del evento. 
// n: es la media movil triangular de n elementos (número IMPAR).
// SALIDA
// ini_ev: fecha donde inicia el evento según el minimo obtenido entre v1 y v2 para la estación e1, e2, ... ei, ordenado ascendentemente por año.
// ini_ev_jul: matriz (años,estaciones) donde sus valor es el número del día del año donde inicia el evento
// fin_ev: fecha donde finaliza el evento según el minimo obtenido entre v1 y v2 para la estación e1, e2, ... ei, ordenado ascendentemente por año.
// fin_ev_jul: matriz (años,estaciones) donde sus valor es el número del día del año donde finaliza el evento.
// f_min: fecha del minimo obtenido entre v1 y v2 para la estación e1, e2, ... ei, ordenado ascendentemente por año.
// f_min_jul: matriz (años,estaciones) donde sus valor es el número del día del año donde se encuentra el valor mínimo del evento.
// v_min: valor del minimo detectado entre v1 y v2 para la estación e1, e2, ... ei, ordenado ascendentemente por año.
// rango_ev: rango en dias del evento, esto sería donde la precipitacion es decreciente, llega al minimo y es creciente
// pro_mm: promedio en mm/dia de la precipitacion del rango del evento.
// clim: matríz de datos (12, e_i) donde cada fila es el valor climatológico mensual de Ene a Dic en mm/día para la estación e_i.
// salida: matriz resultante operada por la media movil triangular de n datos, de dimensiones [año mes dia e1 e2 e3 ...e_i, dia_del__año]

// NOTA IMPORTANTE: los datos de las estaciones de "datos" deben empezar en la columna 4 en adelante donde las primeras tres columnas son
// año mes y día en orden ascendiende de fecha. No se pueden omitir valores de fechas, todas deben estar presentes.
 
   
[clim, serie]  = climmt(datos,n) 
   
    a = 1
    back = []
    forw = []
    [nf, nc] = size(serie);
    ini = serie(1,a);
    fin = serie($,a);
    años = linspace(ini,fin, fin+1-ini )';
    [nfa, nca] = size(años);
    for i = 1:nfa; //  rango total 1:nfa
        mask = find(serie(:,a) == años(i));
        serie_annos = serie(mask,:); // esta serie va de 1 hasta 366 máx
        // encontrar el valor mínimo de esa serie. 
        for e = 4:nc-1 // rango total 4:nc-1
            serie_an = [serie_annos(:,1:3) serie_annos(:,e) serie_annos(:,$)]
            for v = v1:v2
                maskminimos = find(serie_an(:,4)==min(serie_an(v1:v2,4)))
                minimos = serie_an(maskminimos,:)
                maskmin = find(minimos(:,5)>=v1 & minimos(:,5)<=v2)
                min_serie = minimos(maskmin,:)
                mnb = min_serie(1,$)
                mnf = min_serie(1,$)
            end

            if serie_an(v1,4)<=min_serie(1,4) | serie_an(v2,4)<=min_serie(1,4) | mean(serie_an(v1:v2,4))==0 | size(min_serie,'r')>1 then
                if serie_an(v1,4)<=min_serie(1,4) then
                    mprintf("ALERTA: Se encontró  que en la estación %i la fecha %i/%i/%i el valor\n inicial v1 es el mínimo, se va a sustituir los valores para este año como Nan.\n",e-3,serie_an(v1,1),serie_an(v1,2),serie_an(v1,3))
                else
                    mprintf("ALERTA: Se encontró  que en la estación %i la fecha %i/%i/%i el valor\n final v2 es el mínimo, se va a sustituir los valores para este año como Nan.\n",e-3,serie_an(v2,1),serie_an(v2,2),serie_an(v2,3))
                end
                if mean(serie_an(v1:v2,4))==0 then
                    mprintf("ALERTA: Se encontró  que en la estación %i el año %i sus valores tienen precipitación = 0\n entre los días %i y %i, se va a sustituir los valores para este año como Nan.\n",e-3,serie_an(v2,1), v1, v2)
                elseif size(min_serie,'r')>1 then
                    mprintf("ALERTA: Se encontró  que en la estación %i el año %i tiene %i mínimos con valor de %i entre\n los días %i y %i, se va a sustituir los valores de las salidas para este año como Nan.\n",e-3,serie_an(v2,1), size(min_serie,'r'),mnb,v1,v2)
                end
                
                                    
                v_min(i,e-3) = %nan
                f_min(i,(e-3)*3-2:(e-3)*3) = %nan*ones(1,3)
                f_min_jul(i,(e-3)) = %nan
                ini_ev(i,(e-3)*3-2:(e-3)*3) = %nan*ones(1,3)
                ini_ev_jul(i,(e-3)) = %nan
                fin_ev(i,(e-3)*3-2:(e-3)*3) = %nan*ones(1,3)
                fin_ev_jul(i,(e-3)) = %nan
                rango_ev(i,e-3) = %nan
                pro_mm(i,e-3) = %nan
            else

                back = []
                d1 = 1 
                while serie_an(mnb-1,4) >= serie_an(mnb,4)  & serie_an(mnb-2,5) > serie_an(1,5), // se sale del loop cuando llega al inicio de la serie, esto para tener indices válidos y que el programa no se rompa.
                    back(d1,:) = serie_an(mnb-1,:);
                    mnb = mnb-1;
                    d1 = d1+1;
                end
                forw = []
                d2 = 1
                while serie_an(mnf+1,4) >= serie_an(mnf,4)& serie_an(mnf+1,5) < serie_an($,5),  //en caso de que el valor siga aumentando, la rutina se sale al final del año. 
                    forw(d2,:) = serie_an(mnf+1,:);
                    mnf = mnf+1;
                    d2 = d2+1;
                end

                v_min(i,e-3) = min_serie(1,4)
                f_min(i,(e-3)*3-2:(e-3)*3) = min_serie(1,1:3)
                f_min_jul(i,(e-3)) = min_serie(1,5)
                ini_ev(i,(e-3)*3-2:(e-3)*3) = back($,1:3)
                ini_ev_jul(i,(e-3)) = back($,5)
                fin_ev(i,(e-3)*3-2:(e-3)*3) = forw($,1:3)
                fin_ev_jul(i,(e-3)) = forw($,5)
                rango_ev(i,e-3) = forw($,5)-back($,5)+1
                range = [flipdim(back,1); min_serie; forw]
                pro_mm(i,e-3) = round(mean(range(:,4))*100)/100

            end
        end
    end
endfunction

function [clim,salida]  = climmt(serie,n)
//    [clim, salida ]  = todas(serie,n);
// este programita recibe una serie de datos diarios, calcula su climatología
// mensual en mm/dia, sustituye los valores nulos por la climatología de esa estación, se agregan
// (n-1)/2 días al inicio y al final correspondientes y rellenados con la climatologia para no perder datos con la media movil,
// luego calcula una media movil triangular de n elementos, esto se guarda en "salida" 
// ENTRADA  
// serie: matriz de datos donde las columnas son [año mes dia e1 e2 e3 ...],
// donde e1, e2, e3,... e_i son valores de precipitación diaria en mm, con datos 
// faltantes codificados como Nan.
// n: es la media movil triangular de n elementos. ESTA DEBE SER IMPAR!!
// SALIDA
// clim: matríz de datos (12, e_i) donde cada fila es el valor climatológico
// mensual de Ene a Dic en mm/día para la estación e_i.
// salida: matriz resultante de dimensiones [año mes dia e1 e2 e3 ...e_i, dia]
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
