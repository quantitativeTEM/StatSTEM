function f = criterion_MAP_back_samerho(p,xi,yi,m,n_exp,psizex,psizey)

[X,Y] = meshgrid(xi,yi);
zs = zeros(psizey,psizex);

fb = zs + p(1);
for i = 1:n_exp
    R2 = (X-p(3*i+1)).^2 + (Y-p(3*i+2)).^2;
    fb = fb + p(3*i)*exp(-0.5*R2./(p(2))^2);
end

mm = m;
mm(mm<0) = 0;
sigma = mm.^0.5;
sigma(sigma==0) = 1; 
f = (m - fb)./sigma;