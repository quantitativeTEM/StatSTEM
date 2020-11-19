function beta = backwardStep(scale,Gauss,A)
    
    T = size(Gauss,1);
    N = size(Gauss,2);
    num_components = size(Gauss,3);
    
    beta = zeros(T,N,num_components);
    beta(T,:,:) = ones(1,N,num_components);%/scale(T,n);
    for t = T-1:-1:1
        for n = 1:N
            for i_g = 1:(num_components)
                beta_sum = 0;
                for i_j = 1:(num_components)
                    beta_sum = beta_sum + beta(t+1,n,i_j)*Gauss(t+1,n,i_j)*A(i_g,i_j);
                end
                beta(t,n,i_g) = beta_sum/scale(t+1,n);
            end
        end
    end
    
end