function [A,Init,Sigma,ScalingHybrid] = runMstep(O,libraries,gamma,xi)

    A = updateTransitionMatrix(xi);

    Init = updateInitialDistribution(gamma);

    ScalingHybrid = updateScalingParameter(O,gamma,libraries);

    Sigma = updateWidth(O,gamma,libraries,ScalingHybrid);
    

end