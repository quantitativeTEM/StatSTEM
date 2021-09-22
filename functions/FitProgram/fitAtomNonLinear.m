function EstimatedParametersnonlin = fitAtomNonLinear(method,inCoordinates,obs_bs,X,Y,Box,betaX_estimatedbackground,betaY_estimatedbackground,rho_estimatedbackground,eta_estimatedbackground,dx,radius,options,ind)

betaX_org = inCoordinates(:,1);
betaY_org = inCoordinates(:,2);
type = inCoordinates(:,3);

if strcmp(method,'same')
    EstimatedParametersnonlin = zeros(2,length(ind));
else
    EstimatedParametersnonlin = zeros(3,length(ind));
end
for n=1:length(ind)
    i = ind(n);
    % select section of the image and grid around a single atom column
    [obs_s, X_s, Y_s, K_s, L_s] = selectSection(obs_bs, X, Y, Box(type(i)),betaX_org(i)/dx, betaY_org(i)/dx);
    [betaX_b, betaY_b, rho_b, eta_b] = selectParameters(betaX_estimatedbackground, betaY_estimatedbackground, rho_estimatedbackground, eta_estimatedbackground, radius,i);
    LsKs = L_s*K_s;
    reshapeX_s = reshape(X_s,LsKs,1);
    reshapeY_s = reshape(Y_s,LsKs,1);

    % Create model to subtract from partial images, for overlap neighbouring columns
    combined_background = sparse(LsKs,1);
    for k = 1:length(betaX_b)
        R2 = (reshapeX_s - betaX_b(k)).^2 + (reshapeY_s - betaY_b(k)).^2;
        combined_background = combined_background + eta_b(k)*exp(-R2/(2*rho_b(k)^2));
    end
    obs_s_back = reshape(obs_s,LsKs,1) - combined_background;

    % fit
    if strcmp(method,'same')
        StartParametersnonlin_s = [betaX_estimatedbackground(i) betaY_estimatedbackground(i)];
        EstimatedParametersnonlin(:,n) = lsqnonlin('criterionGauss_samerho',StartParametersnonlin_s',[],[],options,reshapeX_s,reshapeY_s,K_s,L_s,obs_s_back,rho_estimatedbackground(i));
    else
        StartParametersnonlin_s = [betaX_estimatedbackground(i) betaY_estimatedbackground(i) rho_estimatedbackground(i)];
        EstimatedParametersnonlin(:,n) = lsqnonlin('criterionGauss_diffrho',StartParametersnonlin_s',[],[],options,reshapeX_s,reshapeY_s,K_s,L_s,obs_s_back);
    end
end