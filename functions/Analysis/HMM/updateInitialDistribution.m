function Init = updateInitialDistribution(expectedValueBinaryH)

    num_components = size(expectedValueBinaryH,3);

    Init = zeros(num_components,1);
    for i_g = 1:(num_components)
        Init(i_g) = sum(expectedValueBinaryH(1,:,i_g))/sum(sum(expectedValueBinaryH(1,:,:)));
    end
    
end