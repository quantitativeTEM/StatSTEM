function gamma = calculateGamma(alpha,beta)
    
   T = size(alpha,1);
   N = size(alpha,2);
   num_components = size(alpha,3);
    
   gamma = zeros(T,N,num_components);
    for t = 1:T
        for n = 1:N
            gamma(t,n,:) = (alpha(t,n,:).*beta(t,n,:))/sum((alpha(t,n,:).*beta(t,n,:)));
        end
    end

end