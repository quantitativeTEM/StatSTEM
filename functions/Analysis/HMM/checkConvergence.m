function check = checkConvergence(oldvalue,newvalue,tolerance,cycle)

    check = 0;
    if cycle > 2
       if abs((newvalue-oldvalue)/oldvalue) < tolerance
           check = 1;
       end
    end

    if ~isfinite(newvalue)
       warning('no longer finite: convergence aborted')
       check = 1;
    end

end