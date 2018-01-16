sinr_assoc = zeros(1,100);
for u=1:100
    for b=1:84
        if m6_ua(u,b) == 1
            sinr_assoc(u) = m6_sinr(u,b);
        end
    end
end