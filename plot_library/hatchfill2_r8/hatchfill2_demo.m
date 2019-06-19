%HATCHFILL2_DEMO   Demonstration script for HATCHFILL2 function
%  4 examples from original HATCHFILL by Neil Tandon
%  a bar plot example

clear; close all; drawnow

%%% In this example, the 2 contour of a contour plot
%%% is filled with hatching.
load([mfilename '_data']);

% plot background data
figure;
[~,h] = contourf(lat,p,temp,150:10:320);
caxis([190 270]);
set(h,'linestyle','none');
hold on;

% plot hatching region:
% zone(40:60,15:20) = nan; % force errorneous case
[c2,h2] = contourf(lat2,p2,zone,[2 2]); % plots only the 2 contour
set(h2,'linestyle','none','Tag','HatchingRegion');
hold off;                                 % if you want to have more control
ax1 = gca;
ax2 = copyobj(ax1,figure);

% Example 1: Default hatching
hp = findobj(ax1,'Tag','HatchingRegion');
hh = hatchfill2(hp,'cross','LineWidth',1,'Fill','off');
title('Example 1: hatchfill2(hp,''HatchColor'',''w'',''FaceColor'',''none'')');

% Example 2: Set logarithmic yscale and reverse yaxis & speckle
set(ax2,'ylim',[50 700],'yscale','log','ydir','reverse');
hp = findobj(ax2,'Tag','HatchingRegion');
% h1 = hatchfill2(hp,'speckle','HatchColor','w');
h1 = hatchfill2(hp,'HatchColor','w');
title('Example 2: hatchfill2(hp,''speckle'',''HatchColor'',''w'') on log-scaled reversed y-axes');

% Example 3: Cross-hatching of multi-face patch
xdata = [2 2 0 2 5;
   2 8 2 4 5;
   8 8 2 4 8];
ydata = [4 4 4 2 0;
   8 4 6 2 2;
   4 0 4 0 0];
figure;
hp = patch(xdata,ydata,linspace(0,1,size(xdata,2)),'EdgeColor','none');
hatchfill2(hp,'cross','HatchAngle',45,'HatchDensity',20,'HatchColor','b','HatchLineWidth',2);
% hatchfill2(hp,'speckle','HatchAngle',45,'HatchDensity',50,'HatchColor','b','HatchLineWidth',2);
title('Example 3: Hatching a patch object with multiple faces');

% Example 4: bar plot hatching
c = load('count.dat');
Y = c(1:6,:);
figure;
hp = bar(Y,'stacked');
hatchfill2(hp(1),'single','HatchAngle',0);
hatchfill2(hp(2),'cross','HatchAngle',45);
hatchfill2(hp(3),'single','HatchAngle',90);
legend('Macro','Femto','mmWave')
title('Example 4: Hatching bars of a bar plot');

% Example 5: 3D hatching
t = linspace(0,3,101)';
x = cos(2*pi*t);
y = sin(2*pi*t);
plot3(t,x,y)

%REAL PROJECTION
hx = patch('XData',[t(1);t;t(end)],'YData',[0;x;0],'ZData',zeros(length(t)+2,1),'FaceColor','b','EdgeColor','b','LineWidth',1,'EdgeAlpha',0.5,'FaceAlpha',0.15);
hatchfill2(hx,'cross','LineWidth',1,'FaceColor','none','HatchStyle','single','HatchAngle',90,'HatchDensity',50);

%IMAG PROJECTION
hy = patch('XData',[t(1);t;t(end)],'YData',zeros(length(t)+2,1),'ZData',[0;y;0],'FaceColor','b','EdgeColor','b','LineWidth',1,'EdgeAlpha',0.5,'FaceAlpha',0.15);
hatchfill2(hy,'cross','LineWidth',1,'FaceColor','none','HatchStyle','single','HatchAngle',90,'HatchDensity',50);
