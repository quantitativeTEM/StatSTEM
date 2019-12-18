function [alpha,beta,loglikelihood] = forwardBackwardAlgorithm(Gauss,Init,A)
    
    [scale,alpha] = forwardStep(Init,Gauss,A);
    beta = backwardStep(scale,Gauss,A);
    loglikelihood = sum(sum(log(scale)));
    
end