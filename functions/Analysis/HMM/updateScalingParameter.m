function ScalingHybrid = updateScalingParameter(O,expectedValueBinaryH,libraries)

    T = size(O,1);
    N = size(O,2);
    num_components = size(expectedValueBinaryH,3);

    ScalingHybrid_n = 0;
    ScalingHybrid_dn = 0;
    for t = 1:T
        for n = 1:N
            ScalingHybrid_n = ScalingHybrid_n + O(t,n)*reshape(expectedValueBinaryH(t,n,:),1,num_components)*libraries(1:(num_components));
            ScalingHybrid_dn = ScalingHybrid_dn + reshape(expectedValueBinaryH(t,n,:),1,num_components)*(libraries(1:(num_components)).^2);
        end
    end
    ScalingHybrid = ScalingHybrid_n/ScalingHybrid_dn;
    
end