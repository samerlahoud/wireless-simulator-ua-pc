L=60;
G=rand(L,L);
p=ones(1,L)*8;
cump=[p];
nb_steps = 500;

k=0.001;
epsilon=1e-6;
n=1e-6;

for s=1:nb_steps 
    for l=1:L
        partial_grad = 0;
        for j=1:L
            if j == l
                continue;
            else
                interf = 0;
                for k=1:L
                    if k==j
                        continue;
                    else
                        interf = interf + G(j,k)*p(k);
                    end
                end
                partial_grad = partial_grad + (G(j,l)/(interf+n));
            end 
        end
        p(l) = p(l) + k*(1/p(l) - partial_grad);
    end
    if(norm(p-cump(end,:)))<epsilon
        break;
    end
    cump=[cump;p];
end

plot([1:s],cump);