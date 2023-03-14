function [ou1] = testwhile(serie_an, mn)
    mn = 264-15
    d = 1
    e = 4
    d1=1
while serie_an(mn+1,e) > serie_an(mn,e)|| serie_an(mn+2,e) > serie_an(mn+1,e),
    ou1(d1,:) = serie_an(mn+1,:);
    mn = mn+1;
    d1 = d1+1;
end

endfunction
    
