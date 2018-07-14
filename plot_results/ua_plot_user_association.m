% Fancy plotting
%load('./output/radio_generation.mat')
%load('./output/user_association.mat');

global netconfig;
nb_users = netconfig.nb_users;
nb_femto_BSs = netconfig.nb_femto_BSs;
nb_macro_BSs = netconfig.nb_macro_BSs;
nb_BSs = netconfig.nb_BSs;

macro_BS_abs = BS_abs(1:nb_macro_BSs);
macro_BS_ord = BS_ord(1:nb_macro_BSs);
femto_BS_abs = BS_abs(nb_macro_BSs+1:nb_macro_BSs+nb_femto_BSs);
femto_BS_ord = BS_ord(nb_macro_BSs+1:nb_macro_BSs+nb_femto_BSs);
mmwave_BS_abs = BS_abs(nb_macro_BSs+nb_femto_BSs+1:end);
mmwave_BS_ord = BS_ord(nb_macro_BSs+nb_femto_BSs+1:end);

figure(1);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
for u = 1:nb_users
    associated_BS_idx = find(m1_ua(u,:)>=1e-3);
    for b = associated_BS_idx
        plot([user_abs(u),BS_abs(b)],[user_ord(u),BS_ord(b)],'b:');
    end
end
%print -deps -color test.eps
hold off

figure(2);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
for u = 1:nb_users
    associated_BS_idx = find(m2_ua(u,:)>=1e-3);
    for b = associated_BS_idx
        plot([user_abs(u),BS_abs(b)],[user_ord(u),BS_ord(b)],'b:');
    end
end
%print -deps -color test.eps
hold off

figure(3);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
for u = 1:nb_users
    associated_BS_idx = find(m3_ua(u,:)>=1e-3);
    for b = associated_BS_idx
        plot([user_abs(u),BS_abs(b)],[user_ord(u),BS_ord(b)],'b:');
    end
end
%print -deps -color test.eps
hold off

figure(4);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
for u = 1:nb_users
    associated_BS_idx = find(m4_ua(u,:)>=1e-3);
    for b = associated_BS_idx
        plot([user_abs(u),BS_abs(b)],[user_ord(u),BS_ord(b)],'b:');
    end
end
%print -deps -color test.eps
hold off

figure(5);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
for u = 1:nb_users
    associated_BS_idx = find(m5_ua(u,:)>=1e-3);
    for b = associated_BS_idx
        plot([user_abs(u),BS_abs(b)],[user_ord(u),BS_ord(b)],'b:');
    end
end
%print -deps -color test.eps
hold off

f=figure(6);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs,femto_BS_ord,'r^','MarkerFaceColor','r');
plot(mmwave_BS_abs,mmwave_BS_ord,'g^','MarkerFaceColor','g');
plot(user_abs, user_ord, 'x');
print(f,'-depsc', './output/hetnetwork.eps');
savefig('./output/hetnetwork.fig');
matlab2tikz('./output/hetnetwork.tex','showInfo', false, ...
        'parseStrings',false,'standalone', false, ...
        'height', '\figureheight', 'width','\figurewidth');