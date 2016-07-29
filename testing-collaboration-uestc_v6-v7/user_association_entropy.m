total_nb_users=10;
nb_sectors=7;
nb_RBs=15;
rho = 10+rand(total_nb_users,nb_sectors,nb_RBs);

% Geometric programming formulation of the problem
cvx_begin
cvx_solver mosek
% variables are power levels
variable theta(total_nb_users,nb_sectors) %binary

% Expressions used in computations
expression nb_users_per_sector(nb_sectors)
expression left_expr_objective
expression right_expr_objective

for i=1:total_nb_users
    for j=1:nb_sectors
        for k=1:nb_RBs
            left_expr_objective = left_expr_objective + theta(i,j)*log(rho(i,j,k));
        end
    end
end

%left_expr_objective = sum(sum(theta));
for j=1:nb_sectors
    nb_users_per_sector(j) = sum(theta(:,j));
end

right_expr_objective = nb_RBs * sum(entr(nb_users_per_sector));

objective=left_expr_objective + right_expr_objective;
maximize(objective)

subject to
for i=1:total_nb_users
    sum(theta(i,:)) <= 1;
end 
0<=theta<=1;
cvx_end
theta