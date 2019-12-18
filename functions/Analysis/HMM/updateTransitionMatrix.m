function A = updateTransitionMatrix(expectedValueProductBinaryH)

    T = size(expectedValueProductBinaryH,1)+1;
    N = size(expectedValueProductBinaryH,2);
    num_components = size(expectedValueProductBinaryH,3);
    
    A = zeros(num_components,num_components);
    for i_j = 1:(num_components)
        for i_g = 1:(num_components)
            A_teller = 0;
            A_noemer = 0;
            for t = 2:T
                for n = 1:N
                    A_teller = A_teller + expectedValueProductBinaryH(t-1,n,i_j,i_g); 
                    for i_k = 1:(num_components)
                        A_noemer = A_noemer + expectedValueProductBinaryH(t-1,n,i_j,i_k);
                    end
                end
            end
            if A_noemer ~= 0
                A(i_j,i_g) = A_teller/A_noemer;
            elseif A_noemer == 0 && A_teller == 0
                A(i_j,i_g) = 0;
            else
                A(i_j,i_g) = 0;
                warning('something went wrong while updating transition probabilities; changed to 0')
            end
        end
    end

end