function Sigma = updateWidth(O,expectedValueBinaryH,libraries,ScalingHybrid)

    T = size(expectedValueBinaryH,1);
    N = size(expectedValueBinaryH,2);
    num_components = size(expectedValueBinaryH,3);

    Sigma = 0;
    for t = 1:T
        for n = 1:N
            for i_g = 1:(num_components)
                Sigma = Sigma + expectedValueBinaryH(t,n,i_g)*(O(t,n)-ScalingHybrid*libraries(i_g))^2;
            end
        end
    end
    Sigma = sqrt(Sigma/sum(expectedValueBinaryH(:)));
    
end