function [ v_min,pro_mm,rango_ev,f_min_jul,f_min,fin_ev_jul,fin_ev,ini_ev_jul,ini_ev,clim,serie ] = dryev(datos, v1, v2, n)
// creado por B.Sc. Pablo Ureña Mora para Scilab 6.0.2 
// contacto: juan.urenamora@ucr.ac.cr jpablm@gmail.com 
// Jun 2019   

// [ v_min,pro_mm,rango_ev,f_min_jul,f_min,fin_ev_jul,fin_ev,ini_ev_jul,ini_ev,clim,serie ] = dryev(serie, 227, 304, 31);
     
//Esta rutina detecta los eventos secos entre dos fechas con número de día del año v1 y v2. Para esto calcula primero la climatología.
//Si hay datos ausentes (Nan) los rellena con el valor correspondiente de la climatología mensual según la estación que corresponda, luego calcula 
//la media movil triangular de n valores y con esa métrica detecta la fecha del inicio, mínimo, y final del evento entre v1 y v2, rango en días, 
// promedio en mm, valor del mínimo, fecha del mínimo, entre otros. 

// ENTRADA  
// datos: matriz de datos donde las columnas son [año mes dia e1 e2 e3 ...],
// donde e1, e2, e3,... e_i son valores de precipitación diaria en mm (punto como separador decimal), con datos 
// faltantes codificados como Nan.
// v1: numero del dia del año para empezar el periodo de deteccion del evento.
// v2: numero del dia del año donde finaliza el periodo de deteccion del evento. 
// n: es la media movil triangular de n elementos (se recomienda que sea un número impar).
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
// salida: matriz resultante operada por la media movil triangular de dimensiones [año mes dia e1 e2 e3 ...e_i, dia_del__año], esta matriz
// tiene los (n-1)/2 datos iniciales y finales rellenados con la climatología.

// NOTA IMPORTANTE: los datos de las estaciones de "datos" deben empezar en la columna 4 en adelante donde las primeras tres columnas son
// año mes y día en orden ascendiende de fecha. No se pueden omitir valores de fechas, todas deben estar presentes.

// rango recomendado, para el otoñillo, v1 = 227 (15-Ago), v2 = 304 (31-Oct)  
   
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
mprintf("La climatología mensual en mm/día de enero a diciembre para las %i estaciones es:\n (mes, e)",nc-3)
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
