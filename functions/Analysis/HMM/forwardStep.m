function [scale,alpha] = forwardStep(Init,Gauss,A)
    
    T = size(Gauss,1);
    N = size(Gauss,2);
    num_components = size(Gauss,3);
    
    scale=zeros(T,N);
    alpha = zeros(T,N,num_components);
    for n = 1:N
        for i_g = 1:(num_components)
            alpha(1,n,i_g)=Init(i_g)*Gauss(1,n,i_g);
        end
        scale(1,n)=sum(alpha(1,n,:));
        alpha(1,n,:)=alpha(1,n,:)/scale(1,n);
    end
    for t = 2:T
        for n = 1:N
            for i_g = 1:(num_components)
                alpha_sum = 0;
                for i_j = 1:(num_components)
                    alpha_sum = alpha_sum + alpha(t-1,n,i_j)*A(i_j,i_g);
                end
                alpha(t,n,i_g) = Gauss(t,n,i_g)*alpha_sum;
            end
            scale(t,n)=sum(alpha(t,n,:));
            alpha(t,n,:)=alpha(t,n,:)/scale(t,n);
        end
    end

    
end