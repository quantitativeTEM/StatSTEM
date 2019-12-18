function Gauss = calculateEmissionProbability(O,libraries,num_components,ScalingHybrid,Sigma)
    
    T = size(O,1);
    N = size(O,2);    

    Gauss = zeros(T,N,num_components);
    for t=1:T
        for n=1:N
            for i_g = 1:(num_components)
                Gauss(t,n,i_g)=normpdf(O(t,n),ScalingHybrid*libraries(i_g),Sigma);
            end
            Gauss(t,n,:) = Gauss(t,n,:)/sum(Gauss(t,n,:));
        end
    end
    
end