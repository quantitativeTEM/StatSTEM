function outputHMM = analyseFactorialHMM(inputHMM)

    %%%% outputHMM = runEM(inputHMM);
    O = inputHMM.O;
    libraries = inputHMM.libraries;
    num_components = inputHMM.num_components;
        
    % starting values 
    ScalingHybrid = 1;
    Sigma = (max(O(:)) - min(O(:)))/2/(inputHMM.num_components);
    Init = ones(1,inputHMM.num_components)/(inputHMM.num_components);
    A = ones(inputHMM.num_components,inputHMM.num_components)/(inputHMM.num_components);
    
    cyc = 1000;
    tol = 10^(-12);
    
    H_viterbi = [];
    LL_viterbi = 0;
    coordinates_T = inputHMM.coordinates_T;
    outputHMM = outputStatSTEM_HMM(ScalingHybrid,Sigma,Init,A,H_viterbi,LL_viterbi,coordinates_T); %inputHMMect uit die klasse aanmaken eerst
    
    loglikelihood = -Inf;
    
    if isempty(inputHMM.GUI)
        outputHMM.GUI = inputHMM.GUI;
    end
    if ~isempty(inputHMM.GUI)
        inputHMM.waitbar.setValue(0)
    else
        h_bar = waitbar(0,'Fitting... ');
    end

    
    for cycle=1:cyc
        oldlikelihood = loglikelihood;
        
        [gamma,xi,loglikelihood] = runEstep(O,libraries,num_components,ScalingHybrid,Sigma,Init,A);
        [A,Init,Sigma,ScalingHybrid] = runMstep(O,libraries,gamma,xi);
        
        check = checkConvergence(oldlikelihood,loglikelihood,tol,cycle);
        if check == 1 || cycle == cyc
            outputHMM.maxLogLikelihood = loglikelihood;
            outputHMM.A = A;
            outputHMM.Sigma = Sigma;
            outputHMM.Init = Init;
            outputHMM.ScalingHybrid = ScalingHybrid;
            break;
        end
        
        % Update waitbar
        if ~isempty(inputHMM.GUI)
            inputHMM.waitbar.setValue(cycle/cyc*100)
        else
            waitbar(cycle/cyc,h_bar,'Fitting ...')
        end
    
    end
    % Update waitbar
    if ~isempty(inputHMM.GUI)
        inputHMM.waitbar.setValue(95)
    else
        delete(h_bar)
    end
    %%%% outputHMM = Viterbi(inputHMM,outputHMM);
    T = size(O,1);
    N = size(O,2);
    
    delta = zeros(T,num_components,N);
    delta_all = zeros(T,num_components,num_components,N);
    arg = zeros(T,num_components,N);
    H = zeros(T,N);
    LL = zeros(1,N);
    
    Gauss = calculateEmissionProbability(O,libraries,num_components,ScalingHybrid,Sigma);
    
    % initialise best score and argument array
    delta(1,:,:) = Init.*reshape(Gauss(1,:,:),N,num_components)';
    arg(1,:,:) = 0;
    
    % recursion
        for t=2:T
            for n = 1:N
                for i_g = 1:(num_components)
                    delta_all(t,:,i_g,n) = delta(t-1,:,n).*A(:,i_g)';
                    [delta(t,i_g,n),arg(t,i_g,n)] = max(reshape(delta_all(t,:,i_g,n),num_components,1)); 
                    delta(t,i_g,n) = delta(t,i_g,n)*Gauss(t,n,i_g);
                end
                delta(t,:,n) = delta(t,:,n)/sum(delta(t,:,n)); %normalisatie owv computationele redenen!
            end
        end
    
    % termination step at time T
    for n = 1:N
        [LL(n), H(T,n)] = max(delta(T,:,n)); %nog steeds LL door normalisatie owv computationele redenen?
    end
    LL = prod(LL);
    
    % path backtracking
    for t = T-1:-1:1
        for n = 1:N
            H(t,n) = arg(t+1,H(t+1,n),n);
        end
    end
    
    if libraries(1) == 0
        outputHMM.H_viterbi = H - 1;
    else
        outputHMM.H_viterbi = H;
    end
    
    outputHMM.LL_viterbi = LL;

end
