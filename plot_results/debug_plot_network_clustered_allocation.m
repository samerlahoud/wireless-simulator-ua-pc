idx = kmeans(femto_to_femto_pathloss,5)
figure(1);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs(idx == 1),femto_BS_ord(idx == 1),'g^','MarkerFaceColor','g');
plot(femto_BS_abs(idx == 2),femto_BS_ord(idx == 2),'r^','MarkerFaceColor','r');
plot(femto_BS_abs(idx == 3),femto_BS_ord(idx == 3),'k^','MarkerFaceColor','k');
plot(femto_BS_abs(idx == 4),femto_BS_ord(idx == 4),'c^','MarkerFaceColor','c');
plot(femto_BS_abs(idx == 5),femto_BS_ord(idx == 5),'y^','MarkerFaceColor','y');


idx = kmeans(femto_to_femto_pathloss,7)
figure(1);
voronoi(macro_BS_abs, macro_BS_ord,'k');
hold on
plot(macro_BS_abs,macro_BS_ord,'b^','MarkerFaceColor','b','MarkerSize',8);
plot(femto_BS_abs(idx == 1),femto_BS_ord(idx == 1),'g^','MarkerFaceColor','g');
plot(femto_BS_abs(idx == 2),femto_BS_ord(idx == 2),'r^','MarkerFaceColor','r');
plot(femto_BS_abs(idx == 3),femto_BS_ord(idx == 3),'k^','MarkerFaceColor','k');
plot(femto_BS_abs(idx == 4),femto_BS_ord(idx == 4),'c^','MarkerFaceColor','c');
plot(femto_BS_abs(idx == 5),femto_BS_ord(idx == 5),'y^','MarkerFaceColor','y');
plot(femto_BS_abs(idx == 6),femto_BS_ord(idx == 6),'m^','MarkerFaceColor','m');
plot(femto_BS_abs(idx == 7),femto_BS_ord(idx == 7),'k^','MarkerFaceColor','k');


nb_macro_BSs = netconfig.nb_macro_BSs;
femto_to_femto_pathloss = BS_to_BS_pathloss(nb_macro_BSs+1:end,nb_macro_BSs+1:end);

figure 
data = femto_RB_allocation
pcolor(data)
colormap(gray(2))
axis ij
axis square

figure
imagesc(femto_to_femto_pathloss < 1e13)
colorbar

figure 
data = previous_femto_RB_allocation
pcolor(data)
colormap(gray(2))
axis ij
axis square

figure
% Create a 3x4 array of sample data in the range of 0-255.
data = femto_to_femto_pathloss
% Display it.
image(data);
% Initialize a color map array of 256 colors.
colorMap = jet(256);
% Apply the colormap and show the colorbar
colormap(colorMap);
colorbar;