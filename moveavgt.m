function [serfilt]=moveavgt(serie,n)
% [serfilt]=moveavgt(serie,n)
% calcula una ventana triangular de un promedio movil
% de n elementos
% donde serie son los datos de entrada y
% seriefilt son los datos filtrados con la ventana triangular 
% de n observaciones
% seriefilt tiene n datos menos que la serie original
k=zeros(n,1);
[nf,nc]=size(serie);
if nc > 1
   serie=serie';
end
for i=1:n
 N=(n-1)/2;
 k(i)=(N+1-abs(-(N+1)+i))/((N+1)^2);
end
serfilt=zeros(length(serie)-2*N,1);
for i=1:length(serie)-2*N
 serfilt(i)=sum(k .* serie(i:i+n-1));
end