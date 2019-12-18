function [gamma,xi,loglikelihood] = runEstep(O,libraries,num_components,ScalingHybrid,Sigma,Init,A)

    
    
    Gauss = calculateEmissionProbability(O,libraries,num_components,ScalingHybrid,Sigma);
    [alpha,beta,loglikelihood] = forwardBackwardAlgorithm(Gauss,Init,A);
    gamma = calculateGamma(alpha,beta);
    xi = calculateXi(alpha,beta,A,Gauss);
    
end
