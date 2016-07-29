function s = spatiallyCorrelateMap(n_neighbors,offsets_neighbors,L_tilde,a_n_matrix,lambda_n_T)
% Spatially correlates map. Separately written so as to allow automatic
% code generation

N_x         = size(a_n_matrix,2);
N_y         = size(a_n_matrix,1);
num_eNodeBs = size(a_n_matrix,3);
s   = zeros(N_y,N_x,num_eNodeBs);

%% Calculate space-correlated maps
for y_=1:N_y
    for x_=1:N_x
        % Substitutes the LTE_aux_shadowFadingMapClaussen_get_neighbors function
        s_tilde            = zeros(n_neighbors,num_eNodeBs);
        neighbor_positions = [x_+offsets_neighbors(:,1) y_+offsets_neighbors(:,2)];
        positions_geq0     = neighbor_positions>0;
        positions_leqroi   = [neighbor_positions(:,1)<=N_x neighbor_positions(:,2)<=N_y];
        positions_valid    = (positions_geq0(:,1)&positions_geq0(:,2)) & (positions_leqroi(:,1)&positions_leqroi(:,2));
        
        for i_=1:n_neighbors
            if positions_valid(i_)
                s_tilde(i_,:) = s(neighbor_positions(i_,2),neighbor_positions(i_,1),:);
            end
        end
        
        inv_L_tilde_s_tilde = L_tilde\s_tilde;
        a_n_all = reshape(a_n_matrix(y_,x_,:),1,[]);
        inv_L_tilde_s_tilde_a_n = [inv_L_tilde_s_tilde;a_n_all];
        s(y_,x_,:) = lambda_n_T*inv_L_tilde_s_tilde_a_n;
    end
end

end

