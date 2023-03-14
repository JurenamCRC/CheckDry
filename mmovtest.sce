function [ v_min,pro_mm,rango_ev,f_min_jul,f_min,fin_ev_jul,fin_ev,ini_ev_jul,ini_ev] = dryev2(serie, v1, v2)
   
    a = 1
    back = []
    forw = []
    [nf, nc] = size(serie);
    ini = serie(1,a);
    fin = serie($,a);
    años = linspace(ini,fin, fin+1-ini )';
    [nfa, nca] = size(años);
    for i = 32:32; //  rango total 1:nfa
        mask = find(serie(:,a) == años(i));
        serie_annos = serie(mask,:); // esta serie va de 1 hasta 366 máx
        // encontrar el valor mínimo de esa serie. 
        for e = 30:30 // rango total 4:nc-1
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
