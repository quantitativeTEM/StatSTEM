function xi = calculateXi(alpha,beta,A,Gauss)

   T = size(alpha,1);
   N = size(alpha,2);
   num_components = size(alpha,3);

    xi = zeros(T-1,N,num_components,num_components);
    for t=1:T-1
        for n = 1:N
            xi(t,n,:,:) = A.*(reshape(alpha(t,n,:),num_components,1)*reshape(beta(t+1,n,:).*Gauss(t+1,n,:),1,num_components));
            xi(t,n,:,:) = xi(t,n,:,:)/sum(sum(xi(t,n,:,:)));
        end
    end
    
end