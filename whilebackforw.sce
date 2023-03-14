function ini_ev, ini_ev_jul, fin_ev, fin_ev_jul, rango_ev = whilebackforw(serie_an, mnb, mnf)

back = []
d1 = 1    
while serie_an(mnb-1,4) >= serie_an(mnb,4)  & serie_an(mnb-2,5) > serie_an(1,5), // se sale 
    // del loop cuando llega al inicio de la serie, esto para tener indices válidos y que 
    // el programa no se rompa.
    back(d1,:) = serie_an(mnb-1,:);
    mnb = mnb-1;
    d1 = d1+1;
end
forw = []
d2 = 1
while serie_an(mnf+1,4) >= serie_an(mnf,4)& serie_an(mnb+1,5) < serie_an($,5),  //en caso de
    // que el valor siga aumentando, la rutina se sale al final del año. 
    forw(d2,:) = serie_an(mnf+1,:);
    mnf = mnf+1;
    d2 = d2+1;
end
endfunction
